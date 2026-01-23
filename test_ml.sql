set serveroutput on
begin
    delete from kursanci_tab;
    delete from pojazdy_tab;
    delete from instruktorzy_tab;
    commit;
exception
    when others then null;
end;

begin
    szkola_jazdy_pkg.dodaj_instruktora(2, 'Michał', 'Kowalski');
end;
/
select * from instruktorzy_tab
/
--begin
--    szkola_jazdy_pkg.usun_instruktora(1);
--end;
--/

begin
    szkola_jazdy_pkg.zarejestruj_kursanta('PKK001', 'Adam', 'Nowak');
end;
/
begin
    szkola_jazdy_pkg.dodaj_pojazd('KR12345', 'Toyota Yaris', 12);
end;
/
--begin
--    szkola_jazdy_pkg.usun_pojazd('KR12345');
--end;


select nr_rejestracyjny, model, przebieg, dostepny
from pojazdy_tab;

begin
    szkola_jazdy_pkg.dodaj_jazde(
        p_nr_pkk        => 'PKK001',
        p_nr_rej        => 'KR12345',
        p_id_instr      => 2,
        p_godziny       => 3,
        p_typ_lekcji    => 'miasto',
        p_data_jazdy    => date '2022-03-18',
        p_godzina_start => 17
    );
end;

begin
    szkola_jazdy_pkg.lista_lekcji_instruktora(2);
end;
/

select 
    k.nr_pkk,
    t.data_jazdy,
    t.czas_trwania,
    t.typ_lekcji,
    t.czy_odbyta
    
from kursanci_tab k,
     table(k.historia_jazd) t
where k.nr_pkk = 'PKK001';


select t.data_jazdy
from kursanci_tab k,
     table(k.historia_jazd) t
where k.nr_pkk = 'PKK001';


begin
    szkola_jazdy_pkg.zakoncz_lekcje(
        p_nr_pkk   => 'PKK001',
        data       => to_date('2022/03/18', 'yy/mm/dd'),
        p_przebieg => 120150
    );
end;
/


select t.czy_odbyta, t.przebieg_auta
from kursanci_tab k,
     table(k.historia_jazd) t
where k.nr_pkk = 'PKK001';

-- Przebieg pojazdu
select przebieg
from pojazdy_tab
where nr_rejestracyjny = 'KR12345';


begin
    szkola_jazdy_pkg.wyrejestruj_kursanta('PKK001');
end;
/


select *
from kursanci_tab
where nr_pkk = 'PKK001';


begin
    szkola_jazdy_pkg.dodaj_jazde(
        p_nr_pkk     => 'PKK099',
        p_nr_rej     => 'KR1235',
        p_id_instr   => 1,
        p_godziny    => 2,
        p_typ_lekcji => 'miasto',
        p_data_jazdy => to_date('15/03/2026', 'dd/mm/yyyy')
    );
end;
/

