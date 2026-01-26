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
    instruktor_type(instruktor_seq.nextval, 'Marek', 'Kowalski')
);

insert into instruktorzy_tab values (
    instruktor_type(instruktor_seq.nextval, 'Anna', 'Nowak')
);

insert into instruktorzy_tab values (
    instruktor_type(instruktor_seq.nextval, 'Tomasz', 'Wiśniewski')
);

commit;

-- ==========================================================
-- Pojazdy
-- ==========================================================

insert into pojazdy_tab values (
    pojazd_type('WAW 10001', 'Toyota Yaris', 5000, 'tak', lista_serwisow_type())
);

insert into pojazdy_tab values (
    pojazd_type('KR 50000', 'Kia Rio', 55000, 'tak', 
        lista_serwisow_type(
            serwis_type(to_date('2023-01-10', 'YYYY-MM-DD'), 'Duży przegląd', 30000)
        )
    )
);

insert into pojazdy_tab values (
    pojazd_type('GD 99999', 'Skoda Fabia', 12000, 'nie', lista_serwisow_type())
);

commit;

-- ==========================================================
-- Kursanci i historia jazd
-- ==========================================================

insert into kursanci_tab values (
    kursant_type('11111111111', 'Krzysztof', 'Jankowski', lista_lekcji_type())
);

insert into kursanci_tab values (
    kursant_type('22222222222', 'Monika', 'Lewandowska',
        lista_lekcji_type(
            lekcja_type(
                sysdate - 10,
                10,
                2,
                (select ref(i) from instruktorzy_tab i where nazwisko = 'Kowalski'),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny = 'WAW 10001'),
                4800,
                'plac',
                'tak'
            ),
            lekcja_type(
                sysdate - 5,
                12,
                2,
                (select ref(i) from instruktorzy_tab i where nazwisko = 'Kowalski'),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny = 'WAW 10001'),
                4850,
                'miasto',
                'tak'
            ),
            lekcja_type(
                sysdate + 1,
                8,
                2,
                (select ref(i) from instruktorzy_tab i where nazwisko = 'Nowak'),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny = 'KR 50000'),
                null,
                'miasto',
                'nie'
            )
        )
    )
);

insert into kursanci_tab values (
    kursant_type('33333333333', 'Piotr', 'Zieliński',
        lista_lekcji_type(
            lekcja_type(sysdate - 30, 8, 4, (select ref(i) from instruktorzy_tab i where nazwisko = 'Wiśniewski'), (select ref(p) from pojazdy_tab p where nr_rejestracyjny = 'WAW 10001'), 4000, 'plac', 'tak'),
            lekcja_type(sysdate - 28, 8, 4, (select ref(i) from instruktorzy_tab i where nazwisko = 'Wiśniewski'), (select ref(p) from pojazdy_tab p where nr_rejestracyjny = 'WAW 10001'), 4050, 'plac', 'tak'),
            lekcja_type(sysdate - 26, 8, 4, (select ref(i) from instruktorzy_tab i where nazwisko = 'Wiśniewski'), (select ref(p) from pojazdy_tab p where nr_rejestracyjny = 'WAW 10001'), 4100, 'miasto', 'tak'),
            lekcja_type(sysdate - 24, 8, 4, (select ref(i) from instruktorzy_tab i where nazwisko = 'Wiśniewski'), (select ref(p) from pojazdy_tab p where nr_rejestracyjny = 'WAW 10001'), 4150, 'miasto', 'tak'),
            lekcja_type(sysdate - 22, 8, 4, (select ref(i) from instruktorzy_tab i where nazwisko = 'Wiśniewski'), (select ref(p) from pojazdy_tab p where nr_rejestracyjny = 'WAW 10001'), 4200, 'miasto', 'tak'),
            lekcja_type(sysdate - 20, 8, 4, (select ref(i) from instruktorzy_tab i where nazwisko = 'Wiśniewski'), (select ref(p) from pojazdy_tab p where nr_rejestracyjny = 'WAW 10001'), 4250, 'miasto', 'tak'),
            lekcja_type(sysdate - 18, 8, 4, (select ref(i) from instruktorzy_tab i where nazwisko = 'Wiśniewski'), (select ref(p) from pojazdy_tab p where nr_rejestracyjny = 'WAW 10001'), 4300, 'miasto', 'tak'),
            lekcja_type(sysdate - 16, 8, 4, (select ref(i) from instruktorzy_tab i where nazwisko = 'Wiśniewski'), (select ref(p) from pojazdy_tab p where nr_rejestracyjny = 'WAW 10001'), 4350, 'miasto', 'tak')
        )
    )
);

commit;