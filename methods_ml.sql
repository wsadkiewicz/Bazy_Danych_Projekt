create or replace package szkola_jazdy_pkg as
    procedure dodaj_instruktora(p_id number, p_imie varchar2, p_nazwisko varchar2);
    procedure dodaj_pojazd(p_nr_rej varchar2, p_model varchar2, p_przebieg number);
    procedure zmien_status_pojazdu(p_nr_rej varchar2, p_dostepnosc varchar2);
    function sprawdz_serwis(p_nr_rej varchar2) return varchar2;
    procedure zarejestruj_kursanta(p_nr_pkk varchar2, p_imie varchar2, p_nazwisko varchar2);
    procedure wyrejestruj_kursanta(p_nr_pkk varchar2);
    
    procedure dodaj_jazde(p_nr_pkk varchar2, p_nr_rej varchar2, p_id_instr number, p_godziny number, p_typ_lekcji varchar2, p_data_jazdy date);
    procedure zakoncz_lekcje(p_nr_pkk varchar2, data date, p_przebieg number);
    
    function status_kursu(p_nr_pkk varchar2) return number;
    function wygeneruj_raport(p_nr_pkk varchar2) return sys_refcursor;
end szkola_jazdy_pkg;
/

create or replace package body szkola_jazdy_pkg as
    procedure dodaj_instruktora(p_id number, p_imie varchar2, p_nazwisko varchar2) is
    begin
        insert into instruktorzy_tab 
        values (instruktor_type(p_id, p_imie, p_nazwisko));
        
        commit;
        dbms_output.put_line('Dodano instruktora: ' || p_imie || ' ' || p_nazwisko);
    exception
        when dup_val_on_index then
            raise_application_error(-20001, '[Błąd] Instruktor o id ' || p_id || ' już istnieje.');
    end dodaj_instruktora;
    
    
    procedure dodaj_pojazd(p_nr_rej varchar2, p_model varchar2, p_przebieg number) is
    begin
        insert into pojazdy_tab values (
            pojazd_type(
                p_nr_rej,
                p_model,
                p_przebieg,
                'tak',
                lista_serwisow_type()
            )
        );
    exception
        when dup_val_on_index then
            raise_application_error(-20001, 'Pojazd o podanym numerze rejestracyjnym już istnieje.');
    end dodaj_pojazd;

    
    
    procedure zmien_status_pojazdu(p_nr_rej varchar2, p_dostepnosc varchar2) is
    begin
        if p_dostepnosc not in ('tak', 'nie') then
             raise_application_error(-20003, '[Błąd] Status musi być "tak" lub "nie"');
        end if;

        update pojazdy_tab 
        set dostepny = p_dostepnosc 
        where nr_rejestracyjny = p_nr_rej;
        
        if sql%rowcount = 0 then
            raise_application_error(-20002, '[Błąd] Nie znaleziono pojazdu o numerze ' || p_nr_rej);
        end if;
        
        commit;
        dbms_output.put_line('Zmieniono status pojazdu ' || p_nr_rej || ' na: ' || p_dostepnosc);
            
    end zmien_status_pojazdu;
    
    
    function sprawdz_serwis(p_nr_rej varchar2) return varchar2 is
        aktualny_przebieg number;
        ostatni_serwis    number;
        limit             constant number := 15000;
    begin
        select p.przebieg into aktualny_przebieg
        from pojazdy_tab p
        where nr_rejestracyjny = p_nr_rej;
    
        select nvl(max(s.przebieg), 0) into ostatni_serwis
        from pojazdy_tab p, table(p.historia_serwisow) s
        where p.nr_rejestracyjny = p_nr_rej;
        
        if (aktualny_przebieg - ostatni_serwis) >= limit then
             return 'Pojazd wymaga serwisu.';
        else
             return 'Pojazd nie wymaga serwisu.';
        end if;
        
    exception
        when no_data_found then
            raise_application_error(-20002, '[Błąd] Nie znaleziono pojazdu o numerze ' || p_nr_rej);
    end sprawdz_serwis;
    
    
    procedure zarejestruj_kursanta(p_nr_pkk varchar2, p_imie varchar2, p_nazwisko varchar2) is
    begin
        insert into kursanci_tab values(kursant_type(p_nr_pkk, p_imie, p_nazwisko, lista_lekcji_type()));
        
        commit;
        dbms_output.put_line('Zarejestrowano kursanta ' || p_imie || ' ' || p_nazwisko);
        
    exception
        when dup_val_on_index then
            raise_application_error(-20001, '[Błąd] Kursant o PKK ' || p_nr_pkk || ' już istnieje.');
    end zarejestruj_kursanta;
    
    
    procedure wyrejestruj_kursanta(p_nr_pkk varchar2) is
    begin
        delete from kursanci_tab
        where nr_pkk = p_nr_pkk;
    
        if sql%rowcount = 0 then
            raise_application_error(-20002, 'Nie znaleziono kursanta o podanym numerze PKK.');
        end if;
    end wyrejestruj_kursanta;


    
    
    procedure dodaj_jazde(
        p_nr_pkk varchar2,
        p_nr_rej varchar2,
        p_id_instr number,
        p_godziny number,
        p_typ_lekcji varchar2,
        p_data_jazdy date
    ) is
        v_ref_instr  ref instruktor_type;
        v_ref_pojazd ref pojazd_type;
    begin
        select ref(i)
        into v_ref_instr
        from instruktorzy_tab i
        where i.id_instruktora = p_id_instr;
    
        select ref(p)
        into v_ref_pojazd
        from pojazdy_tab p
        where p.nr_rejestracyjny = p_nr_rej
          and p.dostepny = 'tak';
    
        update kursanci_tab k
        set k.historia_jazd =
            case
                when k.historia_jazd is null then
                    lista_lekcji_type(
                        lekcja_type(
                            p_data_jazdy,
                            p_godziny,
                            v_ref_instr,
                            v_ref_pojazd,
                            null,
                            p_typ_lekcji,
                            'nie'
                        )
                    )
                else
                    k.historia_jazd multiset union all
                    lista_lekcji_type(
                        lekcja_type(
                            p_data_jazdy,
                            p_godziny,
                            v_ref_instr,
                            v_ref_pojazd,
                            null,
                            p_typ_lekcji,
                            'nie'
                        )
                    )
            end
        where k.nr_pkk = p_nr_pkk;
    
        if sql%rowcount = 0 then
            raise_application_error(-20003, 'Nie znaleziono kursanta o podanym PKK.');
        end if;
    end dodaj_jazde;


    
    
    procedure zakoncz_lekcje(
        p_nr_pkk varchar2,
        data date,
        p_przebieg number
    ) is
        v_kursant kursant_type;
    begin
        select value(k)
        into v_kursant
        from kursanci_tab k
        where k.nr_pkk = p_nr_pkk
        for update;
    
        if v_kursant.historia_jazd is null then
            raise_application_error(-20005, 'Kursant nie posiada żadnych jazd.');
        end if;
    
        for i in 1 .. v_kursant.historia_jazd.count loop
            if trunc(v_kursant.historia_jazd(i).data_jazdy) = trunc(data)
                and v_kursant.historia_jazd(i).czy_odbyta = 'nie' then
    
                v_kursant.historia_jazd(i).zakoncz_jazde(p_przebieg);
    
                declare
                    v_pojazd pojazd_type;
                begin
                    select deref(v_kursant.historia_jazd(i).ref_pojazd)
                    into v_pojazd
                    from dual;
                
                    v_pojazd.aktualizuj_przebieg(p_przebieg);
                
                    update pojazdy_tab p
                    set value(p) = v_pojazd
                    where ref(p) = v_kursant.historia_jazd(i).ref_pojazd;
                end;
    
                update kursanci_tab
                set historia_jazd = v_kursant.historia_jazd
                where nr_pkk = p_nr_pkk;
    
                return;
            end if;
        end loop;
    
        raise_application_error(-20006, 'Nie znaleziono pasującej lekcji do zakończenia.');
    end zakoncz_lekcje;



    
    
    function status_kursu(p_nr_pkk varchar2) return number is
        kursant kursant_type;
    begin
        select value(k) into kursant
        from kursanci_tab k
        where k.nr_pkk = p_nr_pkk;
        
        return kursant.status_kursu();
    exception
        when no_data_found then
            raise_application_error(-20002, '[Błąd] Nie znaleziono kursanta o PKK ' || p_nr_pkk);
    end status_kursu;
    
    
    function wygeneruj_raport(p_nr_pkk varchar2) return sys_refcursor is
        kursor  sys_refcursor;
        kursant kursant_type;
        suma    number;
    begin
        begin
            select value(k) into kursant 
            from kursanci_tab k 
            where k.nr_pkk = p_nr_pkk;
            
            suma := kursant.status_kursu();
            
            if suma < 30 then
                raise_application_error(-20004, '[Info] Kursant posiada ' || suma || 'h. Brakuje jeszcze ' || (30 - suma) || 'h.');
            end if;
            
        exception
            when no_data_found then
                raise_application_error(-20002, '[Błąd] Nie znaleziono kursanta o PKK ' || p_nr_pkk);
        end;
    
        open kursor for
            select 
                k.nr_pkk,
                k.imie, 
                k.nazwisko,
                suma as liczba_godzin,
                t.ref_instruktor.imie || ' ' || t.ref_instruktor.nazwisko as instruktor
            from 
                kursanci_tab k,
                table(k.historia_jazd) t
            where 
                k.nr_pkk = p_nr_pkk
                and t.czy_odbyta = 'tak'
            order by 
                t.data_jazdy desc
            fetch first 1 row only;
    
        return kursor;
        
    end wygeneruj_raport;
   
end szkola_jazdy_pkg;
/