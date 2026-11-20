# SKUN EXPRESS — repozytorium firmowe

Prywatna wtyczka Photoshop CEP dla zespołu SQN, wydanie **v1.2.0**.

## Narzędzia

- Inteligentny mockup
- Rozmiar pod media
- Eksport obszarów kompozycji
- Prowadnice na okładce
- Warianty grafik zbiorczych

## Przygotowanie repozytorium

1. Na GitHubie utwórz **prywatne** repozytorium `SKUN-EXPRESS`.
2. Dodaj do niego zawartość tej paczki, zachowując strukturę katalogów.
3. Współpracownikom przyznaj dostęp **Read**; osobom publikującym wersje **Write**.
4. Spakuj katalog `SKUN_EXPRESS` jako `SKUN_EXPRESS_1.2.0.zip` (wewnątrz ZIP musi znajdować się folder `SKUN_EXPRESS`).
5. Utwórz GitHub **Release** z tagiem `v1.2.0` i załącz plik `SKUN_EXPRESS_1.2.0.zip`. Sam commit nie publikuje aktualizacji!

## Instalacja u współpracownika (Windows)

1. Zainstaluj [GitHub CLI](https://cli.github.com), uruchom w terminalu `gh auth login` i zaloguj się na konto z prawem do prywatnego repozytorium.
2. Pobierz pliki `INSTALUJ.cmd`, `INSTALUJ.ps1`, `AKTUALIZUJ.cmd`, `AKTUALIZUJ.ps1` do **tego samego folderu** (można pobrać całe repo jako ZIP).
3. Uruchom `INSTALUJ.cmd`, wpisz `OWNER/REPO`, np. `SQN/SKUN-EXPRESS`.
4. Instalator pobierze najnowsze stabilne wydanie z Releases, zweryfikuje strukturę i wersję, po zamknięciu Photoshopa wykona podmianę. Zapisuje kopię poprzedniej wersji.
5. Otwórz Photoshop → Okno → Rozszerzenia (przestarzałe) → SKUN EXPRESS.

Panel uruchamia lokalną kopię aktualizatora przez przycisk **Sprawdź i aktualizuj**. Weryfikacja nowej wersji odbywa się w oknie PowerShell; panel nie przechowuje tokenów GitHub.

## Kolejne aktualizacje

- Zmieniaj zawartość `SKUN_EXPRESS` i numer wersji w `version.txt`, `index.html`, `CSXS/manifest.xml`.
- Twórz ZIP z katalogiem `SKUN_EXPRESS` i tag GitHub Release o **identycznym numerze** (np. `v1.3.0` + `SKUN_EXPRESS_1.3.0.zip`).
- Wypuszczaj jedynie wydania stabilne (bez `prerelease`), kiedy mają trafić do współpracowników.
- Nie zamieszczaj poświadczeń ani tokenów w plikach repozytorium.

## Ważne

- Rozszerzenie CEP jest **niepodpisane**. Na komputerach testowych konieczna może być konfiguracja `PlayerDebugMode`; docelowo do szerokiej dystrybucji warto podpisać CEP lub przenieść panel do UXP.
- Instalator jest przeznaczony dla Windows i wymaga GitHub CLI. Każdy użytkownik loguje się **własnym kontem** GitHub.
- Przed wdrożeniem firmowym wykonaj test na jednym stanowisku. Nie testowano tutaj wykonania w Photoshopie 27.11 ani Windows PowerShell.
- Repozytorium prywatne ogranicza dostęp do skryptów; osoby z uprawnieniami do odczytu mogą je pobrać.
