import UIKit
import Flutter
import CoreLocation

@main
@objc class AppDelegate: FlutterAppDelegate, CLLocationManagerDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      
      let locationChannel = FlutterMethodChannel(
        name: "hotzone/locationPermission", binaryMessenger: controller.binaryMessenger
      )
      
      locationChannel.setMethodCallHandler({
          (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          switch call.method {
          case "getLocationPermission":
              self.getLocationPermission(manager: CLLocationManager())
              result(self.getLocationPermission(manager: CLLocationManager(), didChangeAuthorization: CLLocationManager().authorizationStatus))
          default:
              result(FlutterMethodNotImplemented)
          }
      })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func getLocationPermission(manager: CLLocationManager) -> Void {
            manager.delegate = self
            manager.requestWhenInUseAuthorization()
        }

    
    private func getLocationPermission(manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) -> Int {
        
        switch status {
        case .authorizedAlways,.authorizedWhenInUse:
            return 2;
        case .denied, .restricted:
            return 1;
        case .notDetermined:
            return 0;
        default:
            return 3;
        }
    }
    }

