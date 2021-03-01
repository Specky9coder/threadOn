package com.threadon.app;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import com.paypal.android.sdk.payments.PayPalAuthorization;
import com.paypal.android.sdk.payments.PayPalConfiguration;
import com.paypal.android.sdk.payments.PayPalFuturePaymentActivity;
import com.paypal.android.sdk.payments.PayPalPayment;
import com.paypal.android.sdk.payments.PayPalService;
import com.paypal.android.sdk.payments.PaymentActivity;
import com.paypal.android.sdk.payments.PaymentConfirmation;

import org.json.JSONException;
import org.json.JSONObject;

import java.math.BigDecimal;
import java.util.ArrayList;

public class Paypal_Screen extends AppCompatActivity {

    private static final String CONFIG_ENVIRONMENT = PayPalConfiguration.ENVIRONMENT_SANDBOX;
    public static final String EXTRA_COUNTER = "counter";



    // note that these credentials will differ between live & sandbox
    // environments.
    private static final String CONFIG_CLIENT_ID = "AcMV7y11QgpPKwaX4L_CrFKdjhIPhZiUbfSyMQcsNqdy-CTjtop6y12GOQCdbInD_nfdedGqyB-drJ7r";

    private static final int REQUEST_CODE_PAYMENT = 1;
    private static final int REQUEST_CODE_FUTURE_PAYMENT = 2;

    private static PayPalConfiguration config = new PayPalConfiguration()
            .environment(CONFIG_ENVIRONMENT)
            .clientId(CONFIG_CLIENT_ID);
            // The following are only used in PayPalFuturePaymentActivity.
           /* .merchantName("Hipster Store")
            .merchantPrivacyPolicyUri(
                    Uri.parse("https://www.example.com/privacy"))
            .merchantUserAgreementUri(
                    Uri.parse("https://www.example.com/legal"));
*/
    PayPalPayment thingToBuy;
    String Total1="";
    String Item="";
    int StatusCode = 1;
    ArrayList<String> paymentdata;



    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.second_screen);

        Intent i = getIntent();
        Total1 = getIntent().getStringExtra(EXTRA_COUNTER);
       String [] Total=Total1.split("@");
       Total1 = Total[1];
        Item = Total[0];
        Button b = findViewById(R.id.click);
        b.setVisibility(View.GONE);


        getPayment();
                thingToBuy = new PayPalPayment(new BigDecimal(Total1), "USD",
                        "HeadSet", PayPalPayment.PAYMENT_INTENT_SALE);

        Intent intent1 = new Intent(Paypal_Screen.this, PayPalService.class);
        intent1.putExtra(PayPalService.EXTRA_PAYPAL_CONFIGURATION, config);
        startService(intent1);



    }public void onFuturePaymentPressed(View pressed) {
        Intent intent = new Intent(Paypal_Screen.this,
                PayPalFuturePaymentActivity.class);

        startActivityForResult(intent, REQUEST_CODE_FUTURE_PAYMENT);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE_PAYMENT) {
            if (resultCode == Activity.RESULT_OK) {
                PaymentConfirmation confirm = data
                        .getParcelableExtra(PaymentActivity.EXTRA_RESULT_CONFIRMATION);
                if (confirm != null) {
                    try {
                        System.out.println(confirm.toJSONObject().toString(4));
                        System.out.println(confirm.getPayment().toJSONObject().toString(4));

                        String resDetails = confirm.getPayment().toJSONObject().toString(4);
                        JSONObject jsonDetails1 = new JSONObject(resDetails);
                        String amount = jsonDetails1.getString("amount");
                        String currency_code = jsonDetails1.getString("currency_code");
                        String short_description = jsonDetails1.getString("short_description");
                        //JSONObject obj =jsonDetails1.getJSONObject("response");


                        String paymentDetails = confirm.toJSONObject().toString(4);

                        JSONObject jsonDetails = new JSONObject(paymentDetails);
                        JSONObject obj =jsonDetails.getJSONObject("response");
                        String id = obj.getString("id");
                        String intent = obj.getString("intent");
                        String state = obj.getString("state");

                         paymentdata = new ArrayList<>();
                         paymentdata.add("0");
                        paymentdata.add(id);
                        paymentdata.add(intent);
                        paymentdata.add(state);
                        paymentdata.add(amount);
                        paymentdata.add(currency_code);
                        paymentdata.add(short_description);


                        //Displaying payment details
                        //showDetails(, intent.getStringExtra("PaymentAmount"));

                        StatusCode = 0;
                        returnToFlutterView(paymentdata,StatusCode);
                        Toast.makeText(getApplicationContext(), "Order placed",
                                Toast.LENGTH_LONG).show();

                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            } else if (resultCode == Activity.RESULT_CANCELED) {
                System.out.println("The user canceled.");
                StatusCode = 3;
                paymentdata = new ArrayList<>();
                paymentdata.add("3");
                paymentdata.add("The user canceled.");
            } else if (resultCode == PaymentActivity.RESULT_EXTRAS_INVALID) {
                System.out
                        .println("An invalid Payment or PayPalConfiguration was submitted. Please see the docs.");
                StatusCode = 2;

                paymentdata = new ArrayList<>();
                paymentdata.add("2");
                paymentdata.add("TAn invalid Payment or PayPalConfiguration was submitted. Please see the docs.");
            }
        } else if (requestCode == REQUEST_CODE_FUTURE_PAYMENT) {
            if (resultCode == Activity.RESULT_OK) {
                PayPalAuthorization auth = data
                        .getParcelableExtra(PayPalFuturePaymentActivity.EXTRA_RESULT_AUTHORIZATION);
                if (auth != null) {
                    try {
                        Log.i("FuturePaymentExample", auth.toJSONObject()
                                .toString(4));

                        String authorization_code = auth.getAuthorizationCode();
                        Log.i("FuturePaymentExample", authorization_code);

                        sendAuthorizationToServer(auth);
                        Toast.makeText(getApplicationContext(),
                                "Future Payment code received from PayPal",
                                Toast.LENGTH_LONG).show();

                    } catch (JSONException e) {
                        Log.e("FuturePaymentExample",
                                "an extremely unlikely failure occurred: ", e);
                    }
                }
            } else if (resultCode == Activity.RESULT_CANCELED) {
                Log.i("FuturePaymentExample", "The user canceled.");
            } else if (resultCode == PayPalFuturePaymentActivity.RESULT_EXTRAS_INVALID) {
                Log.i("FuturePaymentExample",
                        "Probably the attempt to previously start the PayPalService had an invalid PayPalConfiguration. Please see the docs.");
            }
        }
    }

    private void sendAuthorizationToServer(PayPalAuthorization authorization) {

    }

    public void onFuturePaymentPurchasePressed(View pressed) {
        // Get the Application Correlation ID from the SDK
        String correlationId = PayPalConfiguration
                .getApplicationCorrelationId(this);

        Log.i("FuturePaymentExample", "Application Correlation ID: "
                + correlationId);

        // TODO: Send correlationId and transaction details to your server for
        // processing with
        // PayPal...
        Toast.makeText(getApplicationContext(),
                "App Correlation ID received from SDK", Toast.LENGTH_LONG)
                .show();
    }

    @Override
    public void onDestroy() {
        // Stop service when done
        stopService(new Intent(this, PayPalService.class));

        super.onDestroy();

    }


    private void returnToFlutterView(ArrayList<String> paydata,int Stcode) {
        Intent returnIntent = new Intent();
        returnIntent.putExtra("StatusCode",Stcode);
        returnIntent.putStringArrayListExtra(EXTRA_COUNTER, paydata);
        setResult(AppCompatActivity.RESULT_OK, returnIntent);
        finish();
    }

    public void onBackPressed() {
        if (StatusCode == 0){
            returnToFlutterView(paymentdata,StatusCode);
        }
        else if (StatusCode == 3){
            returnToFlutterView(paymentdata,StatusCode);
        }
        else if (StatusCode == 2){
            returnToFlutterView(paymentdata,StatusCode);
        }
        else if (StatusCode == 1){
            returnToFlutterView(paymentdata,StatusCode);
        }

    }

    private void getPayment() {
      //  paymentAmount = tv_total_pay.getText().toString();
        PayPalPayment payment = new PayPalPayment(new BigDecimal(Integer.parseInt(Total1.trim())), "USD", Item,
                PayPalPayment.PAYMENT_INTENT_SALE);

        Intent intent = new Intent(this, PaymentActivity.class);

        //putting the paypal configuration to the intent
        intent.putExtra(PayPalService.EXTRA_PAYPAL_CONFIGURATION, config);

        //Puting paypal payment to the intent
        intent.putExtra(PaymentActivity.EXTRA_PAYMENT, payment);

        //Starting the intent activity for result
        //the request code will be used on the method onActivityResult
        startActivityForResult(intent, REQUEST_CODE_PAYMENT);
    }
}
