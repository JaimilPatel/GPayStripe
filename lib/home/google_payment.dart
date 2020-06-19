import 'package:flutter/material.dart';
import 'package:googlepaystripe/apis/stripe_payment_manager.dart';
import 'package:googlepaystripe/home/model/cancel_payment_info.dart';
import 'package:googlepaystripe/home/model/confirm_payment_info.dart';
import 'package:googlepaystripe/home/model/payment_intent_info.dart';
import 'package:googlepaystripe/utils/constants/constants.dart';
import 'package:googlepaystripe/utils/constants/dimens.dart';
import 'package:googlepaystripe/utils/localization/localization.dart';
import 'package:googlepaystripe/utils/toast.dart';
import 'package:intl/intl.dart';
import 'package:stripe_native/stripe_native.dart';

class GooglePaymentPage extends StatefulWidget {
  @override
  _GooglePaymentPageState createState() => _GooglePaymentPageState();
}

class _GooglePaymentPageState extends State<GooglePaymentPage> {
  double totalAmount = 0;
  double amount = 0;
  String currencyName = "";
  Map receipt;
  Receipt finalReceipt;
  String generatedToken = "";
  final StripePaymentManager _stripePaymentManager = StripePaymentManager();

  @override
  void initState() {
    super.initState();
    StripeNative.setPublishableKey(publishableKey);
    StripeNative.setMerchantIdentifier(merchantIdentifier);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            googlePay,
            style: nativeTextStyle,
          ),
          centerTitle: true,
        ),
        body: Center(
          child: _buildNativeButton(),
        ));
  }

  //Native Button Widget
  Widget _buildNativeButton() {
    return Padding(
        padding: EdgeInsets.all(spacingSmall),
        child: RaisedButton(
            color: Colors.black,
            child: Text(
              googlePay,
              style: nativeTextStyle,
            ),
            onPressed: () {
              _onNativeButtonClicked();
            }));
  }

  //To Generate Token (Method Already Implemented in Plugin)
  Future<String> receiptPayment(Receipt finalReceipt) async {
    return await StripeNative.useReceiptNativePay(finalReceipt);
  }

  //Click Event Method For Google Pay Button
  _onNativeButtonClicked() async {
    currencyName = currency();
//    Below Two lines is for Example To Show How To Pass Details To receiptPayment
//    Method For Generating Token
    receipt = <String, double>{"Nice Hat": 5.00, "Used Hat": 1.50};
    finalReceipt = Receipt(receipt, "Hat Store");
    //You can pass Amount According To Your Payment
    amount = 0;
    receipt.values.forEach((element) {
      amount = amount + element;
    });
    totalAmount = amount * 100.0;
    generatedToken = await receiptPayment(finalReceipt);
    try {
      dynamic result = await _stripePaymentManager.startCreatePayment(
          context, totalAmount, currencyName, generatedToken);
      if (result is PaymentIntentInfo) {
        if (result != null) {
          confirmDialog(receipt, finalReceipt, result.paymentIntentId,
              result.paymentMethodId);
        }
      }
    } catch (e) {
      ToastUtils.showToast(e, Colors.black, Colors.white);
      return e;
    }
  }

  //To Get Locale Based Currency Name
  String currency() {
    Locale locale = Localizations.localeOf(context);
    var format = NumberFormat.simpleCurrency(locale: locale.toString());
    return format.currencyName;
  }

  //To Ask User To Confirm Payment Or Not
  confirmDialog(
      Map receipt, Receipt finalReceipt, String intentId, String methodId) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(Localization.of(context).confirmDialogTitle,
                  style: headerTextStyle),
              content: Container(
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Column(
                    children: finalReceipt.items.entries.map((e) {
                  totalAmount = totalAmount + e.value;
                  return Column(children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("${e.key}", style: titleTextStyle),
                          Text("${e.value}", style: titleContentTextStyle),
                        ])
                  ]);
                }).toList()),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                          "${Localization.of(context).payTo} ${finalReceipt.merchantName}",
                          style: headerTextStyle),
                      Text(
                        "${finalReceipt.items.values.elementAt(0) + finalReceipt.items.values.elementAt(1)}",
                        style: titleContentTextStyle,
                      )
                    ])
              ])),
              actions: <Widget>[
                RaisedButton(
                  child: Text(Localization.of(context).cancel,
                      style: cancelTextStyle),
                  onPressed: () {
                    Navigator.of(context).pop();
                    cancelPayment(intentId);
                  },
                ),
                RaisedButton(
                    child: Text(Localization.of(context).confirm,
                        style: confirmTextStyle),
                    onPressed: () {
                      Navigator.of(context).pop();
                      confirmPayment(intentId, methodId);
                    })
              ]);
        });
  }

  //To Confirm the payment process
  confirmPayment(String intentId, String methodId) async {
    try {
      dynamic result = await _stripePaymentManager.confirmPaymentIntent(
          context, intentId, methodId);
      if (result is ConfirmPaymentInfo) {
        if (result != null) {
          if (result.paymentStatus ==
              Localization.of(context).paymentSuccessStatus) {
            ToastUtils.showToast(Localization.of(context).successPaymentStatus,
                Colors.black, Colors.white);
          }
        }
      }
    } catch (e) {
      ToastUtils.showToast(e, Colors.black, Colors.white);
      return e;
    }
  }

  //To Cancel the payment process
  cancelPayment(String intentId) async {
    try {
      dynamic result =
          await _stripePaymentManager.cancelPayment(context, intentId);
      if (result is CancelPaymentInfo) {
        if (result != null) {
          if (result.cancelStatus == Localization.of(context).cancelStatus) {
            ToastUtils.showToast(Localization.of(context).cancelPaymentStatus,
                Colors.black, Colors.white);
          }
        }
      }
    } catch (e) {
      ToastUtils.showToast(e, Colors.black, Colors.white);
      return e;
    }
  }
}

//You can generate Token using this method also according to your requirement

//  Future<String> get orderPayment async {
//    // subtotal, tax, tip, merchant name
//    var order = Order(5.50, 1.0, 2.0, "Some Store");
//    return await StripeNative.useNativePay(order);
//  }
