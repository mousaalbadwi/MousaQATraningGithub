package com.example.finale_project;

import android.os.Bundle;
import android.util.Log;
import java.util.stream.Collectors;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import java.io.File;
import java.util.Arrays;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "mfcc_channel";

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);

    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
      .setMethodCallHandler((call, result) -> {
        if (call.method.equals("extractMFCC")) {
          String filePath = call.argument("path");
          if (filePath != null) {
            MFCCExtractor.extractMFCC(new File(filePath), new MFCCListener() {
              @Override
              public void onMFCCExtracted(float[] mfcc) {
                result.success(
  Arrays.stream(mfcc)
        .mapToDouble(f -> (double) f)
        .boxed()
        .collect(Collectors.toList())
);;
              }

              @Override
              public void onError(String error) {
                result.error("MFCC_ERROR", error, null);
              }
            });
          } else {
            result.error("NO_PATH", "File path is null", null);
          }
        } else {
          result.notImplemented();
        }
      });
  }
}