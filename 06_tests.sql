-- =====================================================
-- tests.sql – KOMPLETNY ZESTAW ~30 TESTÓW
-- =====================================================

set serveroutput on
@05_tests_data.sql

-- =====================================================
-- 1–3: LISTY PODSTAWOWE
-- =====================================================

-- TEST 1
begin
    kadra_pkg.lista_instruktorow;
end;
/

-- TEST 2
begin
    flota_pkg.lista_pojazdow;
end;
/

-- TEST 3
begin
    kursant_pkg.lista_kursantow;
end;
/

-- =====================================================
-- 4–7: REJESTRACJA KURSANTÓW
-- =====================================================

-- TEST 4 – duplikat PKK
begin
    kursant_pkg.zarejestruj('PKK001','X','Y');
exception
    when others then
        dbms_output.put_line('OK 4: ' || sqlerrm);
end;
/

-- TEST 5 – NULL PKK
begin
    kursant_pkg.zarejestruj(null,'X','Y');
exception
    when others then
        dbms_output.put_line('OK 5: ' || sqlerrm);
end;
/

-- TEST 6 – poprawny nowy kursant
begin
    kursant_pkg.zarejestruj('PKK004','A','B');
end;
/

-- TEST 7 – wyrejestrowanie nieistniejącego
begin
    kursant_pkg.wyrejestruj('XXX');
exception
    when others then
        dbms_output.put_line('OK 7: ' || sqlerrm);
end;
/

-- =====================================================
-- 8–15: DODAWANIE JAZD
-- =====================================================

-- TEST 8 – poprawna jazda miasto
begin
    kursant_pkg.dodaj_jazde(
        'PKK001','KR1000A',1,2,trunc(sysdate)+1,10,'miasto'
    );
end;
/

-- TEST 9 – poprawna jazda plac
begin
    kursant_pkg.dodaj_jazde(
        'PKK001','KR2000B',2,1,trunc(sysdate)+2,12,'plac'
    );
end;
/

-- TEST 10 – zły typ lekcji
begin
    kursant_pkg.dodaj_jazde(
        'PKK001','KR1000A',1,1,trunc(sysdate)+3,10,'autostrada'
    );
exception
    when others then
        dbms_output.put_line('OK 10: ' || sqlerrm);
end;
/

-- TEST 11 – czas < 1h
begin
    kursant_pkg.dodaj_jazde(
        'PKK001','KR1000A',1,0,trunc(sysdate)+3,10,'miasto'
    );
exception
    when others then
        dbms_output.put_line('OK 11: ' || sqlerrm);
end;
/

-- TEST 12 – czas > 4h
begin
    kursant_pkg.dodaj_jazde(
        'PKK001','KR1000A',1,5,trunc(sysdate)+3,10,'miasto'
    );
exception
    when others then
        dbms_output.put_line('OK 12: ' || sqlerrm);
end;
/

-- TEST 13 – godzina < 8
begin
    kursant_pkg.dodaj_jazde(
        'PKK001','KR1000A',1,1,trunc(sysdate)+3,6,'miasto'
    );
exception
    when others then
        dbms_output.put_line('OK 13: ' || sqlerrm);
end;
/

-- TEST 14 – koniec po 20
begin
    kursant_pkg.dodaj_jazde(
        'PKK001','KR1000A',1,3,trunc(sysdate)+3,18,'miasto'
    );
exception
    when others then
        dbms_output.put_line('OK 14: ' || sqlerrm);
end;
/

-- TEST 15 – brak kursanta
begin
    kursant_pkg.dodaj_jazde(
        'XXX','KR1000A',1,1,trunc(sysdate)+3,10,'miasto'
    );
exception
    when others then
        dbms_output.put_line('OK 15: ' || sqlerrm);
end;
/

-- =====================================================
-- 16–18: LISTY LEKCJI
-- =====================================================

-- TEST 16
begin
    kursant_pkg.lista_lekcji('PKK001');
end;
/

-- TEST 17 – brak kursanta
begin
    kursant_pkg.lista_lekcji('XXX');
exception
    when others then
        dbms_output.put_line('OK 17: ' || sqlerrm);
end;
/

-- TEST 18 – kursant bez jazd
begin
    kursant_pkg.lista_lekcji('PKK002');
end;
/

-- =====================================================
-- 19–21: ZAKOŃCZENIE JAZDY
-- =====================================================

-- TEST 19 – poprawne zakończenie
begin
    kursant_pkg.zakoncz_jazde(
        'PKK001',trunc(sysdate)+1,10,40
    );
end;
/

-- TEST 20 – brak jazdy
begin
    kursant_pkg.zakoncz_jazde(
        'PKK002',trunc(sysdate),10,10
    );
exception
    when others then
        dbms_output.put_line('OK 20: ' || sqlerrm);
end;
/

-- TEST 21 – zła data
begin
    kursant_pkg.zakoncz_jazde(
        'PKK001',trunc(sysdate)+10,10,10
    );
exception
    when others then
        dbms_output.put_line('OK 21: ' || sqlerrm);
end;
/

-- =====================================================
-- 22–24: STATUS I RAPORT
-- =====================================================

-- TEST 22
declare
    v number;
begin
    v := kursant_pkg.status_kursu('PKK001');
    dbms_output.put_line(v);
end;
/

-- TEST 23 – brak kursanta
declare
    v number;
begin
    v := kursant_pkg.status_kursu('XXX');
exception
    when others then
        dbms_output.put_line('OK 23: ' || sqlerrm);
end;
/

-- TEST 24 – raport (za mało godzin)
begin
    kursant_pkg.wygeneruj_raport('PKK001');
end;
/

-- =====================================================
-- 25–28: FLOTA
-- =====================================================

-- TEST 25 – serwis
begin
    flota_pkg.zaplanuj_serwis(
        'KR3000C',trunc(sysdate)+1,'Przeglad',30000
    );
end;
/

-- TEST 26 – sprawdz serwis
declare
    v varchar2(50);
begin
    v := flota_pkg.sprawdz_serwis('KR3000C');
    dbms_output.put_line(v);
end;
/

-- TEST 27 – zmiana statusu
begin
    flota_pkg.zmien_status('KR1000A','nie');
end;
/

-- TEST 28 – zły status
begin
    flota_pkg.zmien_status('KR1000A','xxx');
exception
    when others then
        dbms_output.put_line('OK 28: ' || sqlerrm);
end;
/

-- =====================================================
-- 29–30: KADRA
-- =====================================================

-- TEST 29 – usunięcie instruktora z lekcjami
begin
    kadra_pkg.usun_instruktora(2);
exception
    when others then
        dbms_output.put_line('OK 29: ' || sqlerrm);
end;
/

-- TEST 30 – lista lekcji instruktora
begin
    kadra_pkg.lista_lekcji(1);
end;
/

-- =====================================================
-- 31–36: POJAZD W SERWISIE A DODANIE LEKCJI
-- =====================================================

-- TEST 31 – zaplanowanie serwisu pojazdu (PRZYGOTOWANIE)
begin
    flota_pkg.zaplanuj_serwis(
        'KR2000B',
        trunc(sysdate) + 5,
        'Przegląd okresowy',
        35000
    );
end;
/

-- TEST 32 – próba dodania lekcji w DNIU SERWISU (BŁĄD)
begin
    kursant_pkg.dodaj_jazde(
        'PKK001',
        'KR2000B',
        2,
        1,
        trunc(sysdate) + 5, -- ten sam dzień co serwis
        10,
        'miasto'
    );
exception
    when others then
        dbms_output.put_line('OK 32:' || sqlerrm);
end;
/

-- TEST 33 – dodanie lekcji DZIEŃ PO SERWISIE (OK)
begin
    kursant_pkg.dodaj_jazde(
        'PKK001',
        'KR2000B',
        2,
        1,
        trunc(sysdate) + 6, -- dzień po serwisie
        10,
        'plac'
    );
end;
/

-- TEST 34 – inny pojazd w dniu serwisu (OK)
begin
    kursant_pkg.dodaj_jazde(
        'PKK001',
        'KR3000C', -- inny pojazd
        1,
        1,
        trunc(sysdate) + 5,
        12,
        'miasto'
    );
end;
/

-- TEST 35 – drugi wpis serwisowy w tym samym dniu (EDGE CASE)
begin
    flota_pkg.zaplanuj_serwis(
        'KR2000B',
        trunc(sysdate) + 5,
        'Dodatkowa kontrola',
        36000
    );
end;
/

-- TEST 36 – ponowna próba dodania lekcji (NADAL BŁĄD)
begin
    kursant_pkg.dodaj_jazde(
        'PKK001',
        'KR2000B',
        2,
        1,
        trunc(sysdate) + 5,
        14,
        'miasto'
    );
exception
    when others then
        dbms_output.put_line('OK 36: ' || sqlerrm);
end;
/

prompt === KONIEC TESTÓW SERWISU POJAZDU ===

-- TEST 37 – ustawienie pojazdu jako niedostępny
begin
    flota_pkg.zmien_status(
        'KR1000A',
        'nie'
    );
end;
/

-- TEST 38 – dodanie jazdy dla pojazdu niedostępnego (BŁĄD)
begin
    kursant_pkg.dodaj_jazde(
        'PKK001',
        'KR1000A',  -- pojazd niedostępny
        1,
        1,
        trunc(sysdate) + 7,
        10,
        'miasto'
    );
exception
    when others then
        dbms_output.put_line('OK 38: ' || sqlerrm);
end;
/

-- TEST 39 – przywrócenie dostępności pojazdu
begin
    flota_pkg.zmien_status(
        'KR1000A',
        'tak'
    );
end;
/


-- TEST 40 – dodanie jazdy po przywróceniu dostępności (OK)
begin
    kursant_pkg.dodaj_jazde(
        'PKK001',
        'KR1000A',
        1,
        1,
        trunc(sysdate) + 7,
        12,
        'plac'
    );
end;
/

-- TEST 41 – dodanie jazdy z nieistniejącym instruktorem
begin
    kursant_pkg.dodaj_jazde(
        'PKK001','KR1000A',999,1,trunc(sysdate)+8,10,'miasto'
    );
exception
    when others then
        dbms_output.put_line('OK 41: ' || sqlerrm);
end;
/

-- TEST 42 – dodanie jazdy z nieistniejącym pojazdem
begin
    kursant_pkg.dodaj_jazde(
        'PKK001','XXX999',1,1,trunc(sysdate)+8,10,'miasto'
    );
exception
    when others then
        dbms_output.put_line('OK 42:' || sqlerrm);
end;
/

-- TEST 43 – godzina rozpoczęcia = 20 (BŁĄD)
begin
    kursant_pkg.dodaj_jazde(
        'PKK001','KR1000A',1,1,trunc(sysdate)+9,20,'miasto'
    );
exception
    when others then
        dbms_output.put_line('OK 43: ' || sqlerrm);
end;
/

-- TEST 44 – lekcja kończąca się dokładnie o 20 (OK)
begin
    kursant_pkg.dodaj_jazde(
        'PKK001','KR1000A',1,2,trunc(sysdate)+9,18,'plac'
    );
end;
/

-- TEST 45 – ponowne zakończenie tej samej jazdy
begin
    kursant_pkg.zakoncz_jazde(
        'PKK001',trunc(sysdate)+9,18,10
    );
exception
    when others then
        dbms_output.put_line('OK 45: ' || sqlerrm);
end;
/

-- TEST 46 – wyrejestrowanie kursanta z historią jazd
begin
    kursant_pkg.wyrejestruj('PKK001');
    dbms_output.put_line('UWAGA 46: kursant usunięty mimo jazd');
exception
    when others then
        dbms_output.put_line('OK 46: ' || sqlerrm);
end;
/

-- TEST 47 – usunięcie nieistniejącego pojazdu
begin
    flota_pkg.usun_pojazd('XXX999');
exception
    when others then
        dbms_output.put_line('OK 47: ' || sqlerrm);
end;
/

-- TEST 48 – poprawne usunięcie instruktora bez lekcji
begin
    kadra_pkg.usun_instruktora(3);
end;
/

-- TEST 49 – test poprawnego wygenerowania raportu
-- Dodanie jazd do uzyskania wymaganych 30 godzin
begin
    kursant_pkg.dodaj_jazde('PKK003','KR1000A',1,4,trunc(sysdate)+20,8,'miasto');
    kursant_pkg.dodaj_jazde('PKK003','KR1000A',1,4,trunc(sysdate)+21,8,'miasto');
    kursant_pkg.dodaj_jazde('PKK003','KR1000A',1,4,trunc(sysdate)+22,8,'plac');
    kursant_pkg.dodaj_jazde('PKK003','KR1000A',1,4,trunc(sysdate)+23,8,'plac');
    kursant_pkg.dodaj_jazde('PKK003','KR1000A',1,4,trunc(sysdate)+24,8,'miasto');
    kursant_pkg.dodaj_jazde('PKK003','KR1000A',1,4,trunc(sysdate)+25,8,'miasto');
    kursant_pkg.dodaj_jazde('PKK003','KR1000A',1,4,trunc(sysdate)+26,8,'plac');
    kursant_pkg.dodaj_jazde('PKK003','KR1000A',1,4,trunc(sysdate)+27,8,'miasto');
end;
/

-- Zakończenie jazd (uznanie godzin)
begin
    kursant_pkg.zakoncz_jazde('PKK003', trunc(sysdate)+20, 8, 40);
    kursant_pkg.zakoncz_jazde('PKK003', trunc(sysdate)+21, 8, 40);
    kursant_pkg.zakoncz_jazde('PKK003', trunc(sysdate)+22, 8, 40);
    kursant_pkg.zakoncz_jazde('PKK003', trunc(sysdate)+23, 8, 40);
    kursant_pkg.zakoncz_jazde('PKK003', trunc(sysdate)+24, 8, 40);
    kursant_pkg.zakoncz_jazde('PKK003', trunc(sysdate)+25, 8, 40);
    kursant_pkg.zakoncz_jazde('PKK003', trunc(sysdate)+26, 8, 40);
    kursant_pkg.zakoncz_jazde('PKK003', trunc(sysdate)+27, 8, 40);
end;
/

-- Poprawne wygenerowanie raportu ukończenia kursu
begin
    kursant_pkg.wygeneruj_raport('PKK003');
end;
/

-- TEST 50 – próba dodania jazdy, gdy instruktor ma już lekcję w tym terminie
begin
kursant_pkg.dodaj_jazde(
        'PKK003','KR1000A',1,2,trunc(sysdate)+9,18,'plac'
    );
end;
/

begin
    kursant_pkg.dodaj_jazde(
        'PKK002','KR1000A',1,2,trunc(sysdate)+9,18,'plac'
    );
exception
    when others then
        dbms_output.put_line('OK 50: ' || sqlerrm);
end;

prompt === KONIEC  TESTÓW ===
