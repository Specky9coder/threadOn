package com.threadon.app;
import android.content.Intent;
// import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import java.util.ArrayList;

// import io.flutter.app.FlutterActivity;
// import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
// import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
// import io.flutter.plugin.common.MethodChannel.Result;
// import io.flutter.plugins.GeneratedPluginRegistrant;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
public class MainActivity extends FlutterActivity {

     @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                    (call, result) -> {
                       // Your existing code
                }
        );
   }
  /*  String text="";
    String total="";
    private MethodChannel.Result result;

    private static final String CHANNEL = "samples.flutter.io/platform_view";
    private static final String METHOD_SWITCH_VIEW = "switchView";
    private static final int COUNT_REQUEST = 1;

*/
 

      /*  new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(

                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        // if (call.method.equals("demoFunction")) { // INFO: method check
                        //   String argument = call.argument("data"); // INFO: get arguments
                        //   demoFunction(result, argument); // INFO: method call, every method call should pass result parameter
                        // } else
                        MainActivity.this.result = result;

                        if(call.method.equals(METHOD_SWITCH_VIEW)) {
                            text = call.argument("text").toString();
                            onLaunchFullScreen(text);

                        }
                    }
                }
        );
*/
    }
/*

    private void onLaunchFullScreen(String count) {
        Intent fullScreenIntent = new Intent(this, Paypal_Screen.class);
        fullScreenIntent.putExtra(Paypal_Screen.EXTRA_COUNTER,count );
        startActivityForResult(fullScreenIntent, COUNT_REQUEST);
    }



    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == COUNT_REQUEST) {
            if (resultCode == RESULT_OK) {
                ArrayList<String> d =data.getStringArrayListExtra(Paypal_Screen.EXTRA_COUNTER);
                result.success(d);
            }
            else {
                result.error("ACTIVITY_FAILURE", "Failed while launching activity", null);
            }

        }
    }

}
*/
