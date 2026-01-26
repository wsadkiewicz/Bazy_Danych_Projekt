-- =====================================================
-- data_tests.sql
-- Przygotowanie danych testowych do testów systemu
-- =====================================================

set serveroutput on
prompt === RESET DANYCH ===
delete from kursanci_tab;
delete from pojazdy_tab;
delete from instruktorzy_tab;
commit;

-- =====================================================
-- INSTRUKTORZY
-- =====================================================
prompt === Dodawanie instruktorów ===
begin
    kadra_pkg.dodaj_instruktora(1, 'Adam', 'Nowicki');
    kadra_pkg.dodaj_instruktora(2, 'Piotr', 'Zieliński');
    kadra_pkg.dodaj_instruktora(3, 'Marek', 'Lewandowski');
end;
/

-- =====================================================
-- POJAZDY
-- =====================================================
prompt === Dodawanie pojazdów ===
begin
    flota_pkg.dodaj_pojazd('KR1000A', 'Toyota Yaris', 10000);
    flota_pkg.dodaj_pojazd('KR2000B', 'Hyundai i20', 20000);
    flota_pkg.dodaj_pojazd('KR3000C', 'Skoda Fabia', 5000);
end;
/

-- =====================================================
-- KURSANCI
-- =====================================================
prompt === Rejestracja kursantów ===
begin
    kursant_pkg.zarejestruj('PKK001', 'Jan', 'Kowalski');
    kursant_pkg.zarejestruj('PKK002', 'Anna', 'Nowak');
    kursant_pkg.zarejestruj('PKK003', 'Tomasz', 'Wiśniewski');
end;
/

prompt === Dane testowe gotowe ===