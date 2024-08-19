import Cocoa
import FlutterMacOS
import IOKit.ps
import CoreLocation

class MainFlutterWindow: NSWindow, CLLocationManagerDelegate {
  override func awakeFromNib() {
    
    let locationManager = CLLocationManager()
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

      
    locationManager.delegate = self;
      
    let locationChannel = FlutterMethodChannel(
        name: "hotzone/locationPermission", binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    
      locationChannel.setMethodCallHandler{ (call, result) in
          switch call.method {
          case "getLocationPermission":
              guard let locationPermissionStatus = getLocationPermissionStatus(manager: locationManager) else {
                  result(
                  FlutterError(
                  code: "Internal Error", message: "Couldn't access permission status", details: nil
                  ))
                  return
              }
              result(locationPermissionStatus)
          default:
              result(FlutterMethodNotImplemented)
          }
      }
      
    RegisterGeneratedPlugins(registry: flutterViewController)
      
    super.awakeFromNib()
  }
}


private func getLocationPermissionStatus(manager: CLLocationManager) -> Int? {
    manager.requestWhenInUseAuthorization()
    
    let status = manager.authorizationStatus

    switch status {
    case .notDetermined:
        manager.requestWhenInUseAuthorization()
        return(2)// or requestAlwaysAuthorization()
    case .restricted, .denied:
        return(1)
        // Handle denied or restricted case (e.g., show a message to user)
    case .authorizedWhenInUse, .authorizedAlways:
        return(0)// Permission granted, proceed with location services
    default:
        return(3)
    }
}
