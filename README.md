# Pharmacy POS - Multi-Tenant SaaS Application

A production-ready Flutter application for pharmacy management and point-of-sale operations.

## Architecture

This project follows **Clean Architecture** principles with:

- **Presentation Layer**: UI + BLoC (State Management)
- **Domain Layer**: Entities, Use Cases, Repository Interfaces
- **Data Layer**: API Services, Models (DTOs), Repository Implementations

## Features

- ✅ Multi-tenant support
- ✅ JWT Authentication
- ✅ Role-based access control (Admin, Manager, Cashier)
- ✅ Product & Inventory Management
- ✅ Sales/POS System
- ✅ Purchase Management
- ✅ Reports & Analytics
- ✅ Notifications & Alerts
- ✅ Subscription Billing
- ✅ Offline-safe UI
- ✅ Dark Theme Support
- ✅ Localization Support

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate code (for models, API services):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/              # Core utilities, themes, network, etc.
├── data/              # Data layer (API, models, repositories)
├── domain/            # Domain layer (entities, use cases, repositories)
├── presentation/      # Presentation layer (BLoC, UI)
└── main.dart          # App entry point
```

## Testing

Run tests with:
```bash
flutter test
```

## License

This project is proprietary software.

