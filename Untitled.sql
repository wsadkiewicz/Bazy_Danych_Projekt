drop table instruktorzy_tab;
drop table pojazdy_tab;
drop table kursanci_tab;


create table instruktorzy_tab of instruktor_type (
    id_instruktora primary key
);

create table pojazdy_tab of pojazd_type (
    nr_rejestracyjny primary key,
    constraint chk_pojazd_dostepnosc check (dostepny in ('tak', 'nie'))
)
nested table historia_serwisow store as historia_serwisow_tab;

create table kursanci_tab of kursant_type (
    nr_pkk primary key
)
nested table historia_jazd store as historia_jazd_tab;

alter table historia_jazd_tab add (
      
    constraint chk_lekcja_odbyta    check (czy_odbyta in ('tak', 'nie')),
    constraint chk_typ_lekcji       check (typ_lekcji in ('miasto', 'plac')),
    
    scope for (ref_instruktor) is instruktorzy_tab,
    scope for (ref_pojazd)     is pojazdy_tab
);