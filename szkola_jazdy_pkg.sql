create or replace package szkola_jazdy_pkg as
    procedure dodaj_instruktora(id number, imie varchar2, nazwisko varchar2);
    procedure dodaj_pojazd(nr_rej varchar2, model varchar2, przebieg number);
    procedure zmien_status_pojazdu(nr_rej varchar2, dostepnosc varchar2);
    function sprawdz_serwis(nr_rej varchar2) return varchar2;
    procedure zarejestruj_kursanta(pkk varchar2, imie varchar2, nazwisko varchar2);
    procedure wyrejestruj_kursanta(pkk varchar2);
    
    procedure dodaj_jazde(pkk varchar2, nr_rej varchar2, id_instr number, godziny number, typ_lekcji varchar2);
    procedure zakoncz_lekcje(pkk varchar2, data date, przebieg number);
    
    function status_kursu(pkk varchar2) return varchar2;
    procedure wygeneruj_raport(pkk varchar2);
end szkola_jazdy_pkg;
/

create or replace package body szkola_jazdy_pkg as
    procedure dodaj_instruktora(id number, imie varchar2, nazwisko varchar2) is
    begin
        null;
    end dodaj_instruktora;
    
     procedure dodaj_pojazd(nr_rej varchar2, model varchar2, przebieg number) is
     begin
        null;
    end dodaj_pojazd;
    
    procedure zmien_status_pojazdu(nr_rej varchar2, dostepnosc varchar2) is
    begin
        null;
    end zmien_status_pojazdu;
    
    function sprawdz_serwis(nr_rej varchar2) return varchar2 is
    begin
       return null;
    end sprawdz_serwis;
    
    procedure zarejestruj_kursanta(pkk varchar2, imie varchar2, nazwisko varchar2) is
    begin
        null;
    end zarejestruj_kursanta;
    
    procedure wyrejestruj_kursanta(pkk varchar2) is
    begin
        null;
    end wyrejestruj_kursanta;
    
    procedure dodaj_jazde(pkk varchar2, nr_rej varchar2, id_instr number, godziny number, typ_lekcji varchar2) is
    begin
        null;
    end dodaj_jazde;
    
    procedure zakoncz_lekcje(pkk varchar2, data date, przebieg number) is
    begin
        null;
    end zakoncz_lekcje;
    
    function status_kursu(pkk varchar2) return varchar2 is
    begin
       return null;
    end status_kursu;
    
    procedure wygeneruj_raport(pkk varchar2) is
    begin
        null;
    end wygeneruj_raport;
   
end szkola_jazdy_pkg;
/