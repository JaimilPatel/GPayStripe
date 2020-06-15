import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:googlepaystripe/utils/constants/constants.dart';
import 'package:googlepaystripe/utils/constants/dimens.dart';
import 'package:googlepaystripe/utils/progress_dialog.dart';
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
  HttpsCallable callPaymentIntent, callConfirmPayment;

  @override
  void initState() {
    super.initState();
    StripeNative.setPublishableKey(publishableKey);
    StripeNative.setMerchantIdentifier(merchantIdentifier);
    callPaymentIntent = new CloudFunctions(region: europeRegion)
        .getHttpsCallable(functionName: createPaymentMethod);
    callConfirmPayment = new CloudFunctions(region: europeRegion)
        .getHttpsCallable(functionName: confirmPaymentMethod);
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
          child: _buildNativeButton(callPaymentIntent, callConfirmPayment),
        ));
  }

  //Native Button Widget
  Widget _buildNativeButton(
      HttpsCallable callPaymentIntent, HttpsCallable callConfirmPayment) {
    return Padding(
        padding: EdgeInsets.all(spacingSmall),
        child: RaisedButton(
            color: Colors.black,
            child: Text(
              googlePay,
              style: nativeTextStyle,
            ),
            onPressed: () {
              _onNativeButtonClicked(callPaymentIntent, callConfirmPayment);
            }));
  }

  //To Generate Token (Method Already Implemented in Plugin)
  Future<String> receiptPayment(Receipt finalReceipt) async {
    return await StripeNative.useReceiptNativePay(finalReceipt);
  }

  //Click Event Method For Google Pay Button
  _onNativeButtonClicked(
      HttpsCallable callPaymentIntent, HttpsCallable callConfirmPayment) async {
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
    generatedToken = await receiptPayment(finalReceipt);
    startCreatePayment(receipt, finalReceipt, amount, currencyName,
        generatedToken, callPaymentIntent, callConfirmPayment);
  }

  //To Get Locale Based Currency Name
  String currency() {
    Locale locale = Localizations.localeOf(context);
    var format = NumberFormat.simpleCurrency(locale: locale.toString());
    return format.currencyName;
  }

  //To Start Process of Payment
  startCreatePayment(
      Map receipt,
      Receipt finalReceipt,
      double totalAmount,
      String currencyName,
      String token,
      HttpsCallable callPaymentIntent,
      HttpsCallable callConfirmPayment) async {
    double amount =
        totalAmount * 100.0; // multipliying with 100 to change $ to cents
    ProgressDialogUtils.showProgressDialog(context);
    try {
      final HttpsCallableResult result = await callPaymentIntent
          .call(<String, dynamic>{
        amountKey: amount,
        currencyKey: currencyName,
        tokenKey: token
      });
      var paymentIntentId = result.data[paymentIntentIdKey];
      var paymentMethodId = result.data[paymentMethodIdKey];
      ProgressDialogUtils.dismissProgressDialog();
      confirmDialog(receipt, finalReceipt, paymentIntentId, paymentMethodId,
          callConfirmPayment);
    } on CloudFunctionsException catch (e) {
      print(e.code);
      print(e.message);
      print(e.details);
    } catch (e) {
      print(e);
    }
  }

  //To Ask User To Confirm Payment Or Not
  confirmDialog(Map receipt, Receipt finalReceipt, String intentId,
      String methodId, HttpsCallable callPaymentConfirm) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              confirmDialogTitle,
              style: headerTextStyle,
            ),
            content: Container(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                    children: finalReceipt.items.entries.map((e) {
                  totalAmount = totalAmount + e.value;
                  return Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "${e.key}",
                            style: titleTextStyle,
                          ),
                          Text(
                            "${e.value}",
                            style: titleContentTextStyle,
                          ),
                        ],
                      ),
                    ],
                  );
                }).toList()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "$payTo ${finalReceipt.merchantName}",
                      style: headerTextStyle,
                    ),
                    Text(
                      "${finalReceipt.items.values.elementAt(0) + finalReceipt.items.values.elementAt(1)}",
                      style: titleContentTextStyle,
                    )
                  ],
                ),
              ],
            )),
            actions: <Widget>[
              RaisedButton(
                child: Text(
                  cancel,
                  style: cancelTextStyle,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              RaisedButton(
                child: Text(
                  confirm,
                  style: confirmTextStyle,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  confirmPaymentProcess(intentId, methodId, callPaymentConfirm);
                },
              ),
            ],
          );
        });
  }

  //To Process Of Successful Payment
  confirmPaymentProcess(String intentId, String methodId,
      HttpsCallable confirmPaymentIntent) async {
    ProgressDialogUtils.showProgressDialog(context);
    try {
      final HttpsCallableResult result =
          await confirmPaymentIntent.call(<String, dynamic>{
        paymentIntentIdKey: intentId,
        paymentMethodIdKey: methodId,
      });
      var status = result.data[paymentStatusKey];
      ProgressDialogUtils.dismissProgressDialog();
      if (status == paymentSuccessStatus) {
        Fluttertoast.showToast(
            msg: success,
            backgroundColor: Colors.black,
            textColor: Colors.white);
      } else {
        Fluttertoast.showToast(
            msg: status,
            backgroundColor: Colors.black,
            textColor: Colors.white);
      }
    } on CloudFunctionsException catch (e) {
      print(e.code);
      print(e.message);
      print(e.details);
    } catch (e) {
      print(e);
    }
  }
}

//You can generate Token using this method also according to your requirement

//  Future<String> get orderPayment async {
//    // subtotal, tax, tip, merchant name
//    var order = Order(5.50, 1.0, 2.0, "Some Store");
//    return await StripeNative.useNativePay(order);
//  }
