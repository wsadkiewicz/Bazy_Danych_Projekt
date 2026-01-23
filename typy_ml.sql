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
    dostepny            varchar2(3),
    historia_serwisow   lista_serwisow_type,

    member procedure aktualizuj_przebieg(nowy_przebieg number)
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

    -- [NOTKA] lista_lekcji dla instruktora lepiej przenieść do pakietu bo odnosi się do tabeli kursanci_tab
    -- member function lista_lekcji return sys_refcursor
);
/

create or replace type lekcja_type as object (
    data_jazdy     date,
    czas_trwania   number,
    ref_instruktor ref instruktor_type,
    ref_pojazd     ref pojazd_type,
    przebieg_auta  number,
    typ_lekcji     varchar2(20),
    czy_odbyta     varchar2(3),

    member procedure zakoncz_jazde(nowy_przebieg number)
);
/

create or replace type body lekcja_type as
    member procedure zakoncz_jazde(nowy_przebieg number) is
    begin
        self.czy_odbyta := 'tak';
        self.przebieg_auta := nowy_przebieg;
    end;
end;
/

create or replace type lista_lekcji_type as table of lekcja_type;
/

create or replace type kursant_type as object (
    nr_pkk          varchar2(20),
    imie            varchar2(50),
    nazwisko        varchar2(50),
    historia_jazd   lista_lekcji_type,
    
    member function status_kursu return number,
    member function lista_lekcji return varchar2
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
    
    member function lista_lekcji return varchar2 is
        wynik           varchar2(5000);
        instruktor      instruktor_type;
        czy_istnieje    boolean := false;
    begin
        wynik := 'Imię i Nazwisko: ' || self.imie || ' ' || self.nazwisko || chr(10) ||
                   'Numer PKK: ' || self.nr_pkk || chr(10) || chr(10) ||
                   '-------- Zaplanowane jazdy --------' || chr(10);

        if self.historia_jazd is null or self.historia_jazd.count = 0 then
            return wynik || 'Brak zaplanowanych jazd.';
        end if;

        for i in 1..self.historia_jazd.count loop
            if self.historia_jazd(i).data_jazdy > sysdate then
                czy_istnieje := true;
                
                begin
                    select deref(self.historia_jazd(i).ref_instruktor) 
                    into instruktor 
                    from dual;
                exception
                    when others then
                        instruktor := null;
                end;

                wynik := wynik || 
                         '[' || to_char(self.historia_jazd(i).data_jazdy, 'dd.mm.yyyy hh24:mi') || '] ' ||
                         self.historia_jazd(i).czas_trwania || 'h (' || 
                         initcap(self.historia_jazd(i).typ_lekcji) || ') 
                         - Instruktor: ' ||
                           case 
                               when instruktor is not null then instruktor.imie || ' ' || instruktor.nazwisko 
                               else 'Nieznany' 
                           end ||
                         chr(10);
            end if;
        end loop;

        if not czy_istnieje then
            return 'Brak zaplanowanych jazd.';
        end if;

        return wynik;
    end lista_lekcji;
end;
/