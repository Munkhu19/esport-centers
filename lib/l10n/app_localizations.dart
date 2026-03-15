import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_mn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('mn')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'E-Sport Center'**
  String get appTitle;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'E-SPORT CENTER'**
  String get loginTitle;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @switchToSignUp.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get switchToSignUp;

  /// No description provided for @switchToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get switchToSignIn;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully. Please sign in.'**
  String get accountCreated;

  /// No description provided for @usernameAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use.'**
  String get usernameAlreadyExists;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @authInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address.'**
  String get authInvalidEmail;

  /// No description provided for @authEmailPasswordNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Email/Password sign-in is disabled in Firebase.'**
  String get authEmailPasswordNotEnabled;

  /// No description provided for @authUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get authUserDisabled;

  /// No description provided for @authTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get authTooManyRequests;

  /// No description provided for @authApiKeyInvalid.
  ///
  /// In en, this message translates to:
  /// **'Firebase API key is invalid for this app.'**
  String get authApiKeyInvalid;

  /// No description provided for @authFirebaseNotInitialized.
  ///
  /// In en, this message translates to:
  /// **'Firebase is not initialized correctly.'**
  String get authFirebaseNotInitialized;

  /// No description provided for @authWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak.'**
  String get authWeakPassword;

  /// No description provided for @authNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet.'**
  String get authNetworkError;

  /// No description provided for @authUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get authUnknownError;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get invalidCredentials;

  /// No description provided for @centersTitle.
  ///
  /// In en, this message translates to:
  /// **'E-SPORT CENTERS'**
  String get centersTitle;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @searchCenterHint.
  ///
  /// In en, this message translates to:
  /// **'Search center...'**
  String get searchCenterHint;

  /// No description provided for @noCentersFound.
  ///
  /// In en, this message translates to:
  /// **'No centers found'**
  String get noCentersFound;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Center Map'**
  String get mapTitle;

  /// No description provided for @mapTab.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTab;

  /// No description provided for @bookingHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking History'**
  String get bookingHistoryTitle;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address: {address}'**
  String addressLabel(Object address);

  /// No description provided for @pcCountLabel.
  ///
  /// In en, this message translates to:
  /// **'PC count: {count}'**
  String pcCountLabel(Object count);

  /// No description provided for @pcSpecLabel.
  ///
  /// In en, this message translates to:
  /// **'PC spec: {spec}'**
  String pcSpecLabel(Object spec);

  /// No description provided for @pricePerHourLabel.
  ///
  /// In en, this message translates to:
  /// **'Price: {price}₮ / hour'**
  String pricePerHourLabel(Object price);

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone: {phone}'**
  String phoneLabel(Object phone);

  /// No description provided for @selectPcSeats.
  ///
  /// In en, this message translates to:
  /// **'Select PC Seats'**
  String get selectPcSeats;

  /// No description provided for @makeBooking.
  ///
  /// In en, this message translates to:
  /// **'Make Booking'**
  String get makeBooking;

  /// No description provided for @selectSeatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Seats - {center}'**
  String selectSeatsTitle(Object center);

  /// No description provided for @bookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get bookingTitle;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields.'**
  String get fillAllFields;

  /// No description provided for @selectAtLeastOneSeat.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one PC seat.'**
  String get selectAtLeastOneSeat;

  /// No description provided for @invalidPlayDuration.
  ///
  /// In en, this message translates to:
  /// **'Play duration must be a positive number.'**
  String get invalidPlayDuration;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed'**
  String get bookingConfirmed;

  /// No description provided for @bookingSummary.
  ///
  /// In en, this message translates to:
  /// **'{center}\\nSeats: {seats}\\nTime: {time}'**
  String bookingSummary(Object center, Object seats, Object time);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @noneSelected.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noneSelected;

  /// No description provided for @centerLabel.
  ///
  /// In en, this message translates to:
  /// **'Center: {center}'**
  String centerLabel(Object center);

  /// No description provided for @selectedSeatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected seats: {seats}'**
  String selectedSeatsLabel(Object seats);

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @phoneMustBe8Digits.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be exactly 8 digits.'**
  String get phoneMustBe8Digits;

  /// No description provided for @playDurationHours.
  ///
  /// In en, this message translates to:
  /// **'Play duration (hours)'**
  String get playDurationHours;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// No description provided for @totalPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Total: {price}₮'**
  String totalPriceLabel(Object price);

  /// No description provided for @bookingReceipt.
  ///
  /// In en, this message translates to:
  /// **'{center}\\nSeats: {seats}\\nHours: {hours}\\nPrice/hour: {pricePerHour}₮\\nTotal: {totalPrice}₮'**
  String bookingReceipt(Object center, Object seats, Object hours, Object pricePerHour, Object totalPrice);

  /// No description provided for @cancelBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBookingTitle;

  /// No description provided for @cancelBookingQuestion.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking for {center}?'**
  String cancelBookingQuestion(Object center);

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, cancel'**
  String get yesCancel;

  /// No description provided for @bookingCanceled.
  ///
  /// In en, this message translates to:
  /// **'Booking canceled.'**
  String get bookingCanceled;

  /// No description provided for @bookingAlreadyCanceled.
  ///
  /// In en, this message translates to:
  /// **'Booking already canceled.'**
  String get bookingAlreadyCanceled;

  /// No description provided for @noBookingHistory.
  ///
  /// In en, this message translates to:
  /// **'No booking history yet.'**
  String get noBookingHistory;

  /// No description provided for @statusCanceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get statusCanceled;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @customerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer: {name}'**
  String customerLabel(Object name);

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration: {hours} hour(s)'**
  String durationLabel(Object hours);

  /// No description provided for @seatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Seats: {seats}'**
  String seatsLabel(Object seats);

  /// No description provided for @createdLabel.
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String createdLabel(Object date);

  /// No description provided for @canceledLabel.
  ///
  /// In en, this message translates to:
  /// **'Canceled: {date}'**
  String canceledLabel(Object date);

  /// No description provided for @cancelBookingAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBookingAction;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get profileNotSignedIn;

  /// No description provided for @profileNoDisplayName.
  ///
  /// In en, this message translates to:
  /// **'No display name'**
  String get profileNoDisplayName;

  /// No description provided for @profileUidLabel.
  ///
  /// In en, this message translates to:
  /// **'UID: {uid}'**
  String profileUidLabel(Object uid);

  /// No description provided for @profileDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get profileDisplayNameLabel;

  /// No description provided for @profileSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get profileSaveButton;

  /// No description provided for @profileAvatarUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload avatar'**
  String get profileAvatarUpload;

  /// No description provided for @profileAvatarUpdated.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated'**
  String get profileAvatarUpdated;

  /// No description provided for @profileAvatarUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload avatar'**
  String get profileAvatarUpdateFailed;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get profileUpdateFailed;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @profileLastSignInLabel.
  ///
  /// In en, this message translates to:
  /// **'Last sign-in: {date}'**
  String profileLastSignInLabel(Object date);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'mn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'mn': return AppLocalizationsMn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
