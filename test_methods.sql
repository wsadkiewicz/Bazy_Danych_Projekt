-- zarejestruj_kursanta
begin
    szkola_jazdy_pkg.zarejestruj_kursanta('99999999999', 'Anna', 'Marek');
    
    begin
        szkola_jazdy_pkg.zarejestruj_kursanta('99999999999', 'Anna', 'Marek-Druga');
    exception 
        when others then dbms_output.put_line(sqlerrm);
    end;
end;
/

-- sprawdz_serwis
declare
    wynik varchar2(100);
begin
    wynik := szkola_jazdy_pkg.sprawdz_serwis('WAW 10001');
    dbms_output.put_line(wynik);
    
    wynik := szkola_jazdy_pkg.sprawdz_serwis('WAW 99999');
    dbms_output.put_line(wynik);
end;
/

-- zmien_status_pojazdu
declare
    nr_rej   varchar2(20);
    status   varchar2(20);
begin
    szkola_jazdy_pkg.zmien_status_pojazdu('WAW 10001', 'nie');

    select nr_rejestracyjny, dostepny
    into nr_rej, status
    from pojazdy_tab 
    where nr_rejestracyjny = 'WAW 10001';

    dbms_output.put_line('Pojazd: ' || nr_rej || ', Dostępność: ' || status);
    
    szkola_jazdy_pkg.zmien_status_pojazdu('WAW 10001', 'tak');

    select nr_rejestracyjny, dostepny
    into nr_rej, status
    from pojazdy_tab 
    where nr_rejestracyjny = 'WAW 10001';

    dbms_output.put_line('Pojazd: ' || nr_rej || ', Dostępność: ' || status);
end;
/

-- dodaj_instruktora
begin
    szkola_jazdy_pkg.dodaj_instruktora(3, 'Krzysztof', 'Jakubiak');
end;
/

-- wygeneruj_raport
variable wynik refcursor;

begin
    :wynik := szkola_jazdy_pkg.wygeneruj_raport('12345678900');
end;
/

print wynik;


variable wynik refcursor;

begin
    :wynik := szkola_jazdy_pkg.wygeneruj_raport('12345678912');
end;
/

print wynik;

-- status_kursu
declare
    status number;
begin
    status := szkola_jazdy_pkg.status_kursu('12345678900');
    dbms_output.put_line('Status kursu: ' || status);
end;
/