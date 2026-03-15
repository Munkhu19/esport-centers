// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Mongolian (`mn`).
class AppLocalizationsMn extends AppLocalizations {
  AppLocalizationsMn([String locale = 'mn']) : super(locale);

  @override
  String get appTitle => 'E-Sport Төв';

  @override
  String get changeLanguage => 'Хэл солих';

  @override
  String get loginTitle => 'E-SPORT ТӨВ';

  @override
  String get username => 'Нэвтрэх нэр';

  @override
  String get email => 'И-мэйл';

  @override
  String get password => 'Нууц үг';

  @override
  String get confirmPassword => 'Нууц үг давтах';

  @override
  String get signIn => 'Нэвтрэх';

  @override
  String get signUp => 'Бүртгүүлэх';

  @override
  String get switchToSignUp => 'Бүртгэлгүй юу? Бүртгүүлэх';

  @override
  String get switchToSignIn => 'Бүртгэлтэй юу? Нэвтрэх';

  @override
  String get accountCreated => 'Бүртгэл амжилттай үүслээ. Нэвтэрч орно уу.';

  @override
  String get usernameAlreadyExists => 'Энэ и-мэйл аль хэдийн бүртгэлтэй байна.';

  @override
  String get passwordsDoNotMatch => 'Нууц үг хоорондоо таарахгүй байна.';

  @override
  String get authInvalidEmail => 'И-мэйл буруу байна.';

  @override
  String get authEmailPasswordNotEnabled => 'Firebase дээр Email/Password нэвтрэх арга идэвхгүй байна.';

  @override
  String get authUserDisabled => 'Энэ бүртгэл идэвхгүй болсон байна.';

  @override
  String get authTooManyRequests => 'Хэт олон оролдлого хийлээ. Түр хүлээгээд дахин оролдоно уу.';

  @override
  String get authApiKeyInvalid => 'Firebase API key энэ апп дээр буруу байна.';

  @override
  String get authFirebaseNotInitialized => 'Firebase инициализаци буруу байна.';

  @override
  String get authWeakPassword => 'Нууц үг хэт сул байна.';

  @override
  String get authNetworkError => 'Сүлжээний алдаа. Интернэтээ шалгана уу.';

  @override
  String get authUnknownError => 'Нэвтрэх үйлдэл амжилтгүй боллоо. Дахин оролдоно уу.';

  @override
  String get login => 'Нэвтрэх';

  @override
  String get invalidCredentials => 'Нэвтрэх нэр эсвэл нууц үг буруу байна';

  @override
  String get centersTitle => 'E-SPORT ТӨВҮҮД';

  @override
  String get homeTab => 'Нүүр';

  @override
  String get searchCenterHint => 'Төв хайх...';

  @override
  String get noCentersFound => 'Төв олдсонгүй';

  @override
  String get mapTitle => 'Төвүүдийн газрын зураг';

  @override
  String get mapTab => 'Газрын зураг';

  @override
  String get bookingHistoryTitle => 'Захиалгын түүх';

  @override
  String addressLabel(Object address) {
    return 'Хаяг: $address';
  }

  @override
  String pcCountLabel(Object count) {
    return 'PC тоо: $count';
  }

  @override
  String pcSpecLabel(Object spec) {
    return 'PC үзүүлэлт: $spec';
  }

  @override
  String pricePerHourLabel(Object price) {
    return 'Үнэ: $price₮ / цаг';
  }

  @override
  String phoneLabel(Object phone) {
    return 'Утас: $phone';
  }

  @override
  String get selectPcSeats => 'PC суудал сонгох';

  @override
  String get makeBooking => 'Захиалга хийх';

  @override
  String selectSeatsTitle(Object center) {
    return 'Суудал сонгох - $center';
  }

  @override
  String get bookingTitle => 'Захиалга';

  @override
  String get fillAllFields => 'Бүх талбарыг бөглөнө үү.';

  @override
  String get selectAtLeastOneSeat => 'Дор хаяж нэг PC суудал сонгоно уу.';

  @override
  String get invalidPlayDuration => 'Тоглох хугацаа 1-ээс их тоо байх ёстой.';

  @override
  String get bookingConfirmed => 'Захиалга баталгаажлаа';

  @override
  String bookingSummary(Object center, Object seats, Object time) {
    return '$center\\nСуудал: $seats\\nЦаг: $time';
  }

  @override
  String get ok => 'Ойлголоо';

  @override
  String get noneSelected => 'Сонгогдоогүй';

  @override
  String centerLabel(Object center) {
    return 'Төв: $center';
  }

  @override
  String selectedSeatsLabel(Object seats) {
    return 'Сонгосон суудал: $seats';
  }

  @override
  String get name => 'Нэр';

  @override
  String get phone => 'Утас';

  @override
  String get phoneMustBe8Digits => 'Утасны дугаар 8 оронтой байх ёстой.';

  @override
  String get playDurationHours => 'Тоглох хугацаа (цаг)';

  @override
  String get confirmBooking => 'Захиалга батлах';

  @override
  String totalPriceLabel(Object price) {
    return 'Нийт: $price₮';
  }

  @override
  String bookingReceipt(Object center, Object seats, Object hours, Object pricePerHour, Object totalPrice) {
    return '$center\\nСуудал: $seats\\nЦаг: $hours\\nЦагийн үнэ: $pricePerHour₮\\nНийт: $totalPrice₮';
  }

  @override
  String get cancelBookingTitle => 'Захиалга цуцлах';

  @override
  String cancelBookingQuestion(Object center) {
    return '$center төвийн захиалгыг цуцлах уу?';
  }

  @override
  String get no => 'Үгүй';

  @override
  String get yesCancel => 'Тийм, цуцлах';

  @override
  String get bookingCanceled => 'Захиалга цуцлагдлаа.';

  @override
  String get bookingAlreadyCanceled => 'Энэ захиалга өмнө нь цуцлагдсан байна.';

  @override
  String get noBookingHistory => 'Захиалгын түүх хоосон байна.';

  @override
  String get statusCanceled => 'Цуцлагдсан';

  @override
  String get statusActive => 'Идэвхтэй';

  @override
  String customerLabel(Object name) {
    return 'Захиалагч: $name';
  }

  @override
  String durationLabel(Object hours) {
    return 'Хугацаа: $hours цаг';
  }

  @override
  String seatsLabel(Object seats) {
    return 'Суудал: $seats';
  }

  @override
  String createdLabel(Object date) {
    return 'Үүсгэсэн: $date';
  }

  @override
  String canceledLabel(Object date) {
    return 'Цуцалсан: $date';
  }

  @override
  String get cancelBookingAction => 'Захиалга цуцлах';

  @override
  String get profileTitle => 'Профайл';

  @override
  String get profileNotSignedIn => 'Нэвтрээгүй байна';

  @override
  String get profileNoDisplayName => 'Харуулах нэр оноогоүй';

  @override
  String profileUidLabel(Object uid) {
    return 'UID: $uid';
  }

  @override
  String get profileDisplayNameLabel => 'Харуулах нэр';

  @override
  String get profileSaveButton => 'Профайл хадгалах';

  @override
  String get profileAvatarUpload => 'Аватар оруулах';

  @override
  String get profileAvatarUpdated => 'Аватар амжилттай шинэчлэгдлээ';

  @override
  String get profileAvatarUpdateFailed => 'Аватар оруулахад алдаа гарлаа';

  @override
  String get profileUpdated => 'Профайл амжилттай шинэчлэгдлээ';

  @override
  String get profileUpdateFailed => 'Профайл шинэчлэхэд алдаа гарлаа';

  @override
  String get logout => 'Гарах';

  @override
  String profileLastSignInLabel(Object date) {
    return 'Сүүлд нэвтэрсэн: $date';
  }
}
