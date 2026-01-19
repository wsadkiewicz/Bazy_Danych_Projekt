set serveroutput on;

delete from kursanci_tab;
delete from instruktorzy_tab;
delete from pojazdy_tab;

insert into instruktorzy_tab values (instruktor_type(1, 'Jan', 'Kowalski'));
insert into instruktorzy_tab values (instruktor_type(2, 'Adam', 'Nowak'));

insert into pojazdy_tab values (
    pojazd_type('WAW 10001', 'Toyota Yaris', 5000, 'tak', lista_serwisow_type())
);

insert into pojazdy_tab values (
    pojazd_type('WAW 99999', 'Kia Rio', 32000, 'tak', 
        lista_serwisow_type(
            serwis_type(to_date('01-01-2023', 'dd-mm-yyyy'), 'Przegląd gwarancyjny', 15000)
        )
    )
);

insert into kursanci_tab values (
    kursant_type('12345678900', 'Marek', 'Dudek',
        lista_lekcji_type(
            lekcja_type(sysdate-2, 2, 
                (select ref(i) from instruktorzy_tab i where id_instruktora=1),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny='WAW 10001'),
                5100, 'plac', 'tak'),
            lekcja_type(sysdate+1, 2, 
                (select ref(i) from instruktorzy_tab i where id_instruktora=2),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny='WAW 99999'),
                null, 'miasto', 'nie'),
            lekcja_type(sysdate+1, 4, 
                (select ref(i) from instruktorzy_tab i where id_instruktora=2),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny='WAW 99999'),
                5200, 'miasto', 'tak'),
            lekcja_type(sysdate+1, 4, 
                (select ref(i) from instruktorzy_tab i where id_instruktora=2),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny='WAW 99999'),
                5300, 'miasto', 'tak'),
            lekcja_type(sysdate+1, 4, 
                (select ref(i) from instruktorzy_tab i where id_instruktora=2),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny='WAW 10001'),
                5400, 'miasto', 'tak'),
            lekcja_type(sysdate+1, 4, 
                (select ref(i) from instruktorzy_tab i where id_instruktora=2),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny='WAW 99999'),
                5500, 'miasto', 'tak'),
            lekcja_type(sysdate+1, 4, 
                (select ref(i) from instruktorzy_tab i where id_instruktora=2),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny='WAW 99999'),
                5600, 'miasto', 'tak'),
            lekcja_type(sysdate+1, 4, 
                (select ref(i) from instruktorzy_tab i where id_instruktora=2),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny='WAW 10001'),
                5700, 'miasto', 'tak'),
            lekcja_type(sysdate+1, 4, 
                (select ref(i) from instruktorzy_tab i where id_instruktora=2),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny='WAW 99999'),
                5800, 'miasto', 'tak'),
            lekcja_type(sysdate+1, 4, 
                (select ref(i) from instruktorzy_tab i where id_instruktora=2),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny='WAW 99999'),
                5900, 'miasto', 'tak')
        )
    )
);

insert into kursanci_tab values (
    kursant_type('12345678912', 'Hubert', 'Gąska',
        lista_lekcji_type(
            lekcja_type(sysdate-2, 2, 
                (select ref(i) from instruktorzy_tab i where id_instruktora=1),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny='WAW 10001'),
                6200, 'plac', 'tak'),
            lekcja_type(sysdate+1, 2, 
                (select ref(i) from instruktorzy_tab i where id_instruktora=2),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny='WAW 99999'),
                null, 'miasto', 'nie'),
            lekcja_type(sysdate+1, 1, 
                (select ref(i) from instruktorzy_tab i where id_instruktora=2),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny='WAW 99999'),
                6300, 'miasto', 'tak'),
            lekcja_type(sysdate+1, 2, 
                (select ref(i) from instruktorzy_tab i where id_instruktora=2),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny='WAW 99999'),
                6400, 'miasto', 'tak'),
            lekcja_type(sysdate+1, 4, 
                (select ref(i) from instruktorzy_tab i where id_instruktora=2),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny='WAW 10001'),
                6500, 'miasto', 'tak'),
            lekcja_type(sysdate+1, 4, 
                (select ref(i) from instruktorzy_tab i where id_instruktora=2),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny='WAW 99999'),
                6600, 'miasto', 'tak'),
            lekcja_type(sysdate+1, 3, 
                (select ref(i) from instruktorzy_tab i where id_instruktora=2),
                (select ref(p) from pojazdy_tab p where nr_rejestracyjny='WAW 99999'),
                6700, 'miasto', 'tak')
        )
    )
);

commit;