set serveroutput on;

prompt =========================================================================
prompt SCENARIUSZ 1
prompt Rejestracja, planowanie, odbycie jazdy i weryfikacja postępów.
prompt =========================================================================

prompt
prompt =========================================================================
prompt KROK 1: Rejestracja nowego kursanta w systemie
prompt =========================================================================

begin
    kursant_pkg.zarejestruj(
        p_pkk      => '20240202999998888777', 
        p_imie     => 'Kamil', 
        p_nazwisko => 'Stoch'
    );
end;
/

prompt
prompt =========================================================================
prompt KROK 2: Weryfikacja - wyświetlenie listy kursantów
prompt =========================================================================

begin
    kursant_pkg.lista_kursantow;
end;
/

prompt
prompt =========================================================================
prompt KROK 3: Planowanie pierwszej jazdy
prompt =========================================================================

declare
    v_instr_id number;
begin
    select id_instruktora into v_instr_id
    from instruktorzy_tab
    where nazwisko = 'Kwiatkowski';

    kursant_pkg.dodaj_jazde(
        p_pkk          => '20240202999998888777',
        p_nr_rej       => 'EL 4529A',
        p_id_instr     => v_instr_id,
        p_czas_trwania => 2,
        p_data         => sysdate,
        p_godzina      => 10,
        p_typ_lekcji   => 'plac'
    );
    
    dbms_output.put_line('Wywołano procedurę dodania jazdy.');
end;
/

prompt
prompt =========================================================================
prompt KROK 4: Wyświetlenie harmonogramu kursanta
prompt =========================================================================

begin
    kursant_pkg.lista_lekcji('20240202999998888777');
end;
/

prompt
prompt =========================================================================
prompt KROK 5: Realizacja jazdy (instruktor zamyka lekcję)
prompt =========================================================================

begin
kursant_pkg.zakoncz_jazde(
        p_pkk      => '20240202999998888777',
        p_data     => sysdate,
        p_godzina  => 10,
        p_przebieg => 120530
    );
    
    dbms_output.put_line('Zakończono jazdę i zaktualizowano przebieg pojazdu.');
end;
/

prompt
prompt =========================================================================
prompt KROK 6: Sprawdzenie postępów
prompt =========================================================================

declare
    v_ilosc_godzin number;
begin
    v_ilosc_godzin := kursant_pkg.status_kursu('20240202999998888777');
    
    dbms_output.put_line('-------------------------------------------------');
    dbms_output.put_line('Kursant Kamil Stoch wyjeździł łącznie: ' || v_ilosc_godzin || 'h');
    dbms_output.put_line('-------------------------------------------------');
end;
/


prompt
prompt =========================================================================
prompt SCENARIUSZ 2
prompt Pokazanie różnicy między kursantem w trakcie szkolenia a gotowym do egzaminu.
prompt =========================================================================

prompt
prompt =========================================================================
prompt KROK 1: Próba wygenerowania raportu dla kursanta w trakcie szkolenia
prompt =========================================================================

begin
    kursant_pkg.wygeneruj_raport('20240202999998888777');
end;
/

prompt
prompt =========================================================================
prompt KROK 2: Wygenerowanie raportu dla kursanta, który ukończył kurs
prompt =========================================================================

begin
    kursant_pkg.wygeneruj_raport('20230505555556666677');
end;
/

prompt
prompt =========================================================================
prompt SCENARIUSZ 3
prompt Obsługa planowanego serwisu, blokada zapisu oraz awaryjna podmiana auta.
prompt =========================================================================

prompt
prompt =========================================================================
prompt KROK 1: Planowanie serwisu
prompt =========================================================================

begin
    flota_pkg.zaplanuj_serwis(
        p_nr_rej   => 'GD 99999',
        p_data     => sysdate + 5,
        p_opis     => 'Wymiana klocków hamulcowych',
        p_przebieg => 12500
    );
    
    dbms_output.put_line('');
    flota_pkg.lista_serwisow(
        p_nr_rej    => 'GD 99999'
    );
end;
/

prompt
prompt =========================================================================
prompt KROK 2: Próba zapisu kursanta na pojazd w dniu serwisu
prompt =========================================================================

begin
    kursant_pkg.dodaj_jazde(
        p_pkk          => '20240101123456789001', 
        p_nr_rej       => 'GD 99999', 
        p_id_instr     => 1,
        p_czas_trwania => 2, 
        p_data         => sysdate + 5, 
        p_godzina      => 12, 
        p_typ_lekcji   => 'plac'
    );
    
exception
    when others then
        dbms_output.put_line('-------------------------------------------------');
        dbms_output.put_line('Komunikat błędu: ' || sqlerrm);
        dbms_output.put_line('-------------------------------------------------');
end;
/

prompt
prompt =========================================================================
prompt KROK 3: Zapis na sprawne auto
prompt =========================================================================

begin
    kursant_pkg.dodaj_jazde(
        p_pkk          => '20240101123456789001',
        p_nr_rej       => 'WA 88421',
        p_id_instr     => 1,
        p_czas_trwania => 2,
        p_data         => sysdate + 1,
        p_godzina      => 14,
        p_typ_lekcji   => 'miasto'
    );
    
    kursant_pkg.lista_lekcji('20240101123456789001');
end;
/

prompt
prompt =========================================================================
prompt KROK 4: Nagła awaria pojazdu
prompt =========================================================================

begin
    flota_pkg.zmien_status('WA 88421', 'nie');
end;
/

prompt
prompt =========================================================================
prompt KROK 5: Weryfikacja
prompt =========================================================================

begin
    kursant_pkg.lista_lekcji('20240101123456789001');
end;
/

prompt
prompt =========================================================================
prompt SCENARIUSZ 4
prompt Zatrudnienie instruktora, weryfikacja kadry i zapełnienie grafiku.
prompt =========================================================================

prompt
prompt =========================================================================
prompt KROK 1: Dodanie nowego instruktora
prompt =========================================================================

begin
    kadra_pkg.dodaj_instruktora(null, 'Robert', 'Kubica');
end;
/

prompt
prompt =========================================================================
prompt KROK 2: Weryfikacja kadry
prompt =========================================================================

begin
    kadra_pkg.lista_instruktorow;
end;
/

prompt
prompt =========================================================================
prompt KROK 3: Planowanie jazd dla nowego instruktora
prompt =========================================================================

declare
    v_nowy_instr_id number;
begin
    select id_instruktora into v_nowy_instr_id
    from instruktorzy_tab
    where nazwisko = 'Kubica' and imie = 'Robert';

    kursant_pkg.dodaj_jazde(
        p_pkk          => '20240202999998888777',
        p_nr_rej       => 'EL 4529A',
        p_id_instr     => v_nowy_instr_id,
        p_czas_trwania => 2,
        p_data         => sysdate + 6,
        p_godzina      => 8,
        p_typ_lekcji   => 'plac'
    );
    
    kursant_pkg.dodaj_jazde(
        p_pkk          => '20240202999998888777',
        p_nr_rej       => 'GD 99999',
        p_id_instr     => v_nowy_instr_id,
        p_czas_trwania => 3,
        p_data         => sysdate + 10,
        p_godzina      => 14,
        p_typ_lekcji   => 'miasto'
    );
    
    dbms_output.put_line('Zaplanowano dwie jazdy dla instruktora ID: ' || v_nowy_instr_id);
end;
/

prompt
prompt =========================================================================
prompt KROK 4: Generowanie harmonogramu pracy
prompt =========================================================================

declare
    v_nowy_instr_id number;
begin
    select id_instruktora into v_nowy_instr_id
    from instruktorzy_tab
    where nazwisko = 'Kubica';

    kadra_pkg.lista_lekcji(v_nowy_instr_id);
end;
/