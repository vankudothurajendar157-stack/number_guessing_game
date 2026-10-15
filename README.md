# System Number Guessing Game (Flutter Android & Web)

An intelligent Flutter mobile game where the human player secretly chooses a number in their mind, and the AI computer guesses it using an optimal **Binary Search** algorithm based on human feedback.

---

## 📱 Features

1. **AI Binary-Search Guessing Engine**:
   - Computes midpoint using pure integer arithmetic: `currentGuess = low + ((high - low) ~/ 2)`.
   - Guaranteed to find any chosen secret number within optimal ceiling $\lceil \log_2(N) \rceil$ guesses:
     - **Easy (1–20)**: Guaranteed in $\le 5$ guesses.
     - **Medium (1–50)**: Guaranteed in $\le 6$ guesses.
     - **Hard (1–100)**: Guaranteed in $\le 7$ guesses.

2. **Feedback Buttons**:
   - **TOO LOW** (Secret number is higher than guess).
   - **TOO HIGH** (Secret number is lower than guess).
   - **CORRECT** (Guessed successfully; ends round and reveals celebratory screen).

3. **Contradiction Detection & Recovery**:
   - Identifies impossible feedback sequences (e.g. saying "Too Low" when the guess is at the maximum remaining bound).
   - Prevents empty ranges ($low > high$).
   - Explains exactly why the response is impossible.
   - Provides **RECOVER** (undo contradiction without losing previous steps) and **RESTART** options.

4. **Guess History**:
   - Step-by-step chronological log showing every guess and feedback chip.
   - Undo support allows reverting accidental taps.

5. **Continuous Replay & Mental Number Selection**:
   - The player selects a secret number mentally without typing or revealing it anywhere.
   - Screen displays "Think of a new secret number!" with the valid range and a "START GUESSING" button.
   - After victory ("🎉 I guessed your number!"), tap **"PLAY AGAIN — CHOOSE A NEW NUMBER"** to start the next round immediately.
   - Resets all range bounds, binary search midpoint, guess count, and history cleanly.

6. **Material 3 UI / UX**:
   - Light lavender background (`#F7F3FB`) with deep purple primary palette (`#4A148C`).
   - Rounded cards, clear badge indicators, and large readable guess numbers (68sp).
   - Debounce protection against rapid double-taps.

---

## 📂 Project Architecture

```
lib/
├── main.dart                      # App entry point & Material 3 Theme setup
├── models/
│   ├── difficulty_level.dart      # Easy (1-20), Medium (1-50), Hard (1-100)
│   └── guess_entry.dart           # Feedback types & History item models
├── logic/
│   └── guessing_game_engine.dart  # Pure Dart binary-search engine & contradiction handler
└── screens/
    ├── difficulty_screen.dart     # Difficulty selector & How-to-play guide
    └── game_screen.dart           # Active gameplay, feedback controls & victory card
test/
├── guessing_game_engine_test.dart # 13 deterministic algorithmic & edge-case unit tests
└── widget_test.dart               # 2 full UI integration & contradiction widget tests
```

---

## 🧪 Testing

Run all unit and widget tests:
```bash
flutter test
```

Run static analysis:
```bash
flutter analyze
```

---

## 🚀 Running the App

### Option 1: Run in Chrome/Edge (Instant Preview)
```bash
flutter run -d chrome
```

### Option 2: Run on Connected Android Device or Emulator
```bash
flutter run -d android
```

### Option 3: Build Android Release APK
```bash
flutter build apk --release
```
Output location:
`build/app/outputs/flutter-apk/app-release.apk`
