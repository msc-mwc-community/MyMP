# MyMP — prosty multiplayer mod do My Summer Car

Mod w C# wspierający **dwa loadery** (BepInEx i MSCLoader) z jednego,
współdzielonego kodu, plus installer, który kopiuje zbudowane pliki moda
do odpowiedniego folderu w grze. **Da się to wszystko zbudować bez
instalowania dotnet/Visual Studio/Rider** — patrz niżej.

## Zanim zaczniesz: IntelliJ IDEA czy Rider?

Jeśli masz dosłownie **IntelliJ IDEA** (edytor od JetBrains do Javy/Kotlina) -
on w ogóle nie obsługuje C#/.NET, nawet z zainstalowanym dotnet. Do C# w
JetBrains służy osobny produkt: **Rider**. Ale nawet Rider i tak wymaga
gdzieś na dysku prawdziwego kompilatora C# (dotnet SDK albo Mono) - żadne
IDE samo w sobie kompilatora nie dostarcza, tylko się do niego podpina.

Dlatego poniżej jest wariant, który **nie wymaga żadnego IDE ani
instalowania czegokolwiek** - tylko to, co i tak już masz w Windows.

## Wariant bez instalowania niczego (zalecany)

Windows ma już wbudowany kompilator C# jako część .NET Framework (nie
mylić z "dotnet" / .NET SDK, którego nie chcesz instalować) -
`csc.exe`, zwykle pod:
```
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe
```
Jest tam od lat, bez niego połowa Windowsa by nie działała - nic nie musisz
dociągać. Na tym opierają się dwa skrypty w tym projekcie:

- `build_bepinex_no_install.bat` → buduje `MyMP.dll`
- `build_mscloader_no_install.bat` → buduje `MyMP.MSCLoader.dll`

**Co zrobić:**
1. `GAME_DIR` w obu skryptach jest już ustawiony na
   `D:\SteamLibrary\steamapps\common\My Summer Car` — jeśli to Twoja
   ścieżka, nic nie musisz zmieniać.
2. Kliknij dwa razy na `.bat` **wewnątrz folderu `MyMP`** (tego z `Shared`,
   `BepInEx`, `prebuilt` itd.) - nie przenoś samego `.bat` gdzie indziej,
   bo korzysta ze ścieżek względnych (`Shared\*.cs`, `prebuilt\LiteNetLib.dll`).
3. Okno konsoli teraz **zostaje otwarte** (jest na końcu `pause`), więc
   zobaczysz, czy się udało, czy nie, i jaki był błąd - wcześniejsza
   wersja skryptu zamykała okno natychmiast, co mogło wyglądać jakby
   nic się nie stało.
4. Jeśli się powiedzie, `MyMP.dll` (lub `MyMP.MSCLoader.dll`) pojawi się
   **w tym samym folderze co `.bat`** (czyli w `MyMP\`, obok `Shared\`,
   `prebuilt\` itd.) - **nie** w `prebuilt\` (tam są tylko pliki, które
   ja już dla Ciebie zbudowałem: `LiteNetLib.dll` i `MyMP.Installer.exe`).
5. Skopiuj go razem z `prebuilt\LiteNetLib.dll` do:
   - BepInEx: `<gra>\BepInEx\plugins\MyMP\`
   - MSCLoader: do Twojego folderu Mods - MSCPatcher.exe pozwala wybrać
     go spośród kilku lokalizacji (folder gry, Dokumenty, albo AppData),
     więc nie zawsze jest to `<gra>\Mods\`. `MyMP.Installer.exe` (patrz
     niżej) sam sprawdza wszystkie typowe warianty.

   ...albo użyj `prebuilt\MyMP.Installer.exe`, który zrobi to za Ciebie
   (patrz "Installer" niżej) - **ten plik jest już gotowym, działającym
   .exe, nic nie musisz budować, żeby go użyć.**

### Co jest w folderze `prebuilt/` i skąd się wzięło

Nie mam w swoim środowisku ani dotnet, ani Visual Studio, ani dostępu do
NuGet - ale mam dostęp do `apt` (archiwum Ubuntu) i do GitHub, więc
faktycznie skompilowałem dwie rzeczy, które nie zależą od Twojej gry:

- **`LiteNetLib.dll`** - skompilowany z oficjalnych źródeł
  ([RevenantX/LiteNetLib](https://github.com/RevenantX/LiteNetLib)),
  tag `v0.9.5.2`. Użyłem tej starszej wersji celowo - jest ostatnią,
  która kompiluje się starszym/wbudowanym kompilatorem C# bez błędów
  (nowszy LiteNetLib 1.x używa składni C# 9+, której `csc.exe`
  wbudowany w Windows i tak nie obsłuży bez dodatkowych instalacji).
  `Shared/NetworkManager.cs` jest dopasowany pod API akurat tej wersji
  (jedna różnica względem 1.x - opisana w komentarzu w tym pliku).
- **`MyMP.Installer.exe`** - skompilowany z `Installer/Program.cs`
  (ta sama logika co w kroku 4 wyżej).

Obu plików użyłem też do **testu kompilacji całej reszty kodu**: sklei­łem
`Shared/*.cs` + `BepInEx/MyMPPlugin.cs` z realnym `LiteNetLib.dll` i z
przygotowanym przeze mnie przybliżeniem API Unity/BepInEx (bo tych
prawdziwych DLL-i z Twojej gry oczywiście nie mam) - **kompiluje się to
bez błędów**. To nie jest 100% gwarancja (prawdziwe `UnityEngine*.dll`
z Twojej gry mogą mieć drobne różnice), ale duża część ryzyka "literówki
w API" jest już odfajkowana.

Jedyna rzecz, której w ten sposób NIE dało się zweryfikować: dokładne
API `MSCLoader.dll` (nie jest open source w tym samym sensie co
BepInEx/LiteNetLib, nie mam skąd go legalnie wziąć do testu) - tam
nazwy w `MyMPModLoaderEntry.cs` są moją najlepszą, ale niepewną,
propozycją (patrz komentarz w tym pliku).

## Wariant z dotnet / Visual Studio / Rider (alternatywa)

Jeśli jednak kiedyś zainstalujesz dotnet SDK (albo masz Visual Studio/Rider
z już skonfigurowanym .NET), projekty `.csproj` (`BepInEx/MyMP.BepInEx.csproj`,
`MSCLoader/MyMP.MSCLoader.csproj`, `Installer/MyMP.Installer.csproj`) są
gotowe do użycia - teraz też bez NuGet (referują `prebuilt/LiteNetLib.dll`
zamiast paczki), więc zadziałają nawet bez internetu:
```
cd BepInEx
dotnet build -c Release
```

## Installer

W folderze `build/launcher` skrypt `build.ps1` tworzy graficzny
`MyMPLauncher.exe` z angielskim interfejsem i dołącza `MyMP.MSCLoader.dll`,
`LiteNetLib.dll` oraz dostarczone zdjęcie jako tło. Launcher ma przyciski
PLAY, EXIT i Discord, listę zmian oraz wybór folderu gry i folderu Mods.
PLAY rozpakowuje do wskazanego folderu Mods dołączone pliki MyMP, uruchamia
`mysummercar.exe`, czeka na zamknięcie gry i przywraca wcześniejsze pliki
albo usuwa te dodane na czas sesji. Launcher zachowuje dziennik sesji, żeby
przywrócić pliki przy kolejnym uruchomieniu po awarii. Wymaga MSCLoadera;
launcher jest samodzielny i nie wymaga osobnej instalacji .NET Desktop Runtime.
Pliki są obecnie dołączone do paczki; automatyczne
pobieranie aktualizacji z GitHuba wymaga opublikowanego repozytorium/wydań
MyMP, którego ten folder jeszcze nie wskazuje.

Launcher ma własne logo wektorowe i ekran ładowania. Jeśli dotychczasowy
`MyMPLauncher.exe` jest otwarty, nowy build trafia do `build/launcher-update`.

Po uruchomieniu gry wskaźnik `SESSION ONLINE/OFFLINE` znajduje się w lewym
górnym rogu. Informacja `MyMP | Launcher is currently in testing, so expect
bugs.` jest wyświetlana na dole ekranu.

`build.ps1` buduje launcher po skompilowaniu moda.

`prebuilt/MyMP.Installer.exe` jest już zbudowany - możesz go użyć od razu,
bez żadnego kroku budowania. Co robi:

1. Szuka folderu gry - przez rejestr Steam, we WSZYSTKICH bibliotekach
   Steam (czyta `libraryfolders.vdf`, więc znajdzie grę też na innym
   dysku, np. `D:\SteamLibrary`, nie tylko w domyślnej lokalizacji na C:).
   Jeśli nie znajdzie automatycznie, zapyta o ścieżkę z podpowiedzią
   `D:\SteamLibrary\steamapps\common\My Summer Car` (Enter = zaakceptuj).
2. Pyta, czy instalować pod BepInEx czy MSCLoader.
3. Kopiuje `MyMP.dll`/`MyMP.MSCLoader.dll` + `LiteNetLib.dll` (muszą leżeć
   obok `MyMP.Installer.exe`) do właściwego folderu.

**WAŻNE** - to kopiarka plików, nie "wstrzykiwacz" do działającego procesu
gry. Nie używa technik typu `WriteProcessMemory`/`CreateRemoteThread`
(to klasyczne "process injection", używane też przez trenery/cheaty/
malware, i celowo tego tu nie ma). BepInEx i MSCLoader ładują mody z
plików na dysku w momencie startu gry - więc "automatyczne wrzucenie
kodu do MSC" w praktyce oznacza dokładnie to: skopiowanie gotowych
plików tam, gdzie loader i tak ich szuka przy starcie. Installer **nie
instaluje samego BepInEx/MSCLoadera** - to robisz raz, wg ich własnej
instrukcji, zanim uruchomisz installer.

## Struktura projektu

```
MyMP/
├── prebuilt/                     GOTOWE pliki (nie trzeba budować)
│   ├── LiteNetLib.dll
│   └── MyMP.Installer.exe
├── build_bepinex_no_install.bat  buduje MyMP.dll przez wbudowany csc.exe
├── build_mscloader_no_install.bat buduje MyMP.MSCLoader.dll
├── Shared/                       kod wspólny dla obu loaderów
│   ├── PacketType.cs
│   ├── MyMPLog.cs                 loader-agnostyczny logger
│   ├── NetworkManager.cs          host/klient, Ping/Pong, sync pozycji
│   ├── PlayerSync.cs              poruszanie kukiełką gracza nr 2
│   ├── LobbyCodeGenerator.cs      kod lobby MXXXXMP
│   ├── MainMenuHook.cs            nakładki HOST/DISCORD nad Continue/New Game
│   ├── SteamNetworking.cs         P/Invoke do steam_api64.dll (eksperymentalne)
│   └── SteamNetworkManager.cs     odpowiednik NetworkManager przez Steam
├── BepInEx/
│   ├── MyMPPlugin.cs              entry point dla BepInEx
│   └── MyMP.BepInEx.csproj        alternatywny build przez dotnet
├── MSCLoader/
│   ├── MyMPModLoaderEntry.cs      entry point dla MSCLoader
│   └── MyMP.MSCLoader.csproj
├── Installer/
│   ├── Program.cs                 źródło MyMP.Installer.exe
│   └── MyMP.Installer.csproj
└── README.md
```

## Test lokalny (dwie instancje gry na jednym PC)

1. Uruchom grę, kliknij "HOST" (w miejscu Continue), a następnie
   "Stwórz serwer (LAN)". Po udanym uruchomieniu hosta gra automatycznie
   wczyta zapis.
2. Uruchom drugą instancję gry (np. drugi raz przez skrót do exe gry, albo
   drugi komputer w tej samej sieci LAN).
3. W drugiej instancji w polu IP wpisz `127.0.0.1` (ten sam PC) lub lokalny
   adres IP hosta w sieci LAN (np. `192.168.1.23`) i kliknij "Dołącz".
4. W konsoli loadera (BepInEx) / w ModConsole (MSCLoader) powinny pojawiać
   się wpisy `Pong -> RTT = X ms` co 2 sekundy.

## Jak działa pakowanie pozycji (Transform → bajty → Transform)

1. **Po stronie wysyłającej** (`NetworkManager.SendLocalPlayerPosition`):
   - `transform.position` daje `Vector3` (x, y, z) — trzy liczby `float`.
   - `transform.rotation` daje `Quaternion` (x, y, z, w) — cztery liczby `float`.
   - Każdy `float` to 4 bajty. `NetDataWriter.Put(float)` dopisuje te 4 bajty
     do bufora, w kolejności, w jakiej je wywołujesz.
   - Łącznie pakiet pozycji to: 1 bajt typu + 7 × 4 bajty = 29 bajtów.
2. **Po stronie odbierającej** (`NetworkManager.OnNetworkReceive`,
   case `PositionUpdate`):
   - `reader.GetFloat()` czyta kolejne 4-bajtowe porcje — **w dokładnie takiej
     samej kolejności**, w jakiej były zapisane (x, y, z, rx, ry, rz, rw).
   - Z odczytanych liczb odtwarzamy `Vector3` i `Quaternion` i przekazujemy
     do `PlayerSync.UpdateRemotePlayer(...)`.
3. **Poruszanie kukiełką** (`PlayerSync.Tick`):
   - `Vector3.Lerp` / `Quaternion.Slerp` płynnie dociągają kukiełkę do
     ostatnio odebranej pozycji między pakietami, zamiast "teleportować" ją
     co 0.05s.

## Kod lobby — ważne zastrzeżenie

`LobbyCodeGenerator` tworzy kod `MXXXXMP`: litera M, cztery cyfry podzielne przez 7 i końcówka MP. Host używa kodu jako klucza połączenia LAN, więc dołączenie wymaga zgodnego kodu i adresu IP hosta. Kod nie wyszukuje hosta przez internet; do tego potrzebna byłaby usługa pośrednicząca.

## Steam Networking Relay — EKSPERYMENTALNE, nieprzetestowane

Oprócz połączenia po IP (LAN) doszła druga, niezależna opcja w panelu
multiplayer: połączenie przez Steam, adresowane po SteamID64 zamiast IP.
**Nie testowałem tego w prawdziwej grze** (nie mam jak uruchomić
prawdziwego klienta Steam w swoim środowisku) - to pierwszy szkic, który
się kompiluje, ale może wymagać poprawek po pierwszym realnym teście,
dokładnie jak reszta tego projektu przez ostatnie kilka rund.

### Dlaczego nie Facepunch.Steamworks ani pełny Steamworks.NET

- **Facepunch.Steamworks wymaga .NET 4.x** - wprost w ich własnej
  dokumentacji. Wasza gra działa na starym .NET 2.0 (`v2.0.50727`), a ich
  `CreateLobbyAsync`/`JoinLobbyAsync` są oparte o `System.Threading.Tasks`,
  którego w .NET 2.0 w ogóle nie ma - to nie "wymaga poprawek", to twardy
  mur niezależny od tego, ile by się próbowało łatać.
- **Pełny Steamworks.NET** jest bliższy (bez async/Task, klasyczny
  `Callback<T>`/`CallResult<T>`), ale jego całe API to ~950 funkcji
  P/Invoke w jednym pliku (`NativeMethods.cs`) + generyczna infrastruktura
  callbacków używająca `Marshal.SizeOf<T>()`/`PtrToStructure<T>()` (.NET
  4.5+, nie istnieje w .NET 2.0) + `CSteamAPIContext.Init()`, które chce
  na raz znaleźć ~25 podsystemów Steam (jeśli choćby jeden się nie znajdzie,
  caly init zwraca `false`). Naprawienie WSZYSTKICH niezgodności (głównie
  w kodzie obsługującym rzeczy, których nie potrzebujemy - UGC, HTML
  surface, Input, Remote Play...) było nierealne w rozsądnym czasie.

### Co zamiast tego

`Shared/SteamNetworking.cs` - własne, ręczne wiązania P/Invoke do
`steam_api64.dll`, tylko ~15 funkcji, których faktycznie potrzebujemy.
WAŻNE: to nie są zgadywane sygnatury - przepisałem je wprost ze źródeł
Steamworks.NET (więc są poprawne), tylko wybrałem wąski podzbiór zamiast
całości. Używają starego, ale wciąż działającego (Valve oznacza je jako
deprecated, nie jako usunięte) `ISteamNetworking` z automatycznym NAT
traversal + przekazywaniem przez serwery Valve, gdy bezpośrednie
połączenie się nie uda - to jest to, co historycznie nazywało się "Steam
Networking Relay", zanim Valve dodało nowsze `ISteamNetworkingSockets`.

`Shared/SteamNetworkManager.cs` - odpowiednik `NetworkManager`, ten sam
protokół pakietów (Ping/Pong/PositionUpdate), ale adresowanie po SteamID
zamiast IP:port. W `LobbyUI` działa jako druga, niezależna opcja obok
istniejącego połączenia LAN.

### Co najpewniej będzie trzeba poprawić po pierwszym teście

- **Nazwa biblioteki**: zakładam `steam_api64.dll` (gra 64-bitowa). Jeśli
  Wasza gra jest 32-bitowa, w `SteamNetworking.cs` zmień `Lib = "steam_api64"`
  na `"steam_api"`.
- **String wersji interfejsów przy Init**: wysyłam tylko 4 (SteamUtils,
  SteamClient, SteamUser, SteamNetworking) zamiast pełnej listy ~20 -
  jeśli `SteamAPI_Init` zwróci `VersionMismatch`, prawdopodobnie trzeba
  dopisać więcej (zobacz `autogen/SteamConstants.cs`, gdybyś chciał
  pobrać źródła Steamworks.NET żeby porównać dokładne stringi).
- **Nie testowałem w ogóle layoutu `CallbackMsg_t`** (struktura, którą
  Steam wypełnia przy `ManualDispatch_GetNextCallback`) - offsety pól,
  które czytam (`Marshal.ReadInt32(msg, 4)` na `iCallback`,
  `Marshal.ReadIntPtr(msg, 8)` na `pubParam`) są przepisane z dokumentacji
  Valve, ale różnice 32/64-bit w wyrównaniu pamięci (padding) potrafią to
  przesunąć - jeśli auto-akceptacja sesji P2P nie zadziała, to pierwsze
  miejsce do sprawdzenia.
- **Tylko dwóch graczy** (host + jeden klient) - podobnie jak reszta
  tego projektu.
- **Brak Steam Lobby/matchmakingu** - host musi ręcznie podać swój
  SteamID64 znajomemu (pokazany w panelu po kliknięciu "Stwórz serwer
  (Steam)"). Prawdziwe lobby Steam (lista znajomych, przeglądarka) to
  osobna, dużo większa funkcja (`ISteamMatchmaking`) - nie zaimplementowana.

## Poprawki po pierwszym realnym teście builda

Realne uruchomienie skryptów `.bat` na Twoim komputerze (dzięki za
wklejanie logów!) ujawniło kilka rzeczy, które poprawiłem po kolei:

1. **Wbudowany `csc.exe` wspiera tylko C# do wersji 5** (starszy niż
   zakładałem) - cały kod (`Shared/`, `BepInEx/`, `MSCLoader/`,
   `Installer/`) został przepisany bez interpolacji stringów (`$"..."`),
   operatora `?.` i metod/właściwości w formie `=>` - to wszystko są
   funkcje C# 6, których ten kompilator nie obsługuje. Przetestowałem to
   lokalnie z wymuszonym `-langversion:5` - kompiluje się czysto.
2. **`UnityEngine.CoreModule.dll`, `UnityEngine.IMGUIModule.dll` i
   `Unity.TextMeshPro.dll` nie istnieją w Twojej wersji gry** (starsza/
   inna budowa Unity niż zakładałem). Oba skrypty `.bat` teraz same
   sprawdzają, które z tych plików istnieją, i dołączają do kompilacji
   tylko te, które naprawdę są - reszta (`UnityEngine.dll`,
   `BepInEx.dll`/`MSCLoader.dll`, `LiteNetLib.dll`) i tak wystarcza.
   Przy okazji usunąłem z kodu zależność od TextMeshPro (`MainMenuHook`
   obsługuje teraz tylko klasyczny `UnityEngine.UI.Text` - skoro nie
   masz `Unity.TextMeshPro.dll`, Twoja gra najpewniej i tak go nie używa).
3. **Oba pliki `.bat` miały końcówki linii Unix (LF) zamiast
   Windows (CRLF)** - to częsta przyczyna właśnie takich dziwnych,
   trudnych do zdiagnozowania błędów CMD jak „X was unexpected at this
   time.” Przepisałem oba pliki od nowa z poprawnymi końcówkami CRLF.
4. **Ostrzeżenia `CS1684` o `LiteNetLib.dll` i typie `Queue`1`** - to tylko
   ostrzeżenia (nie błędy), efekt tego, że `LiteNetLib.dll` zbudowałem
   przez Mono, a Ty kompilujesz prawdziwym `.NET Framework`. Nie blokują
   builda i nie wpływają na działanie - można je zignorować.
5. **`FindObjectsOfType<T>(true)` i `GetComponentInChildren<T>(true)`
   (wersje z `includeInactive`) nie istnieją w Twojej wersji Unity** -
   usunięte, zostały wersje bezargumentowe. Jedyny efekt uboczny:
   `MainMenuHook` znajdzie przycisk tylko, jeśli jest na AKTYWNYM
   obiekcie w danym momencie - w menu głównym to i tak standardowy
   przypadek.
6. **`Setup.OnModConfirmedExit` nie istnieje w MSCLoaderze** - to był mój
   błąd (zgadywałem). Sprawdziłem oficjalną dokumentację
   (`github.com/piotrulos/MSCModLoader/wiki`) i poprawiłem na realne
   wartości enuma `Setup`: `OnMenuLoad` (zamiast `OnLoad`) do
   inicjalizacji moda - `OnLoad` w MSCLoaderze odpala się dopiero po
   wczytaniu sceny GRY, czyli za późno, żeby zdążyć podmienić przycisk w
   menu głównym - oraz `OnSave` jako najbliższy dostępny odpowiednik
   "zamknięcia gry" (MSCLoader nie ma osobnego zdarzenia na każdy
   możliwy sposób zamknięcia aplikacji).

7. **Najważniejsza poprawka: gra faktycznie działa na starym Mono/.NET 2.0
   (runtime `v2.0.50727`)**, a oba pliki `.dll` były budowane pod nowszy
   `.NET 4.0` (`v4.0.30319`) - stąd błąd gry „classes in the module cannot
   be loaded”. Poprawka w dwóch miejscach:
   - `prebuilt/LiteNetLib.dll` przebudowany z `-sdk:2` (profil .NET 2.0) -
     zweryfikowałem bajtowo, że metadane teraz mają `v2.0.50727`, nie
     `v4.0.30319`.
   - Oba skrypty `.bat` używają teraz kompilatora z folderu **`v3.5`**
     (`C:\Windows\Microsoft.NET\Framework64\v3.5\csc.exe`), NIE `v4.0.30319`
     - mimo nazwy folderu, ten kompilator nadal celuje w stary runtime
     `v2.0.50727` (.NET 3.5 nie ma własnego CLR, działa na CLR 2.0). Jeśli
     tego folderu nie ma, trzeba włączyć w Windows funkcję „.NET Framework
     3.5 (wraz z .NET 2.0 i 3.0)” (Panel sterowania → Programy → Włącz lub
     wyłącz funkcje systemu Windows) - skrypt teraz podpowiada to w
     komunikacie błędu. Przy okazji ten kompilator obsługuje C# tylko do
     wersji 3.0 (jeszcze mniej niż poprzedni limit 5) - sprawdziłem lokalnie
     z `-langversion:3 -sdk:2`, że cały kod nadal się kompiluje czysto.
8. **`new NetManager(this)` nie kompilował się prawdziwym kompilatorem
   C# 3.0** - konstruktor `NetManager` w LiteNetLib ma drugi parametr
   opcjonalny (`PacketLayerBase extraPacketLayer = null`), ale real­ny
   kompilator .NET Framework 3.5 (w przeciwieństwie do Mono, którym to
   wcześniej testowałem) nie rozumie POMIJANIA parametrów domyślnych przy
   WYWOŁANIU - to osobna, specyficzna różnica między C# 3.0 a 4.0, którą
   mój dotychczasowy test z Mono niestety przepuszczał (Mono jest tu
   bardziej pobłażliwe niż prawdziwy kompilator Microsoftu). Poprawka:
   `new NetManager(this, null)` - jawnie podany drugi argument.
   Przeszukałem całe API LiteNetLib, którego używamy, pod kątem innych
   parametrów domyślnych - to było jedyne takie miejsce.
9. **`UnityEngine.SceneManagement` (czyli `SceneManager`/`Scene`/
   `LoadSceneMode`) też nie jest u Ciebie osobnym plikiem .dll** - zamiast
   zgadywać kolejną nazwę pliku, `MainMenuHook` został przepisany tak,
   żeby w ogóle nie potrzebować tej przestrzeni nazw: wykrywanie wczytania
   sceny korzysta teraz ze starszej, "magicznej" metody Unity
   `OnLevelWasLoaded(int level)` + `Application.loadedLevelName` - to
   dużo starsze API (sprzed `SceneManager`), które istnieje w każdej
   wersji Unity bez dodatkowych referencji. Przetestowane lokalnie
   z `-langversion:5` - kompiluje się czysto.

## Historia: jak doszliśmy do obecnego rozwiązania (PlayMaker)

Kilka rund diagnostyki (szczegóły w historii commitów/konwersacji, nie
rozwijam już tu każdego kroku) doprowadziło do pełnego obrazu:

1. Prawdziwe menu gry nie używa `UnityEngine.UI.Button`/`Text` - sprawdziłem
   źródła innych modów MP do MSC (stary, otwarto-źródłowy MSCMP -
   github.com/RootKiller/MSCMP-OLD, GPL v3) i oficjalną wiki MSCLoadera -
   obie potwierdzają, że **My Summer Car jest zbudowane na PlayMaker**
   (popularny w Unity system FSM/wizualnego skryptowania).
2. Prawdziwe przyciski to GameObjecty `ButtonContinue`/`ButtonNewgame`/
   `ButtonQuit`/`ButtonCredits` z komponentem `PlayMakerFSM`, znalezione
   przez refleksję (po nazwie klasy, bez kompilacyjnej referencji do
   `PlayMaker.dll` - gra ma go już załadowanego we własnym procesie).
3. `ButtonContinue` ma sekwencję stanów:
   `Mouse {OVER->Action} -> Action {DOWN->Reset globals 2} -> Reset globals 2
   -> Reset globals -> Init Steam -> State 1 -> Load` - czyli dokładnie to,
   co robi prawdziwe kliknięcie: najechanie wysyła event `OVER`, kliknięcie
   `DOWN`. `PlayMakerFSM` ma do tego metodę `SendEvent(String)` bezpośrednio
   na komponencie.
4. Wysłanie `OVER`+`DOWN` jedno po drugim w tej samej klatce **nie
   działało** - FSM najpewniej przetwarza event dopiero przy swoim
   najbliższym "ticku" i nie zdążał przejść Mouse->Action, zanim przychodziło
   DOWN. Poprawka: oba eventy idą teraz w osobnych klatkach (kilka klatek
   odstępu), w korutynie.

## Obecne rozwiązanie: podmiana przycisku Continue

`MainMenuHook` ukrywa renderery i wyłącza collider prawdziwego
`ButtonContinue`, a w jego miejscu rysuje przycisk HOST przez `OnGUI`,
pozycjonowany względem jego transformacji (`Transform` obiektu ->
`Camera.main.WorldToScreenPoint(...)` -> współrzędne ekranu, przeliczane
co klatkę, więc nadążają nawet jeśli kamera menu się porusza/zmienia kąt):

  - W miejscu `ButtonContinue` → **HOST SESSION**; oryginalny Continue jest ukryty.
- Pod wskaźnikiem sesji w lewym górnym rogu → przycisk **JOIN OUR DISCORD**.

Stałe do dostosowania w `Shared/MainMenuHook.cs`: `ContinueButtonName`/
`NewGameButtonName` (nazwy GameObjectów, gdyby w Twojej wersji gry były
inne), `DiscordUrl`, `ButtonWidth`/`ButtonHeight` (rozmiar nakładek).

Po otwarciu hostowania klon modelu Kale stoi obok Satsumy w scenie menu, a
panel multiplayer ustawia się po prawej, by zostawić podgląd postaci widoczny.
Po wybraniu hostowania `LobbyUI` próbuje wczytać zapis przez wywołania
myszy Unity i zdarzenia PlayMakera, ponawiając próbę pięć razy. Jeśli scena
menu nie zmieni się, lobby pozostaje otwarte z komunikatem diagnostycznym.
To nadal wymaga weryfikacji w prawdziwej grze i zależy od wersji FSM menu.

### Panel administratora

W trakcie gry naciśnij **F6**. Panel jest dostępny dla hosta i pozwala
sprawdzić połączonych graczy LAN/Steam, teleportować hosta do wybranego
gracza, do domu/garażu, sklepu Teimo, warsztatu Fleetariego, nawiedzonego
domu, domu babci, hali tanecznej, cmentarza oraz do aktywnych pojazdów,
sklonować aktywny obiekt obok hosta i dodać pieniądze. Przełącznik „REMOVE ALL
NEEDS” zeruje głód, pragnienie, zmęczenie, stres, potrzeby fizjologiczne i
zabrudzenie, a następnie utrzymuje je na zerze w aktywnej sesji. Przełącznik
„GOD MODE” podtrzymuje flagę `PlayerIsDead` i, jeśli dana wersja gry udostępnia
zmienną, zdrowie `PlayerHealth`; zakres ochrony zależy więc od zmiennych
dostępnych w konkretnej wersji MSC. Obie opcje dotyczą lokalnego hosta i
wyłączają się po rozłączeniu.
Nazwę spawnowanego obiektu wpisuje się dokładnie tak, jak nazywa się obiekt
w hierarchii aktywnej sceny. Zmiany pieniędzy i głodu dotyczą zapisu hosta;
spawnowanie klonuje obiekt lokalnie i na tym etapie nie replikuje go do klientów.

Jeśli gracz umrze w trakcie aktywnej sesji, MyMP sprawdza flagę gry
`PlayerIsDead`, automatycznie wybiera Continue i po wczytaniu zapisu przenosi
gracza w okolice bramy cmentarza. Przy ręcznym wyjściu z zapisu sesja jest
rozłączana przez loader, więc automatyczny powrót nie powinien się uruchomić.
Wczytanie zależy od tego, czy dana wersja gry zachowuje flagę śmierci i przycisk
Continue w oczekiwanym stanie.

### Replikacja świata i model w menu

W LAN i Steam MyMP okresowo przesyła pozycję i rotację pivotów drzwi, bram,
masek, bagażników, klap i szuflad. Kandydaci są odświeżani co pięć sekund,
a skanowanie sceny nie odbywa się już przy każdym pakiecie. Zmiany wysyłane są
co 0,12 s, a pełny stan co osiem sekund. To synchronizuje transformacje tych
elementów, ale nie odtwarza lokalnych dźwięków ani logiki PlayMakera; pozycja
i fizyka pojazdów nadal nie są synchronizowane.
W menu mod próbuje sklonować walkerowy model Kale obok aktywnego Satsumy;
jeśli model lub samochód nie są dostępne w scenie menu, zapisuje ostrzeżenie
w logu zamiast dodawać nieprawidłowy obiekt.

## Co jeszcze warto zweryfikować samemu

- `MainMenuHook` używa `Camera.main` do przeliczenia pozycji 3D na ekran -
  jeśli menu gry nie ma kamery otagowanej "MainCamera", jest fallback na
  pierwszą znalezioną `Camera`, ale jeśli nakładki HOST/DISCORD wyświetlą
  się w złym miejscu (albo wcale), to pierwsze miejsce do sprawdzenia.
- `MainMenuHook` zakłada, że scena menu nazywa się `MainMenu` - zweryfikuj
  w logu (`Wczytano scenę: ...`) i popraw w razie potrzeby.
- `MyMPModLoaderEntry` (MSCLoader) - namespace `MSCLoader` i abstrakcyjna
  właściwość `Version` na klasie `Mod` są potwierdzone z oficjalnej
  dokumentacji. Reszta (`SetupFunction`, enum `Setup.*`, `ModConsole`)
  nadal nie była możliwa do zweryfikowania u mnie - sprawdź względem
  swojej wersji `MSCLoader.dll` (IntelliSense w IDE pokaże dostępne
  wartości enuma, jeśli referencja jest poprawnie dodana).
- **Poprawka względem wcześniejszej wersji**: plik loadera nazywa się
  `MSCLoader.dll` (nie `MSCModLoader.dll`, jak wcześniej zakładałem) i
  leży w `mysummercar_Data\Managed\`, obok `UnityEngine.dll` - nie w
  głównym folderze gry. Instaluje go tam `MSCPatcher.exe` (osobne
  narzędzie, nie ten installer). Wszystkie ścieżki/skrypty w tym
  projekcie są już poprawione.

## Co dalej (nie jest tu zaimplementowane)

- Obsługa więcej niż jednego zdalnego gracza (obecnie jedna kukiełka —
  łatwo rozszerzyć na `Dictionary<int, Transform>` kluczowany po `peer.Id`).
- Synchronizacja animacji postaci, fizyki pojazdów, inwentarza i zdarzeń PlayMakera.
- Prawdziwe łączenie po kodzie lobby przez internet (patrz sekcja wyżej).
- Automatyczna instalacja samego BepInEx/MSCLoadera (installer zakłada, że
  jeden z nich już masz).
- Zabezpieczenia/antycheat — to czysto funkcjonalny szkielet.

## Model zdalnego gracza

Na podstawie zrzutu z logiem MyMP projekt używa modelu gry `HUMANS/Randomizer/Walkers/Kale/Pivot/Char/bodymesh`. Po wczytaniu świata adapter klonuje hierarchię `Char`, wyłącza skrypty i kolizje klona, a pozycję/rotację aktualizuje przez synchronizację sieciową. Jeśli modelu nie ma w scenie, zostaje kapsuła awaryjna. To model walkera z gry jako awatar zdalnego gracza; synchronizacja animacji nie jest jeszcze dodana. Nadruk MyMP na koszulce wymaga osobnej tekstury i dopasowania do UV modelu.

## Kody sesji

Kod ma format `M` + cztery cyfry będące wielokrotnością 7 + `MP`, na przykład `M0042MP`. W połączeniu LAN wpisuje się także adres IP hosta; kod jest kluczem dostępu, a nie usługą wyszukiwania hosta.


## Kompilowanie aktualnym .NET SDK

Na komputerze zainstalowany jest .NET SDK 8. Aby zbudować wersję MSCLoader bez instalowania jej do gry, uruchom z PowerShella w głównym folderze projektu:

```powershell
.\build.ps1
```

Mod trafi do `build\MyMP.MSCLoader.dll`, a gotowa paczka launchera (z aktualizatorem)
do `build\launcher`. Jeśli launcher jest uruchomiony podczas budowania, skrypt
zapisze nową paczkę w `build\launcher-update`. Dodatkowo skrypt tworzy archiwum
`build\MyMPLauncher-<wersja>-win-x64.zip` do pierwszej ręcznej instalacji. Wypakuj
całą zawartość ZIP do jednego folderu i uruchom `MyMPLauncher.exe`.
Alternatywne skrypty `.bat` nadal używają wbudowanego kompilatora .NET Framework 3.5.

## Aktualizacje launchera

Launcher ma przycisk sprawdzania aktualizacji. Przy starcie pobiera mały manifest
z repozytorium `https://github.com/msc-mwc-community/MyMP`, porównuje sumy SHA-256
plików i pobiera wyłącznie te, które różnią się od lokalnej wersji. Osobny
`MyMPUpdater.exe` czeka, aż launcher się zamknie, weryfikuje pliki,
robi kopie zapasowe, podmienia je i uruchamia launcher ponownie. Gra i launcher
nie aktualizują plików moda w trakcie działania gry.

Kanał aktualizacji korzysta z publicznego pliku
`https://raw.githubusercontent.com/msc-mwc-community/MyMP/main/updates/update-manifest.json`.
Dodaj tam wygenerowany manifest. Pierwszą wersję z włączonym kanałem użytkownicy
pobiorą ręcznie; późniejsze wydania będą mogły aktualizować się z poziomu launchera.

Przygotowanie manifestu dla wydania (uruchom z PowerShella w folderze projektu,
po zbudowaniu paczki):

```powershell
.\New-MyMPUpdateManifest.ps1 `
  -PackageDirectory '.\build\launcher' `
  -Version '0.53.0' `
  -DownloadBaseUrl 'https://github.com/msc-mwc-community/MyMP/releases/download/v0.53.0' `
  -Notes 'Stability fixes and multiplayer improvements.' `
  -OutputPath '.\updates\update-manifest.json'
```

Wgraj osiem plików wymienionych przez skrypt jako zasoby wydania GitHub,
a wygenerowany manifest umieść w `updates/update-manifest.json` gałęzi `main`.
Pełny ZIP z paczki służy do pierwszej ręcznej instalacji; aktualizator zostaje
w nim i nie jest pobierany ponownie przy zwykłych wydaniach. Nie zmieniaj nazw
plików w manifeście;
launcher dopuszcza wyłącznie pliki MyMP i odrzuci wpisy bez poprawnej sumy SHA-256
lub linku HTTPS.

Przed kolejnym wydaniem zmień `<Version>` w `Launcher\MyMP.Launcher.csproj`
(na przykład na `0.53.0`), przebuduj paczkę i użyj tej samej wartości w manifeście.
Wersja widoczna w launcherze i porównywana przy aktualizacji jest pobierana z tego
jednego ustawienia.

