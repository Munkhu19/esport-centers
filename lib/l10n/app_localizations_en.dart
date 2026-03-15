// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'E-Sport Center';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get loginTitle => 'E-SPORT CENTER';

  @override
  String get username => 'Username';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Sign up';

  @override
  String get switchToSignUp => 'Don\'t have an account? Sign up';

  @override
  String get switchToSignIn => 'Already have an account? Sign in';

  @override
  String get accountCreated => 'Account created successfully. Please sign in.';

  @override
  String get usernameAlreadyExists => 'This email is already in use.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get authInvalidEmail => 'Invalid email address.';

  @override
  String get authEmailPasswordNotEnabled => 'Email/Password sign-in is disabled in Firebase.';

  @override
  String get authUserDisabled => 'This account has been disabled.';

  @override
  String get authTooManyRequests => 'Too many attempts. Try again later.';

  @override
  String get authApiKeyInvalid => 'Firebase API key is invalid for this app.';

  @override
  String get authFirebaseNotInitialized => 'Firebase is not initialized correctly.';

  @override
  String get authWeakPassword => 'Password is too weak.';

  @override
  String get authNetworkError => 'Network error. Please check your internet.';

  @override
  String get authUnknownError => 'Authentication failed. Please try again.';

  @override
  String get login => 'Login';

  @override
  String get invalidCredentials => 'Invalid username or password';

  @override
  String get centersTitle => 'E-SPORT CENTERS';

  @override
  String get homeTab => 'Home';

  @override
  String get searchCenterHint => 'Search center...';

  @override
  String get noCentersFound => 'No centers found';

  @override
  String get mapTitle => 'Center Map';

  @override
  String get mapTab => 'Map';

  @override
  String get bookingHistoryTitle => 'Booking History';

  @override
  String addressLabel(Object address) {
    return 'Address: $address';
  }

  @override
  String pcCountLabel(Object count) {
    return 'PC count: $count';
  }

  @override
  String pcSpecLabel(Object spec) {
    return 'PC spec: $spec';
  }

  @override
  String pricePerHourLabel(Object price) {
    return 'Price: $price₮ / hour';
  }

  @override
  String phoneLabel(Object phone) {
    return 'Phone: $phone';
  }

  @override
  String get selectPcSeats => 'Select PC Seats';

  @override
  String get makeBooking => 'Make Booking';

  @override
  String selectSeatsTitle(Object center) {
    return 'Select Seats - $center';
  }

  @override
  String get bookingTitle => 'Booking';

  @override
  String get fillAllFields => 'Please fill all fields.';

  @override
  String get selectAtLeastOneSeat => 'Please select at least one PC seat.';

  @override
  String get invalidPlayDuration => 'Play duration must be a positive number.';

  @override
  String get bookingConfirmed => 'Booking Confirmed';

  @override
  String bookingSummary(Object center, Object seats, Object time) {
    return '$center\\nSeats: $seats\\nTime: $time';
  }

  @override
  String get ok => 'OK';

  @override
  String get noneSelected => 'None';

  @override
  String centerLabel(Object center) {
    return 'Center: $center';
  }

  @override
  String selectedSeatsLabel(Object seats) {
    return 'Selected seats: $seats';
  }

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get phoneMustBe8Digits => 'Phone number must be exactly 8 digits.';

  @override
  String get playDurationHours => 'Play duration (hours)';

  @override
  String get confirmBooking => 'Confirm Booking';

  @override
  String totalPriceLabel(Object price) {
    return 'Total: $price₮';
  }

  @override
  String bookingReceipt(Object center, Object seats, Object hours, Object pricePerHour, Object totalPrice) {
    return '$center\\nSeats: $seats\\nHours: $hours\\nPrice/hour: $pricePerHour₮\\nTotal: $totalPrice₮';
  }

  @override
  String get cancelBookingTitle => 'Cancel Booking';

  @override
  String cancelBookingQuestion(Object center) {
    return 'Cancel booking for $center?';
  }

  @override
  String get no => 'No';

  @override
  String get yesCancel => 'Yes, cancel';

  @override
  String get bookingCanceled => 'Booking canceled.';

  @override
  String get bookingAlreadyCanceled => 'Booking already canceled.';

  @override
  String get noBookingHistory => 'No booking history yet.';

  @override
  String get statusCanceled => 'Canceled';

  @override
  String get statusActive => 'Active';

  @override
  String customerLabel(Object name) {
    return 'Customer: $name';
  }

  @override
  String durationLabel(Object hours) {
    return 'Duration: $hours hour(s)';
  }

  @override
  String seatsLabel(Object seats) {
    return 'Seats: $seats';
  }

  @override
  String createdLabel(Object date) {
    return 'Created: $date';
  }

  @override
  String canceledLabel(Object date) {
    return 'Canceled: $date';
  }

  @override
  String get cancelBookingAction => 'Cancel Booking';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileNotSignedIn => 'Not signed in';

  @override
  String get profileNoDisplayName => 'No display name';

  @override
  String profileUidLabel(Object uid) {
    return 'UID: $uid';
  }

  @override
  String get profileDisplayNameLabel => 'Display name';

  @override
  String get profileSaveButton => 'Save profile';

  @override
  String get profileAvatarUpload => 'Upload avatar';

  @override
  String get profileAvatarUpdated => 'Avatar updated';

  @override
  String get profileAvatarUpdateFailed => 'Failed to upload avatar';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get profileUpdateFailed => 'Failed to update profile';

  @override
  String get logout => 'Log out';

  @override
  String profileLastSignInLabel(Object date) {
    return 'Last sign-in: $date';
  }
}
