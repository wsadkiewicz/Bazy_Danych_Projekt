set serveroutput on;

-- =================================================================
-- Usuwanie tabel i sekwencji
-- =================================================================
begin
    for t in (
        select object_name 
        from user_objects 
        where object_type = 'TABLE' 
          and object_name in (
              'KURSANCI_TAB',
              'POJAZDY_TAB',
              'INSTRUKTORZY_TAB'
          )
    ) loop
        execute immediate 'drop table ' || t.object_name || ' cascade constraints';
        dbms_output.put_line('Usunięto tabelę: ' || t.object_name);
    end loop;
    
    for s in (
        select object_name 
        from user_objects 
        where object_type = 'SEQUENCE' 
          and object_name = 'INSTRUKTOR_SEQ'
    ) loop
        execute immediate 'drop sequence ' || s.object_name;
        dbms_output.put_line('Usunięto sekwencję: ' || s.object_name);
    end loop;
end;
/

-- =================================================================
-- Usuwanie pakietów
-- =================================================================
begin
    for p in (
        select object_name 
        from user_objects 
        where object_type = 'PACKAGE' 
          and object_name in ('KURSANT_PKG', 'FLOTA_PKG', 'KADRA_PKG')
    ) loop
        execute immediate 'drop package ' || p.object_name;
        dbms_output.put_line('Usunięto pakiet: ' || p.object_name);
    end loop;
end;
/

-- =================================================================
-- Usuwanie typów
-- =================================================================
begin
    for t in (
        select object_name 
        from user_objects 
        where object_type = 'TYPE' 
          and object_name in (
            'KURSANT_TYPE', 
            'LISTA_LEKCJI_TYPE', 
            'LEKCJA_TYPE', 
            'INSTRUKTOR_TYPE', 
            'POJAZD_TYPE', 
            'LISTA_SERWISOW_TYPE', 
            'SERWIS_TYPE'
        )
    ) loop
        execute immediate 'drop type ' || t.object_name || ' force';
        dbms_output.put_line('Usunięto typ: ' || t.object_name);
    end loop;
end;
/

begin
    dbms_output.put_line('Zakończono czyszczenie danych');
end;
/