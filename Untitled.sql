CREATE TYPE instruktor_type AS OBJECT (
    id_instruktora   NUMBER,
    imie             VARCHAR2(50),
    nazwisko         VARCHAR2(50),

    MEMBER FUNCTION lista_lekcji RETURN SYS_REFCURSOR
);
/
CREATE TYPE BODY instruktor_type AS
    MEMBER FUNCTION lista_lekcji RETURN SYS_REFCURSOR IS
        rc SYS_REFCURSOR;
    BEGIN
        OPEN rc FOR
            SELECT k.pkk,
                   l.data_jazdy,
                   l.czas_trwania
            FROM kursanci_tab k,
                 TABLE(k.historia_jazd) l
            WHERE l.ref_instruktor = REF(SELF);
        RETURN rc;
    END;
END;
/
CREATE TYPE serwis_type AS OBJECT (
    data_serwisu DATE,
    opis         VARCHAR2(200),
    przebieg     NUMBER
);
/
CREATE TYPE lista_serwisow_type AS TABLE OF serwis_type;
/
CREATE TYPE pojazd_type AS OBJECT (
    nr_rejestracyjny VARCHAR2(15),
    model            VARCHAR2(50),
    przebieg         NUMBER,
    dostepny         CHAR(1),
    historia_serwisow lista_serwisow_type,

    MEMBER PROCEDURE aktualizuj_przebieg(km NUMBER)
);
/
CREATE TYPE BODY pojazd_type AS
    MEMBER PROCEDURE aktualizuj_przebieg(km NUMBER) IS
    BEGIN
        przebieg := przebieg + km;
    END;
END;
/
