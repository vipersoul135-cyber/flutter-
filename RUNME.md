# Campus Bus Live - How to Run

## Quick Start

Simply run the custom `flutter.bat` file:

```cmd
flutter
```

or double-click `flutter.bat` in this folder.

It will show a menu to choose where to run:
- **1** - Chrome (Web) - Default, works immediately
- **2** - Windows Desktop
- **3** - Android (needs emulator or device)
- **4** - iOS (Mac only)
- **5** - Get dependencies only

---

## Alternative: Run Menu (GUI-style)

Double-click `run.bat` for a simpler menu interface.

---

## Alternative: Direct Commands

If you know what you're doing, you can use Flutter directly:

```cmd
C:\flutter\bin\flutter.bat run -d chrome   # Web
C:\flutter\bin\flutter.bat run -d windows   # Windows
C:\flutter\bin\flutter.bat run -d android   # Android
```

---

## First Time Setup

1. Install Flutter SDK to `C:\flutter` 
   - Download from: https://flutter.dev

2. Get dependencies:
   ```cmd
   flutter 5
   ```
   or
   ```cmd
   C:\flutter\bin\flutter.bat pub get
   ```

3. Run the app:
   ```cmd
   flutter
   ```

---

## Notes

- The app runs in **Demo Mode** by default (no Firebase required)
- For Google Maps to work, add your API key in:
  `android/app/src/main/AndroidManifest.xml`