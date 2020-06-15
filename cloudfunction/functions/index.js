const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

const firestore = admin.firestore();
const settings = { timestampInSnapshots: true };
firestore.settings(settings)
const stripe = require('stripe')('<Your Secret Key>');

//Create Payment
exports.createPayment = functions.region('europe-west3').https.onCall(async (data, context) => {
  try {
    //Create Payment Method
    const paymentMethod = await stripe.paymentMethods.create(
      {
        type: 'card',
        card: {
          token: data.token,
        },
      },
    );
    // If You Want to Implement Combine Process Of CreatePayment and ConfirmPayment
    //then Please Uncomment this below two lines then return status and Do not Call Below ConfirmPayment
    //method From FrontEnd Side

    //Create PaymentIntent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: data.amount,
      currency: data.currency,
      // payment_method: connectedAccountPaymentMethod.id,
      // confirm: true,
      description: 'Software development',
      shipping: {
        name: 'Jenny Rosen',
        address: {
          line1: '510 Townsend St',
          postal_code: '98140',
          city: 'San Francisco',
          state: 'CA',
          country: 'US',
        },
      },
    })
    return {
      paymentIntentId: paymentIntent.id,
      paymentMethodId: paymentMethod.id
    }
  } catch (e) {
    console.log(e);
  }
  return {
    paymentIntentId: "",
    paymentMethodId: ""
  }
})

//For Confirmming Payment
exports.confirmPayment = functions.region('europe-west3').https.onCall(async (data, context) => {
  try {
    const finalPayment = await stripe.paymentIntents.confirm(
      data.paymentIntentId,
      { payment_method: data.paymentMethodId });
    return {
      paymentStatus: finalPayment.status,
    }
  } catch (e) {
    console.log(e);
  }
  return {
    paymentStatus: "",
  }
});
