Fake News Detective
A Flutter educational game that teaches students how to identify fake news by solving cases, learning misinformation patterns, and earning achievements.
Students analyze news claims and determine whether they are REAL or FAKE using logic and clues provided by the in-app guide Stojche.
The project includes a student mode and a teacher mode where teachers can review and approve student-created cases.

Features

Student
-------
Solve fake news detection cases
Ask the in-app assistant Stojche for hints
Earn XP and unlock achievements
Maintain daily streaks
Learn misinformation patterns
Review solved cases
View leaderboard
-------

Teacher
-------
Moderate student-submitted cases
Approve or decline cases
Generate AI-based cases
View statistics about student activity
-------

Tech Stack

Flutter
Dart
Firebase Authentication
Cloud Firestore
Firebase Cloud Functions
Material Design 3

Requirements

Install the following before running the project:
Flutter SDK (3.x recommended)
Android Studio or IntelliJ IDEA
Android Emulator or physical Android device

Verify installation:

flutter doctor

1. Clone the repository

git clone https://github.com/koceskigj/fake-news-detective.git
cd fake-news-detective
2. Install dependencies

flutter pub get
All dependencies are already defined in:

pubspec.yaml

3. Generate localization files
This project uses Flutter localization (l10n).
Run:

flutter gen-l10n
If this fails, run:

flutter pub get
flutter gen-l10n

Firebase Setup
This repository does not include Firebase configuration files for security reasons.
To run the app, you must add the Firebase configuration files manually:
flutterfire configure
