# Pakiet Skryptów Walidacyjnych SQL (PESEL i IBAN)

## Podsumowanie Biznesowe
Repozytorium zawiera zestaw skryptów, funkcji i triggerów SQL zaprojektowanych do zapewnienia spójności i integralności danych na poziomie bazy danych. Kod koncentruje się na zautomatyzowanej walidacji wrażliwych danych w standardowych formatach: PESEL oraz numerów kont bankowych IBAN.

Implementacja reguł walidacyjnych bezpośrednio w warstwie bazy danych zapobiega wprowadzaniu błędnych informacji, odciąża warstwę aplikacyjną i pozwala na utrzymanie wysokich standardów jakości danych w systemach CRM, kadrowo-płacowych oraz finansowych.

## Główne Funkcjonalności

* **Walidacja struktury PESEL:** Weryfikacja 11-cyfrowego formatu oraz obliczanie sumy kontrolnej Modulo 10.
* **Walidacja krzyżowa PESEL:** Automatyczne sprawdzanie, czy podana płeć oraz data urodzenia są zgodne z informacjami zakodowanymi w numerze PESEL (z uwzględnieniem przesunięć stuleci dla roczników z XX i XXI wieku).
* **Uniwersalna walidacja IBAN:** Implementacja algorytmu Modulo 97 do sprawdzania numerów kont z różnych krajów, w tym konwersja liter kodów krajów na wartości numeryczne.
* **Zoptymalizowana walidacja polskiego IBAN:** Wydzielona, zoptymalizowana logika dla 28-znakowych polskich numerów rachunków, stworzona w celu maksymalizacji wydajności dla najczęstszego przypadku biznesowego.
* **Wsparcie dla wielu silników SQL:** Logika zaimplementowana i przetestowana w dwóch popularnych dialektach.

## Wykorzystane Technologie

* **T-SQL (MS SQL Server):** Zaawansowane funkcje, definicje DDL, wyzwalacze DML.
* **MySQL:** Funkcje deterministyczne do walidacji sum kontrolnych.

## Struktura Repozytorium

* `T-SQL/`
  * `IBAN_kraje.sql` - Uniwersalna funkcja walidująca rachunki międzynarodowe.
  * `IBAN_polska.sql` - Wersja zoptymalizowana wyłącznie dla polskich rachunków.
  * `TriggerPESEL.sql` - Definicja tabeli, trigger walidacji krzyżowej oraz zapytania testowe (mock data).
* `MySQL/`
  * `IBAN_mysql.sql` - Funkcja walidująca polski IBAN.
  * `czy_pesel_mysql.sql` - Funkcja sprawdzająca sumę kontrolną PESEL.

## Wartość Biznesowa

* **Spójność Danych:** Ochrona środowiska produkcyjnego przed brudnymi danymi.
* **Automatyzacja:** Wyzwalacze samoczynnie wyłapują niespójności podczas operacji `INSERT` i `UPDATE` bez konieczności ręcznych audytów.
* **Elastyczność i Wydajność:** Zastosowanie dwóch podejść do walidacji IBAN (rozwiązanie uniwersalne vs zoptymalizowane) pozwala na dostosowanie do konkretnych wymagań wydajnościowych systemu.