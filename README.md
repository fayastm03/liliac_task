

# Expenzia – Personal Expense Tracker

Expenzia is a Flutter-based personal finance application designed to help
users track their income, manage expenses, and monitor their spending
through a simple and user-friendly interface.

## Features

- **Dashboard:** View total balance, total income, total expenses, daily
  average spending, weekly spending, and recent transactions.
- **Transaction Management:** Add, view, edit, and delete transactions.
- **Transaction History:** Review recorded financial transactions.
- **Credit Management:** Record and manage credit entries.
- **Profile:** Manage profile information and profile photo.
- **Local Database:** Store application data using SQLite.
- **Custom Navigation:** Navigate between Home, History, Credit, and
  Profile using a custom bottom navigation bar.
- **Refresh Support:** Refresh transaction data on the dashboard.

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **State Management:** Provider
- **Database:** SQLite using sqflite
- **Local Database Utilities:** path
- **Date Formatting:** intl
- **Image Selection:** image_picker

## Project Structure

```text
lib/
├── core/
│   └── database/
│       └── app_database.dart
├── features/
│   ├── dashboard/
│   │   └── screens/
│   ├── transactions/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   └── screens/
│   ├── credit/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── screens/
│   └── profile/
│       ├── repositories/
│       └── screens/
├── shared/
│   └── widgets/
│       └── app_bottom_navigation.dart
├── app.dart
└── main.dart
```

*The directory tree represents the main feature areas; individual files
may vary as development continues.*

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK (included with Flutter)
- Android Studio or Visual Studio Code
- An Android emulator, iOS Simulator, or compatible device
- Xcode for iOS development on macOS

### 1. Clone the Repository

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd <YOUR_PROJECT_FOLDER>
```

Replace the placeholders with your repository URL and project folder name.

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Check Your Flutter Setup

```bash
flutter doctor
```

### 4. Run the Application

```bash
flutter run
```

### 5. Analyze the Code

```bash
flutter analyze
```

### 6. Format the Code

```bash
dart format lib
```

## Data Storage

Expenzia uses SQLite for local data persistence.

The database manages transaction records and credit entries. Profile
information and the profile photo can also be stored locally in SQLite.

The application is designed around local data storage and does not
require a remote backend for its core transaction features.

## Transaction Calculations

The dashboard displays income, expenses, balance, and spending summaries
based on recorded transaction data.

The current daily average and weekly spending cards use expense records
from the last seven calendar days, including today.

## Future Improvements

- Monthly spending reports
- Expense category charts
- Budget creation and tracking
- Export transactions to CSV or PDF
- Search and filter improvements
- Automated testing and expanded error handling

## Contributing

1. Create a feature branch.
2. Make your changes.
3. Run `dart format lib`.
4. Run `flutter analyze`.
5. Commit your changes and push your branch.
6. Open a pull request for review.

## License

No license has been specified yet. All rights are reserved unless a
license is added to this repository.
EOF
