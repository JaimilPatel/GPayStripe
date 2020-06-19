import 'localization.dart';

class LocalizationEN implements Localization {
  @override
  String get confirmDialogTitle => "Are You Sure To Confirm Payment?";

  @override
  String get payTo => "Pay To";

  @override
  String get cancel => "Cancel";

  @override
  String get confirm => "Confirm";

  @override
  String get successPaymentStatus => "Payment Successful";

  @override
  String get paymentSuccessStatus => "succeeded";

  @override
  String get cancelStatus => "canceled";

  @override
  String get cancelPaymentStatus => "Payment Canceled";
}
