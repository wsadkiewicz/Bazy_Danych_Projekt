# System Zarządzania Szkołą Jazdy

Projekt **obiektowo-relacyjnej bazy danych** stworzony w celu zarządzania Ośrodkiem Szkolenia Kierowców. System demonstruje wykorzystanie mechanizmów obiektowych w bazie Oracle, takich jak typy obiektowe, kolekcje zagnieżdżone, referencje oraz metody instancyjne.

## O Projekcie

Głównym celem projektu jest odejście od klasycznego modelu relacyjnego na rzecz struktury obiektowej, która lepiej odwzorowuje rzeczywiste zależności w szkole jazdy.

**Kluczowe założenia:**
* **Logika w bazie:** Metody typów i pakiety PL/SQL odpowiadają za logikę biznesową (np. obliczanie godzin, aktualizacja stanu licznika).
* **Zastosowanie referencji (`REF`):** Relacje między lekcją a instruktorem/pojazdem zrealizowano za pomocą wskaźników do obiektów (REF), co pozwala na bezpośrednie odwoływanie się do istniejących zasobów bez powielania ich danych.
* **Kolekcje zagnieżdżone (`NESTED TABLE`):** Historia jazd stanowi integralną część struktury obiektu kursanta, co odwzorowuje naturalną hierarchię danych.

## Zastosowane Technologie i Techniki

* **Silnik bazy:** Oracle Database (19c)
* **Język:** SQL, PL/SQL
* **Elementy Obiektowe:**
    * `CREATE TYPE` (Typy obiektowe)
    * `MEMBER FUNCTION / PROCEDURE` (Metody)
    * `REF` (Referencje do obiektów)
    * `NESTED TABLE` (Kolekcje zagnieżdżone)
* **Elementy Logiki:**
    * Pakiety (`PACKAGE`)
    * Obsługa wyjątków

## Struktura Bazy Danych

System opiera się na hierarchii typów obiektowych:

1.  **`kursant_type`**: Główny obiekt. Posiada kolekcję `historia_jazd`.
    * *Metoda:* `status_kursu()` - sprawdza, czy wyjeżdżono 30h.
2.  **`lista_lekcji_type`**: Kolekcja (Nested Table) przechowująca historię jazd wewnątrz kursanta.
3.  **`lekcja_type`**: Obiekt łączący.
    * Zawiera **REFERENCJE (`REF`)** do `pojazd_type` i `instruktor_type`.
    * *Metoda:* `zakoncz_jazde()` - aktualizuje przebieg auta.
4.  **`pojazd_type`**: Reprezentuje flotę.
    * *Metoda:* `aktualizuj_przebieg()` - zmiany stanu licznika.
5.  **`instruktor_type`**: Reprezentuje kadrę instruktorską.
