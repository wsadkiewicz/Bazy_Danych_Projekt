-----------------------------------------------------------------
-- Pakiet do obsługi kursantów
-----------------------------------------------------------------
create or replace package kursant_pkg as
    procedure   zarejestruj(p_pkk varchar2, p_imie varchar2, p_nazwisko varchar2);
    
    procedure   wyrejestruj(p_pkk varchar2);
    
    procedure   dodaj_jazde(p_pkk varchar2, p_nr_rej varchar2, p_id_instr number, p_czas_trwania number, p_data date, p_godzina number, p_typ_lekcji varchar2);
    
    procedure   zakoncz_jazde(p_pkk varchar2, p_data date, p_godzina number, p_przebieg number);
    
    procedure   lista_lekcji(p_pkk varchar2);
    
    function    status_kursu(p_pkk varchar2) return number;
    
    procedure   wygeneruj_raport(p_pkk varchar2);
end kursant_pkg;
/

create or replace package body kursant_pkg as
    procedure zarejestruj(p_pkk varchar2, p_imie varchar2, p_nazwisko varchar2) is
    begin
        insert into kursanci_tab values(kursant_type(p_pkk, p_imie, p_nazwisko, lista_lekcji_type()));
        
        commit;
        dbms_output.put_line('Zarejestrowano kursanta: ' || p_imie || ' ' || p_nazwisko);
        
    exception
        when dup_val_on_index then
            raise_application_error(-20001, '[Błąd] Kursant o PKK ' || p_pkk || ' już istnieje');
    end zarejestruj;
    
    
    procedure wyrejestruj(p_pkk varchar2) is
    begin
        delete from kursanci_tab
        where nr_pkk = p_pkk;
    
        if sql%rowcount = 0 then
            raise_application_error(-20002, '[Błąd] Nie znaleziono kursanta o numerze PKK ' || p_pkk);
        end if;
    end wyrejestruj;
    
    
    procedure dodaj_jazde(p_pkk varchar2, p_nr_rej varchar2, p_id_instr number, p_czas_trwania number, p_data date, p_godzina number, p_typ_lekcji varchar2)  is
        v_instr_ref         ref instruktor_type;
        v_pojazd_ref        ref pojazd_type;
        v_godzina_start     number;
        v_godzina_koniec    number;
        v_data_start        date;
    begin
        if p_czas_trwania < 1 or p_czas_trwania > 4 then
            raise_application_error(-20100, '[Błąd] Lekcja musi trwać od 1 do 4 godzin');
        end if;
    
        if p_godzina < 8 or p_godzina >= 19 then
            raise_application_error(-20101, '[Błąd] Godzina rozpoczęcia musi być w przedziale 08:00 – 19:00');
        end if;
    
        v_godzina_koniec := p_godzina + p_czas_trwania;
    
        if v_godzina_koniec > 20 then
            raise_application_error(-20102, '[Błąd] Lekcja musi zakończyć się najpóźniej o 20:00');
        end if;
    
        v_data_start := trunc(p_data) + (p_godzina / 24);
    
        select ref(i)
        into v_ref_instr
        from instruktorzy_tab i
        where i.id_instruktora = p_id_instr;
    
        select ref(p)
        into v_ref_pojazd
        from pojazdy_tab p
        where p.nr_rejestracyjny = p_nr_rej and p.dostepny = 'tak';
    
        update kursanci_tab k
        set k.historia_jazd =
            case
                when k.historia_jazd is null then
                    lista_lekcji_type(
                        lekcja_type(
                            v_data_start,
                            p_czas_trwania,
                            v_instr_ref,
                            v_pojazd_ref,
                            null,
                            p_typ_lekcji,
                            'nie'
                        )
                    )
                else
                    k.historia_jazd multiset union all
                    lista_lekcji_type(
                        lekcja_type(
                            v_data_start,
                            p_czas_trwania,
                            v_instr_ref,
                            v_pojazd_ref,
                            null,
                            p_typ_lekcji,
                            'nie'
                        )
                    )
            end
        where k.nr_pkk = p_pkk;
    
        if sql%rowcount = 0 then
            raise_application_error(-20003, '[Błąd] Nie znaleziono kursanta o PKK ' || p_pkk);
        end if;
    end dodaj_jazde;
    
    
    procedure zakoncz_jazde(p_pkk varchar2, p_data date, p_godzina number, p_przebieg number) is
        v_kursant kursant_type;
    begin
        select value(k)
        into v_kursant
        from kursanci_tab k
        where k.nr_pkk = p_pkk
        for update;
    
        if v_kursant.historia_jazd is null then
            raise_application_error(-20005, '[Błąd] Kursant nie posiada żadnych jazd.');
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
                where nr_pkk = p_pkk;
    
                return;
            end if;
        end loop;
    
        raise_application_error(-20006, '[Błąd] Nie znaleziono pasującej lekcji do zakończenia.');
    end zakoncz_jazde;
    
    
    procedure lista_lekcji(p_pkk varchar2) is
    begin
        null;
    end;
    
    
    function status_kursu(p_pkk varchar2) return number  is
        kursant kursant_type;
    begin
        select value(k) into kursant
        from kursanci_tab k
        where k.nr_pkk = p_pkk;
        
        return kursant.status_kursu();
    exception
        when no_data_found then
            raise_application_error(-20002, '[Błąd] Nie znaleziono kursanta o PKK ' || p_pkk);
    end status_kursu;
    
    
    procedure wygeneruj_raport(p_pkk varchar2) is 
    v_kursant       kursant_type;
    v_suma          number;
    v_instruktor    varchar2(100);
    v_data          date;
    
begin
    begin
        select value(k) into v_kursant 
        from kursanci_tab k 
        where k.nr_pkk = p_pkk;
        
        v_suma := v_kursant.status_kursu();
        
    exception
        when no_data_found then
            raise_application_error(-20002, '[Błąd] Nie znaleziono kursanta o PKK ' || p_pkk);
            return;
    end;

    if v_suma < 30 then
        dbms_output.put_line('-----------------------------------------------');
        dbms_output.put_line('Kursant nie posiada wymaganej liczby godzin');
        dbms_output.put_line('-----------------------------------------------');
        dbms_output.put_line(' Kursant: ' || v_kursant.imie || ' ' || v_kursant.nazwisko);
        dbms_output.put_line('-----------------------------------------------');
        dbms_output.put_line(' Wyjeżdżone godziny: ' || v_suma || 'h');
        dbms_output.put_line(' Brakuje:            ' || (30 - v_suma) || 'h');
        return;
    end if;

    begin
        select 
            t.ref_instruktor.imie || ' ' || t.ref_instruktor.nazwisko,
            t.data_jazdy
        into 
            v_instruktor, v_data
        from 
            TABLE(v_kursant.historia_jazd) t
        where 
            t.czy_odbyta = 'tak'
        order by 
            t.data_jazdy desc
        fetch first 1 row only;
        
    exception
        when no_data_found then
           raise_application_error(-20002, '[Błąd] Nie znaleziono wymaganych danych do rapotu');
    end;

    dbms_output.put_line('');
    dbms_output.put_line('##########################################');
    dbms_output.put_line('#        RAPORT UKOŃCZENIA KURSU         #');
    dbms_output.put_line('##########################################');
    dbms_output.put_line('');
    dbms_output.put_line(' DANE KURSANTA:');
    dbms_output.put_line(' ' || rpad('Imię i Nazwisko:', 20) || v_kursant.imie || ' ' || v_kursant.nazwisko);
    dbms_output.put_line(' ' || rpad('Numer PKK:', 20) || v_kursant.nr_pkk);
    dbms_output.put_line('------------------------------------------');
    dbms_output.put_line(' PODSUMOWANIE:');
    dbms_output.put_line(' ' || rpad('Suma godzin:', 20) || v_suma);
    dbms_output.put_line(' ' || rpad('Status:', 20) || 'POZYTYWNY');
    dbms_output.put_line('------------------------------------------');
    dbms_output.put_line(' ' || rpad('Data:', 20) || to_char(v_data, 'YYYY-MM-DD'));
    dbms_output.put_line(' ' || rpad('Instruktor:', 20) || v_instruktor);
       
    end wygeneruj_raport;
end kursant_pkg;
/

-----------------------------------------------------------------
-- Pakiet do obsługi floty
-----------------------------------------------------------------
create or replace package flota_pkg as
    procedure   dodaj_pojazd(p_nr_rej varchar2, p_model varchar2, p_przebieg number);
    
    function    sprawdz_serwis(p_nr_rej varchar2) return varchar2;
    
    procedure   zmien_status(p_nr_rej varchar2, p_dostepnosc varchar2);
    
    procedure   usun_pojazd(p_nr_rej varchar2);
end flota_pkg;
/

create or replace package body flota_pkg as
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
        
        commit;
        dbms_output.put_line('Dodano pojazd: ' || p_nr_rej || ' ' || p_model);
    exception
        when dup_val_on_index then
            raise_application_error(-20001, '[Błąd] Pojazd o numerze rejestracyjnym ' || p_nr_rej || ' już istnieje');
    end dodaj_pojazd;
    
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
             return 'Pojazd wymaga serwisu';
        else
             return 'Pojazd nie wymaga serwisu';
        end if;
        
    exception
        when no_data_found then
            raise_application_error(-20002, '[Błąd] Nie znaleziono pojazdu o numerze rejestracyjnym ' || p_nr_rej);
    end sprawdz_serwis;
    
    procedure zmien_status(p_nr_rej varchar2, p_dostepnosc varchar2) is
    begin
        if p_dostepnosc not in ('tak', 'nie') then
             raise_application_error(-20003, '[Błąd] Status musi być "tak" lub "nie"');
        end if;

        update pojazdy_tab 
        set dostepny = p_dostepnosc 
        where nr_rejestracyjny = p_nr_rej;
        
        if sql%rowcount = 0 then
            raise_application_error(-20002, '[Błąd] Nie znaleziono pojazdu o numerze rejestracyjnym ' || p_nr_rej);
        end if;
        
        commit;
        dbms_output.put_line('Zmieniono status pojazdu ' || p_nr_rej || ' na: ' || p_dostepnosc);
    end;
    
    procedure usun_pojazd(p_nr_rej varchar2) is
    begin
        delete pojazdy_tab
        where nr_rejestracyjny = p_nr_rej;
    
        if sql%rowcount = 0 then
            raise_application_error(-20002, '[Błąd] Nie znaleziono pojazdu o numerze rejestracyjnym ' || p_nr_rej);
        end if;
    end;
end flota_pkg;
/

-----------------------------------------------------------------
-- Pakiet do obsługi kadry
-----------------------------------------------------------------
create or replace package kadra_pkg as
    procedure   dodaj_instruktora(p_id number, p_imie varchar2, p_nazwisko varchar2);
    
    procedure   usun_instruktora(p_id number);
    
    procedure   lista_lekcji(p_id varchar2);
end kadra_pkg;
/

create or replace package body kadra_pkg as
    procedure dodaj_instruktora(p_imie varchar2, p_nazwisko varchar2) is
    begin
        insert into instruktorzy_tab 
        values (instruktor_type(p_imie, p_nazwisko));
        
        commit;
        dbms_output.put_line('Dodano instruktora: ' || p_imie || ' ' || p_nazwisko);
    end dodaj_instruktora;
    
    procedure usun_instruktora(p_id number) is
    begin
        delete from instruktorzy_tab
        where id_instruktora = p_id;
    
        if sql%rowcount = 0 then
            raise_application_error(-20002, '[Błąd] Nie znaleziono instruktora o ID ' || p_id);
        end if;
    end usun_instruktora;
    
    procedure lista_lekcji(p_id varchar2) is
        v_instr_ref ref instruktor_type;
        v_imie      instruktorzy_tab.imie%type;
        v_nazwisko  instruktorzy_tab.nazwisko%type;
    begin
        select ref(i), i.imie, i.nazwisko
        into v_instr_ref, v_imie, v_nazwisko
        from instruktorzy_tab i
        where i.id_instruktora = p_id;
    
        dbms_output.put_line(
            'Zaplanowane lekcje instruktora: '
            || v_imie || ' ' || v_nazwisko
        );
        dbms_output.put_line('--------------------------------------------');
    
        for r in (
            select
                k.nr_pkk,
                l.data_jazdy,
                l.godzina_jazdy,
                l.czas_trwania,
                l.typ_lekcji,
                p.nr_rejestracyjny
            from kursanci_tab k,
                 table(k.historia_jazd) l,
                 pojazdy_tab p
            where l.ref_instruktor = v_ref_instr
              and l.czy_odbyta = 'nie'
              and l.ref_pojazd = ref(p)
            order by l.data_jazdy
        ) loop
            dbms_output.put_line(
                'PKK: ' || r.nr_pkk ||
                ' | Data: ' || to_char(r.data_jazdy, 'yyyy-mm-dd') || ' ' || r.godzina_jazdy || ':00' ||
                ' | Czas: ' || r.czas_trwania || 'h' ||
                ' | Typ: ' || r.typ_lekcji ||
                ' | Auto: ' || r.nr_rejestracyjny
            );
        end loop;
    
    exception
        when no_data_found then
            raise_application_error(-20200, 'Nie znaleziono instruktora o ID ' || p_id);
    end lista_lekcji; 
end kadra_pkg;
/