import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:googlepaystripe/home/model/cancel_payment_info.dart';
import 'package:googlepaystripe/home/model/confirm_payment_info.dart';
import 'package:googlepaystripe/home/model/payment_intent_info.dart';
import 'package:googlepaystripe/utils/constants/constants.dart';
import 'package:googlepaystripe/utils/progress_dialog.dart';

class StripePaymentManager {
  HttpsCallableResult paymentIntentResult,
      confirmPaymentResult,
      cancelPaymentResult;
  HttpsCallable callPaymentIntent, callConfirmPayment, callCancelPayment;
  BuildContext context;

  PaymentIntentInfo __paymentInfoFromStripe(HttpsCallableResult intentInfo) {
    return intentInfo != null
        ? PaymentIntentInfo(
            paymentIntentId: intentInfo.data[paymentIntentIdKey],
            paymentMethodId: intentInfo.data[paymentMethodIdKey])
        : null;
  }

  ConfirmPaymentInfo __confirmPaymentInfoFromStripe(
      HttpsCallableResult confirmInfo) {
    return confirmInfo != null
        ? ConfirmPaymentInfo(paymentStatus: confirmInfo.data[paymentStatusKey])
        : null;
  }

  CancelPaymentInfo __cancelPaymentInfoFromStripe(
      HttpsCallableResult cancelInfo) {
    return cancelInfo != null
        ? CancelPaymentInfo(cancelStatus: cancelInfo.data[cancelStatusKey])
        : null;
  }

  //Call Create Payment Method and Create Payment Intent Stripe API
  Future startCreatePayment(BuildContext context, double totalAmount,
      String currencyName, String token) async {
    callPaymentIntent = CloudFunctions(region: europeRegion)
        .getHttpsCallable(functionName: createPaymentMethod);
    ProgressDialogUtils.showProgressDialog(context);
    try {
      paymentIntentResult = await callPaymentIntent.call(<String, dynamic>{
        amountKey: totalAmount,
        currencyKey: currencyName.toLowerCase(),
        tokenKey: token
      });
      ProgressDialogUtils.dismissProgressDialog();
      return __paymentInfoFromStripe(paymentIntentResult);
    } on CloudFunctionsException catch (e) {
      print(e.code);
      print(e.message);
      print(e.details);
    } catch (e) {
      print(e);
    }
  }

  //Call Confirm PaymentIntent Stripe API
  Future confirmPaymentIntent(
      BuildContext context, String intentId, String methodId) async {
    callConfirmPayment = CloudFunctions(region: europeRegion)
        .getHttpsCallable(functionName: confirmPaymentMethod);
    ProgressDialogUtils.showProgressDialog(context);
    try {
      confirmPaymentResult = await callConfirmPayment.call(<String, dynamic>{
        paymentIntentIdKey: intentId,
        paymentMethodIdKey: methodId,
      });
      ProgressDialogUtils.dismissProgressDialog();
      return __confirmPaymentInfoFromStripe(confirmPaymentResult);
    } on CloudFunctionsException catch (e) {
      print(e.code);
      print(e.message);
      print(e.details);
    } catch (e) {
      print(e);
    }
  }

  //Call Cancel PaymentIntent Stripe API
  Future cancelPayment(BuildContext context, String intentId) async {
    try {
      callCancelPayment = CloudFunctions(region: europeRegion)
          .getHttpsCallable(functionName: cancelPaymentMethod);
      ProgressDialogUtils.showProgressDialog(context);
      cancelPaymentResult = await callCancelPayment.call(<String, dynamic>{
        paymentIntentIdKey: intentId,
      });
      ProgressDialogUtils.dismissProgressDialog();
      return __cancelPaymentInfoFromStripe(cancelPaymentResult);
    } on CloudFunctionsException catch (e) {
      print(e.code);
      print(e.message);
      print(e.details);
    } catch (e) {
      print(e);
    }
  }
}
