-----------------------------------------------------------------
-- Pakiet do obsługi kursantów
-----------------------------------------------------------------
create or replace package kursant_pkg as
    procedure   zarejestruj(p_pkk varchar2, p_imie varchar2, p_nazwisko varchar2);
    
    procedure   wyrejestruj(p_pkk varchar2);
    
    procedure   dodaj_jazde(p_nr_pkk varchar2, p_nr_rej varchar2, p_id_instr number, p_czas_trwania number, p_data date, p_godzina number, p_typ_lekcji varchar2);
    
    procedure   zakoncz_jazde(p_nr_pkk varchar2, p_data date, p_godzina number, p_przebieg number);
    
    procedure   lista_lekcji(p_pkk varchar2);
    
    function    status_kursu(p_pkk varchar2) return number;
    
    procedure   wygeneruj_raport(p_pkk varchar2);
end kursant_pkg;
/

create or replace package body kursant_pkg as
    procedure zarejestruj(p_pkk varchar2, p_imie varchar2, p_nazwisko varchar2) is
    begin
        null;
    end;
    
    procedure wyrejestruj(p_pkk varchar2) is
    begin
        null;
    end;
    
    procedure dodaj_jazde(p_nr_pkk varchar2, p_nr_rej varchar2, p_id_instr number, p_czas_trwania number, p_data date, p_godzina number, p_typ_lekcji varchar2) is
    begin
        null;
    end;
    
    procedure zakoncz_jazde(p_nr_pkk varchar2, p_data date, p_godzina number, p_przebieg number) is
    begin
        null;
    end;
    
    procedure lista_lekcji(p_pkk varchar2) is
    begin
        null;
    end;
    
    function status_kursu(p_pkk varchar2) return number is
    begin
        return null;
    end;
    
    procedure wygeneruj_raport(p_pkk varchar2) is
    begin
        null;
    end;
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
        null;
    end;
    
    function sprawdz_serwis(p_nr_rej varchar2) return varchar2 is
    begin
        return null;
    end;
    
    procedure zmien_status(p_nr_rej varchar2, p_dostepnosc varchar2) is
    begin
        null;
    end;
    
    procedure usun_pojazd(p_nr_rej varchar2) is
    begin
        null;
    end;
end flota_pkg;
/

-----------------------------------------------------------------
-- Pakiet do obsługi kadry
-----------------------------------------------------------------
create or replace package kadra_pkg as
    procedure   dodaj_instruktora(p_id number, p_imie varchar2, p_nazwisko varchar2);
    
    procedure   usun_instruktora(p_id number);
    
    procedure   lista_lekcji(p_pkk varchar2);
end kadra_pkg;
/

create or replace package body kadra_pkg as
    procedure dodaj_instruktora(p_id number, p_imie varchar2, p_nazwisko varchar2) is
    begin
        null;
    end;
    
    procedure usun_instruktora(p_id number) is
    begin
        null;
    end;
    
    procedure lista_lekcji(p_pkk varchar2) is
    begin
        null;
    end;
end kadra_pkg;
/