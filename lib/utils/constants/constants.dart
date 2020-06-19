import 'package:flutter/material.dart';
import 'package:googlepaystripe/utils/constants/dimens.dart';

const String muliBoldFont = "MuliBold";
const String muliRegularFont = "MuliRegular";
const String muliMedium = "MuliMedium";
const String publishableKey = "<Your Publishable Key>";
const String merchantIdentifier = "Test";
const String europeRegion = "europe-west3";
const String createPaymentMethod = 'createPayment';
const String confirmPaymentMethod = 'confirmPayment';
const String cancelPaymentMethod = 'cancelPayment';
const String googlePay = "Google Pay";
const String amountKey = 'amount';
const String currencyKey = "currency";
const String tokenKey = "token";
const String paymentIntentIdKey = "paymentIntentId";
const String paymentMethodIdKey = "paymentMethodId";
const String paymentStatusKey = "paymentStatus";
const String cancelStatusKey = "cancelStatus";
const String error = "error";
const String routeSplash = "routeSplash";
const String routePayment = "routePayment";

const nativeTextStyle = TextStyle(
  fontSize: fontLarger,
  color: Colors.white,
  fontFamily: muliBoldFont,
  fontWeight: FontWeight.normal,
);
const titleTextStyle = TextStyle(
  fontSize: fontLarger,
  color: Colors.black,
  fontFamily: muliBoldFont,
  fontWeight: FontWeight.w500,
);
const headerTextStyle = TextStyle(
  fontSize: fontXLarge,
  color: Colors.black,
  fontFamily: muliBoldFont,
  fontWeight: FontWeight.normal,
);
const titleContentTextStyle = TextStyle(
  fontSize: fontLarger,
  color: Colors.black,
  fontFamily: muliMedium,
  fontWeight: FontWeight.normal,
);
const confirmTextStyle = TextStyle(
  fontSize: fontLarger,
  color: Colors.green,
  fontFamily: muliBoldFont,
  fontWeight: FontWeight.w500,
);
const cancelTextStyle = TextStyle(
  fontSize: fontLarger,
  color: Colors.red,
  fontFamily: muliBoldFont,
  fontWeight: FontWeight.w500,
);
