drop type kursant_type;
drop type lista_lekcji_type;
drop type lekcja_type;

drop type instruktor_type;

drop type pojazd_type;
drop type lista_serwisow_type;
drop type serwis_type;


create or replace type serwis_type as object (
    data_serwisu date,
    opis         varchar2(200),
    przebieg     number
);
/

create or replace type lista_serwisow_type as table of serwis_type;
/


create or replace type pojazd_type as object (
    nr_rejestracyjny    varchar2(15),
    model               varchar2(50),
    przebieg            number,
    dostepny            varchar2(3),    -- tak/nie
    historia_serwisow   lista_serwisow_type,

    member procedure    aktualizuj_przebieg(nowy_przebieg number)
);
/

create or replace type body pojazd_type as
    member procedure aktualizuj_przebieg(nowy_przebieg number) is
    begin
        if nowy_przebieg > self.przebieg then
            self.przebieg := nowy_przebieg;
        end if;
    end;
end;
/


create or replace type instruktor_type as object (
    id_instruktora   number,
    imie             varchar2(50),
    nazwisko         varchar2(50)
);
/


create or replace type lekcja_type as object (
    data_jazdy          date,
    godzina_jazdy       number,
    czas_trwania        number,
    ref_instruktor      ref instruktor_type,
    ref_pojazd          ref pojazd_type,
    przebieg_auta       number,
    typ_lekcji          varchar2(20),    -- plac/miasto
    czy_odbyta          varchar2(3),     -- tak/nie

    member procedure    zakoncz_jazde(nowy_przebieg number),
    member function     informacje return varchar2
);
/

create or replace type body lekcja_type as
    member procedure zakoncz_jazde(nowy_przebieg number) is
    begin
        self.czy_odbyta := 'tak';
        self.przebieg_auta := nowy_przebieg;
    end;
    
    member function informacje return varchar2 is
        v_pojazd_ref  pojazd_type;
        v_nr_rej      varchar2(15);
        v_tekst       varchar2(400);
    begin
        if self.ref_pojazd is not null then
            select deref(self.ref_pojazd) into v_pojazd_ref from dual;

            if v_pojazd_ref is not null then
                v_nr_rej := v_pojazd_ref.nr_rejestracyjny;
            end if;
        end if;

        v_tekst := 'Data: ' || to_char(self.data_jazdy, 'yyyy-mm-dd') || ' ' || self.godzina_jazdy || ':00' ||
                   ' | Czas: ' || self.czas_trwania || 'h' || 
                   ' | Typ: ' || self.typ_lekcji || 
                   ' | Pojazd: ' || v_nr_rej;
                   
        return v_tekst;
    end informacje;
end;
/

create or replace type lista_lekcji_type as table of lekcja_type;
/


create or replace type kursant_type as object (
    nr_pkk          varchar2(20),
    imie            varchar2(50),
    nazwisko        varchar2(50),
    historia_jazd   lista_lekcji_type,
    
    member function status_kursu return number
);
/

create or replace type body kursant_type as
    member function status_kursu return number is
        suma_godzin number := 0;
    begin
        if self.historia_jazd is not null then
            for i in 1..self.historia_jazd.count loop
                if self.historia_jazd(i).czy_odbyta = 'tak' then
                    suma_godzin := suma_godzin + self.historia_jazd(i).czas_trwania;
                end if;
            end loop;
        end if;
        
        return suma_godzin;
    end status_kursu;
end;
/