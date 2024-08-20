package com.example.nearmessageapp

import android.Manifest
import android.content.pm.PackageManager
import androidx.activity.result.ActivityResultLauncher
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private var requestCode = 100;
    private lateinit var  requestPermissionLauncher: ActivityResultLauncher<String>;
    private var Location_Permission = arrayOf(
        Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_FINE_LOCATION
    );

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = "hotzone/locationPermission"

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when(call.method) {
                "getLocationPermission" -> {
                    if (checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
                        result.success(2)
                    } else if (ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission_group.LOCATION)){
                        result.success(1);
                    } else {
                        ActivityCompat.requestPermissions(this, Location_Permission, requestCode)
                        result.success(0);
                    }
                }
            }
        }
    }
}
