# Ghid de rulare a aplicației SmartPark

  

Acest document oferă un ghid pas cu pas pentru pregătirea mediului de dezvoltare și rularea aplicației SmartPark.

#### :warning: ATENȚIE :warning: aplicația SmartPark NU a fost testată pe dispozitive iOS, respectiv configuratia acesteia nu suportă momentan rularea aplicației de pe macOS.

## Pregătirea mediului de dezvoltare

  

1.  **Instalare Flutter SDK**:

- Accesați site-ul oficial Flutter la adresa [https://flutter.dev](https://flutter.dev).

- Selectați sistemul de operare pe care îl utilizați și descărcați kitul de dezvoltare Flutter corespunzător.

- Extrageți conținutul arhivei într-o locație preferată pe disc.

- Adăugați calea la directorul `flutter/bin` la variabila de mediu `PATH` a sistemului.

  

2.  **Instalare dependințe**:

- Pentru a rula aplicații Flutter, aveți nevoie de un editor de cod, de exemplu, Visual Studio Code, Android Studio sau IntelliJ IDEA. Instalați editorul preferat pe sistemul dumneavoastră.

- Configurați editorul pentru a utiliza extensia pentru Flutter corespunzătoare editorului ales, pentru a beneficia de facilități suplimentare de dezvoltare.

  

3.  **Verificarea instalării**:

- Deschideți o fereastră terminal sau linie de comandă.

- Rulați comanda `flutter doctor` pentru a verifica instalarea corectă a SDK-ului Flutter și a dependințelor necesare.

- Dacă există probleme, urmați indicațiile oferite pentru a le rezolva.

  

## Rularea aplicației SmartPark

  

1.  **Obținerea codului sursă**:

- Descărcați sau clonați sursa aplicației SmartPark.
`git clone https://github.com/stefan-chivu/smartpark.git`
  

2.  **Conectarea dispozitivului**:

- Pentru a rula aplicația pe un dispozitiv fizic, asigurați-vă că acesta este conectat la computer și are opțiunea de deblocare a dezvoltatorului activată.

- Pentru a rula aplicația pe un emulator, asigurați-vă că aveți un emulator configurat și pornit înainte de a trece la următorul pas. Spre exemplu, pentru Android, acesta poate fi configurat prin intermediul pașilor specificați la secțiunea **"Configurarea unui emulator de Android"**.

3.  **Rularea aplicației**:

- Navigați în directorul proiectului SmartPark utilizând fereastra terminalului sau linia de comandă.

- Rulați comanda `flutter pub get` pentru obținerea pachetelor de care depinde aplicația.

- Rulați comanda `flutter run`.

- Așteptați finalizarea procesului de compilare și instalare a aplicației pe dispozitivul sau emulatorul selectat.

4.  **Vizualizarea aplicației**:

- Odată ce aplicația SmartPark a fost instalată cu succes, aceasta va fi deschisă automat pe dispozitivul sau emulatorul selectat.

- În acest moment, puteți explora și utiliza toate funcționalitățile oferite de aplicația SmartPark.

## Configurarea unui emulator de Android

1. **Deschiderea Android Studio**: 
   - Lansați Android Studio și așteptați până când acesta se încarcă complet.

2. **Accesarea meniului AVD Manager**: 
   - În bara de meniu, faceți clic pe "Tools" (Unelte) și selectați "AVD Manager" (Gestionar AVD).

3. **Crearea unui nou emulator**: 
   - În fereastra "AVD Manager", faceți clic pe butonul "Create Virtual Device" (Creați dispozitiv virtual).
   - Alegeți un dispozitiv virtual predefinit sau faceți clic pe "New Hardware Profile" (Profil hardware nou) pentru a personaliza setările.
   - Selectați o versiune de Android de pe lista "Recommended" (Recomandate) sau faceți clic pe "Download" (Descărcare) pentru a descărca o versiune nouă.
   - Faceți clic pe "Next" (Înainte) și atribuiți un nume emulatorului.
   - Alegeți o imagine de sistem și faceți clic pe "Next" (Înainte).
   - Configurați opțiunile suplimentare, cum ar fi memoria RAM și mărimea ecranului, și faceți clic pe "Finish" (Finalizare).

4. **Pornirea emulatorului**: 
   - În fereastra "AVD Manager", faceți clic dreapta pe emulatorul creat și selectați "Start" (Pornire).
   - Așteptați până când emulatorul se pornește și încarcă complet sistemul de operare Android.

5. **Verificarea emulatorului**: 
   - Puteți verifica starea emulatorului în fereastra "AVD Manager". Dacă starea este "Launched" (Lansat), înseamnă că emulatorul este funcțional și pregătit pentru utilizare.

6. **Rularea aplicației pe emulator**: 
   - În timp ce emulatorul este pornit, deschideți o fereastră terminal sau linie de comandă.
   - Navigați în directorul proiectului Flutter și rulați comanda `flutter run`.
   - Selectați emulatorul din lista dispozitivelor disponibile și așteptați până când aplicația se compilează și se instalează pe emulator.

7. **Vizualizarea aplicației**: 
   - Odată ce aplicația s-a instalat cu succes pe emulator, aceasta va fi deschisă automat și puteți testa și utiliza funcționalitățile în cadrul emulatorului.
