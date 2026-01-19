drop table instruktorzy_tab;
drop table pojazdy_tab;
drop table kursanci_tab;


create table instruktorzy_tab of instruktor_type (
    id_instruktora primary key
);

create table pojazdy_tab of pojazd_type (
    nr_rejestracyjny primary key
)
nested table historia_serwisow store as tab_historia_serwisow;

create table kursanci_tab of kursant_type (
    nr_pkk primary key
)
nested table historia_jazd store as tab_historia_jazd;

alter table tab_historia_jazd add (scope for (ref_instruktor) is instruktorzy_tab);
alter table tab_historia_jazd add (scope for (ref_pojazd) is pojazdy_tab);