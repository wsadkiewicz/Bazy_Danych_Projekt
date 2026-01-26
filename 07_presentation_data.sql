set serveroutput on;

delete from kursanci_tab;
delete from pojazdy_tab;
delete from instruktorzy_tab;

drop sequence instruktor_seq;
create sequence instruktor_seq start with 1 increment by 1;

commit;

-- ==========================================================
-- Instruktorzy
-- ==========================================================

insert into instruktorzy_tab values (
    instruktor_type(instruktor_seq.nextval, 'Andrzej', 'Kwiatkowski')
);

insert into instruktorzy_tab values (
    instruktor_type(instruktor_seq.nextval, 'Beata', 'Majewska')
);

insert into instruktorzy_tab values (
    instruktor_type(instruktor_seq.nextval, 'Grzegorz', 'Wróbel')
);

commit;

-- ==========================================================
-- Pojazdy
-- ==========================================================

insert into pojazdy_tab values (
    pojazd_type('EL 4529A', 'Toyota Yaris IV', 120500, 'tak', lista_serwisow_type())
);

insert into pojazdy_tab values (
    pojazd_type('WA 88421', 'Hyundai i20', 45000, 'tak', 
        lista_serwisow_type(
            serwis_type(to_date('2025-11-15', 'YYYY-MM-DD'), 'Wymiana oleju i filtrów', 40000)
        )
    )
);

insert into pojazdy_tab values (
    pojazd_type('KR 3X200', 'Kia Rio', 185000, 'nie', lista_serwisow_type())
);

insert into pojazdy_tab values (
    pojazd_type('GD 99999', 'Skoda Fabia III', 12000, 'tak', lista_serwisow_type())
);

commit;

-- ==========================================================
-- Kursanci i historia jazd
-- ==========================================================

insert into kursanci_tab values (
    kursant_type('20240101123456789001', 'Adam', 'Nowicki', lista_lekcji_type())
);

insert into kursanci_tab values (
    kursant_type('20231212098765432122', 'Monika', 'Kaczmarek',
        lista_lekcji_type(
            lekcja_type(
                sysdate - 5,
                10,
                2,
                (select ref(i) from instruktorzy_tab i where nazwisko = 'Kwiatkowski'),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny = 'EL 4529A'),
                120400,
                'plac',
                'tak'
            ),
            lekcja_type(
                sysdate - 2,
                12,
                2,
                (select ref(i) from instruktorzy_tab i where nazwisko = 'Kwiatkowski'),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny = 'EL 4529A'),
                120450,
                'miasto',
                'tak'
            ),
            lekcja_type(
                sysdate + 2,
                8,
                2,
                (select ref(i) from instruktorzy_tab i where nazwisko = 'Majewska'),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny = 'WA 88421'),
                null,
                'miasto',
                'nie'
            )
        )
    )
);

insert into kursanci_tab values (
    kursant_type('20230505555556666677', 'Piotr', 'Zieliński',
        lista_lekcji_type(
            lekcja_type(sysdate - 60, 8, 4, (select ref(i) from instruktorzy_tab i where nazwisko = 'Wróbel'), (select ref(p) from pojazdy_tab p where nr_rejestracyjny = 'WA 88421'), 41000, 'plac', 'tak'),
            lekcja_type(sysdate - 55, 8, 4, (select ref(i) from instruktorzy_tab i where nazwisko = 'Wróbel'), (select ref(p) from pojazdy_tab p where nr_rejestracyjny = 'WA 88421'), 41100, 'plac', 'tak'),
            lekcja_type(sysdate - 50, 10, 4, (select ref(i) from instruktorzy_tab i where nazwisko = 'Wróbel'), (select ref(p) from pojazdy_tab p where nr_rejestracyjny = 'WA 88421'), 41200, 'miasto', 'tak'),
            lekcja_type(sysdate - 45, 10, 4, (select ref(i) from instruktorzy_tab i where nazwisko = 'Wróbel'), (select ref(p) from pojazdy_tab p where nr_rejestracyjny = 'WA 88421'), 41300, 'miasto', 'tak'),
            lekcja_type(sysdate - 40, 12, 4, (select ref(i) from instruktorzy_tab i where nazwisko = 'Wróbel'), (select ref(p) from pojazdy_tab p where nr_rejestracyjny = 'WA 88421'), 41400, 'miasto', 'tak'),
            lekcja_type(sysdate - 35, 12, 4, (select ref(i) from instruktorzy_tab i where nazwisko = 'Wróbel'), (select ref(p) from pojazdy_tab p where nr_rejestracyjny = 'WA 88421'), 41500, 'miasto', 'tak'),
            lekcja_type(sysdate - 30, 14, 4, (select ref(i) from instruktorzy_tab i where nazwisko = 'Wróbel'), (select ref(p) from pojazdy_tab p where nr_rejestracyjny = 'WA 88421'), 41600, 'miasto', 'tak'),
            lekcja_type(sysdate - 25, 14, 4, (select ref(i) from instruktorzy_tab i where nazwisko = 'Wróbel'), (select ref(p) from pojazdy_tab p where nr_rejestracyjny = 'WA 88421'), 41700, 'miasto', 'tak')
        )
    )
);

commit;