drop table kursanci_tab;
drop table instruktorzy_tab;
drop table pojazdy_tab;

drop type kursant_type;
drop type lista_lekcji_type;
drop type lekcja_type;
drop type instruktor_type;
drop type pojazd_type;


-- uproszczone referencje [DO ZMIANY]
create or replace type instruktor_type as object (
    id          number,
    imie        varchar2(50),
    nazwisko    varchar2(50)
);
/

create or replace type pojazd_type as object (
    nr_rej      varchar2(10),
    model       varchar2(50),
    przebieg    number,
    
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


-- moja część
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
    nr_pkk        varchar2(20),
    imie          varchar2(50),
    nazwisko      varchar2(50),
    historia_jazd lista_lekcji_type,
    
    member function status_kursu return varchar2,
    member function lista_lekcji return varchar2
);
/

create or replace type body kursant_type as
    member function status_kursu return varchar2 is
        suma_godzin number := 0;
    begin
        if self.historia_jazd is not null then
            for i in 1..self.historia_jazd.count loop
                if self.historia_jazd(i).czy_odbyta = 'tak' then
                    suma_godzin := suma_godzin + self.historia_jazd(i).czas_trwania;
                end if;
            end loop;
        end if;
        
        -- metoda będzie wykorzystywana do sprawdzenia godzin w matodzie do generowania raportu więc trzeba zmienić zwracanie, ale mi się już nie chce XD
        if suma_godzin >= 30 then
            return 'Posiada wymagana liczbe godzin do podejscia do egzaminu';
        else
            return 'Nie posiada wymaganej liczby godzin do podejscia do egzaminu (brakuje ' || (30 - suma_godzin) || 'h)';
        end if;
    end status_kursu;
    
    member function lista_lekcji return varchar2 is
        tekst varchar2(4000) := '--- Harmonogram jazd ---' || chr(10);
    begin
        if self.historia_jazd is null or self.historia_jazd.count = 0 then
            return 'Brak zaplanowanych lekcji.';
        end if;

        for i in 1..self.historia_jazd.count loop
            tekst := tekst || i || '. ' || 
                       to_char(self.historia_jazd(i).data_jazdy, 'yyyy-mm-dd hh24:mi') || 
                       ' (' || self.historia_jazd(i).czas_trwania || 'h)' ||
                       ' [' || self.historia_jazd(i).typ_lekcji || ']' ||
                       ' - Odbyta: ' || self.historia_jazd(i).czy_odbyta || 
                       chr(10);
        end loop;

        return tekst;
    end lista_lekcji;
end;
/


-- [TABELE] - uproszczone
create table instruktorzy_tab of instruktor_type (
    id primary key
);

create table pojazdy_tab of pojazd_type (
    nr_rej primary key
);

create table kursanci_tab of kursant_type (
    nr_pkk primary key
)
nested table historia_jazd store as historia_jazd_tab;

alter table historia_jazd_tab add (scope for (ref_instruktor) is instruktorzy_tab);
alter table historia_jazd_tab add (scope for (ref_pojazd) is pojazdy_tab);


-- W pakiecie potrzebna jest metoda 
-- zakoncz_jazde(pkk varchar2, 
--               data_jazdy date, 
--               przebieg_pojazdu number);
-- która będzie wywoływać zakoncz_jazde z lekcja_type i aktualizuj_przebieg z pojazd_type
-- oraz metoda 
-- sprawdz_postepy_kursanta(pkk varchar2)
-- która będzie wywoływać status_kursu z kursant_type


-- [TESTOWNIE]
set serveroutput on;

-- [USUNIĘCIE STARYCH DANYCH]
delete from kursanci_tab;
delete from instruktorzy_tab;
delete from pojazdy_tab;

-- [DANE TESTOWE]
insert into instruktorzy_tab values (instruktor_type(1, 'Jan', 'Kowalski'));
insert into pojazdy_tab values (pojazd_type('WAW 12345', 'Toyota Yaris', 10000));
commit;

-- [BLOKI TESTUJĄCE]
declare
    v_pojazd pojazd_type;
    v_nr_rej varchar2(15) := 'WAW 12345';
begin
    dbms_output.put_line('=== TEST 1: Aktualizacja przebiegu ===');
    select value(p) into v_pojazd from pojazdy_tab p where nr_rej = v_nr_rej;
    dbms_output.put_line('Startowy przebieg: ' || v_pojazd.przebieg);


    dbms_output.put_line('[TEST]  Próba zmiejszenia przebiegu.');
    v_pojazd.aktualizuj_przebieg(5000);
    dbms_output.put_line('Przebieg po zmianie: ' || v_pojazd.przebieg);
    if v_pojazd.przebieg = 10000 then
        dbms_output.put_line('[OK]    Przebieg bez zmian.');
    else
        dbms_output.put_line('[ERROR] Przebieg zmalał.');
    end if;
    
    dbms_output.put_line('[TEST]  Aktualizacja przebiegu.');
    v_pojazd.aktualizuj_przebieg(10200);
    dbms_output.put_line('Przebieg po zmianie: ' || v_pojazd.przebieg);
    if v_pojazd.przebieg = 10200 then
        dbms_output.put_line('[OK]    Aktualizacja poprawna.');
    end if;
    dbms_output.put_line('---------------------------------------');
end;
/

declare
    v_ref_instr ref instruktor_type;
    v_ref_auto  ref pojazd_type;
    v_lekcja    lekcja_type;
    v_pkk       varchar2(20) := 'PKK_1';
begin
    dbms_output.put_line('=== TEST 2: Zakończ jazdę ===');

    select ref(i) into v_ref_instr from instruktorzy_tab i where id = 1;
    select ref(p) into v_ref_auto from pojazdy_tab p where nr_rej = 'WAW 12345';

    insert into kursanci_tab values (
        kursant_type(v_pkk, 'Jan', 'Test',
            lista_lekcji_type(
                lekcja_type(sysdate, 2, v_ref_instr, v_ref_auto, null, 'plac', 'nie')
            )
        )
    );
    commit;

    select value(t) into v_lekcja
    from kursanci_tab k, table(k.historia_jazd) t
    where k.nr_pkk = v_pkk and t.czy_odbyta = 'nie';

    dbms_output.put_line('Status przed: ' || v_lekcja.czy_odbyta);

    v_lekcja.zakoncz_jazde(10250);

    dbms_output.put_line('Status po: ' || v_lekcja.czy_odbyta);
    dbms_output.put_line('Przebieg spisany w lekcji: ' || v_lekcja.przebieg_auta);

    if v_lekcja.czy_odbyta = 'tak' and v_lekcja.przebieg_auta = 10250 then
        dbms_output.put_line('[OK] Metoda działa poprawnie.');
    else
        dbms_output.put_line('[ERROR] Status lub przebieg nieprawidłowy.');
    end if;
    dbms_output.put_line('-----------------------------');
end;
/

declare
    v_kursant   kursant_type;
    v_status    varchar2(200);
    v_ref_instr ref instruktor_type;
    v_ref_auto  ref pojazd_type;
    v_pkk       varchar2(20) := 'PKK_2';
begin
    dbms_output.put_line('=== TEST 3: Status kursu ===');

    select ref(i) into v_ref_instr from instruktorzy_tab i where id = 1;
    select ref(p) into v_ref_auto from pojazdy_tab p where nr_rej = 'WAW 12345';

    insert into kursanci_tab values (
        kursant_type(v_pkk, 'Anna', 'Test', lista_lekcji_type())
    );
    
    select value(k) into v_kursant from kursanci_tab k where nr_pkk = v_pkk;
    dbms_output.put_line('[TEST - 0h]: ' || v_kursant.status_kursu());

    insert into table(select k.historia_jazd from kursanci_tab k where nr_pkk = v_pkk)
    values (lekcja_type(sysdate, 7, v_ref_instr, v_ref_auto, null, 'plac', 'nie'));
    
    select value(k) into v_kursant from kursanci_tab k where nr_pkk = v_pkk;
    dbms_output.put_line('[TEST - lekcja nieodbyta]: ' || v_kursant.status_kursu());

    update table(select k.historia_jazd from kursanci_tab k where nr_pkk = v_pkk) t
    set t.czy_odbyta = 'tak';
    
    select value(k) into v_kursant from kursanci_tab k where nr_pkk = v_pkk;
    dbms_output.put_line('[TEST - 7h odbytych]: ' || v_kursant.status_kursu());

    insert into table(select k.historia_jazd from kursanci_tab k where nr_pkk = v_pkk)
    values (lekcja_type(sysdate + 1, 25, v_ref_instr, v_ref_auto, null, 'miasto', 'tak'));

    select value(k) into v_kursant from kursanci_tab k where nr_pkk = v_pkk;
    dbms_output.put_line('[TEST - 32h]: ' || v_kursant.status_kursu());
end;
/

declare
    v_kursant kursant_type;
    v_lista   varchar2(4000);
begin
    select value(k) into v_kursant 
    from kursanci_tab k 
    where nr_pkk = 'PKK_2';
    
    v_lista := v_kursant.lista_lekcji();
    
    dbms_output.put_line('Dane kursanta: ' || v_kursant.imie || ' ' || v_kursant.nazwisko);
    dbms_output.put_line(v_lista);
end;
/