create or replace package szkola_jazdy_pkg as
    procedure dodaj_instruktora(p_id number, p_imie varchar2, p_nazwisko varchar2);
    procedure dodaj_pojazd(p_nr_rej varchar2, p_model varchar2, p_przebieg number);
    procedure zmien_status_pojazdu(p_nr_rej varchar2, p_dostepnosc varchar2);
    function sprawdz_serwis(p_nr_rej varchar2) return varchar2;
    procedure zarejestruj_kursanta(p_nr_pkk varchar2, p_imie varchar2, p_nazwisko varchar2);
    procedure wyrejestruj_kursanta(p_nr_pkk varchar2);
    
    procedure dodaj_jazde(p_nr_pkk varchar2, p_nr_rej varchar2, p_id_instr number, p_godziny number, p_typ_lekcji varchar2);
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
        null;
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
        null;
    end wyrejestruj_kursanta;
    
    
    procedure dodaj_jazde(p_nr_pkk varchar2, p_nr_rej varchar2, p_id_instr number, p_godziny number, p_typ_lekcji varchar2) is
    begin
        null;
    end dodaj_jazde;
    
    
    procedure zakoncz_lekcje(p_nr_pkk varchar2, data date, p_przebieg number) is
    begin
        null;
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