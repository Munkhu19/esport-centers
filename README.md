# pc_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase Firestore Rules (Center Admin + Customer)

This project includes security rules in `firestore.rules` for:

- `super_admin`: full access
- `center_admin`: manage seats and center data for assigned `centerId`
- `customer`: read data, create own bookings, book/release own seats

### Required user profile format

Create one document per authenticated user:

- Collection: `users`
- Document ID: Firebase Auth `uid`
- Fields:
  - `role`: `super_admin` | `center_admin` | `customer`
  - `centerId`: required only for `center_admin`

### Deploy rules

1. Install Firebase CLI:
   - `npm i -g firebase-tools`
2. Login:
   - `firebase login`
3. Init Firebase in this project (first time):
   - `firebase init firestore`
   - When asked for rules file, choose `firestore.rules`
4. Deploy rules:
   - `firebase deploy --only firestore:rules`
