package com.prod.hotzone

import android.Manifest
import android.content.pm.PackageManager
import android.nfc.Tag
import android.os.Build
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log


class PermissionRequestHelperActivity : AppCompatActivity() {
    val requestPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) {}
}


class MainActivity: FlutterActivity() {

    private var requestCode = 100;
    private val tag:String = "MainActivity"
    private val requestPermissionLauncher = PermissionRequestHelperActivity().requestPermissionLauncher
    private var Location_Permission = arrayOf(
        Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_FINE_LOCATION
    );

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = "hotzone/locationPermission"

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when(call.method) {
                "getLocationPermission" -> {
                    if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.R) {
                        if (checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
                            result.success(2)
                        } else if (ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission_group.LOCATION)){
                            result.success(1);
                        } else {
                            ActivityCompat.requestPermissions(this, Location_Permission, requestCode)
                            result.success(0);
                        }
                    } else {
                        //Log.d(tag,"run check")
                        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
                            result.success(2)
                            //Log.d(tag,"check")
                        } else {
                            //Log.d(tag,"request")
                            requestPermissionLauncher.launch(Location_Permission)
                            result.success(0)
                        }
                    }
                }
            }
        }
    }
}
