import Cocoa
import FlutterMacOS
import CoreLocation

@main
class AppDelegate: FlutterAppDelegate {

    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
}
