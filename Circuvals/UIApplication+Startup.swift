import UIKit

extension UIApplication {
    class func isFirstLaunch() -> Bool {
        let key = "hasBeenLaunchedBefore"
        if !UserDefaults.standard.bool(forKey: key ) {
            UserDefaults.standard.set(true, forKey: key)
            UserDefaults.standard.synchronize()
            return true
        }
        return false
    }
    
    class func isRunningUITest() -> Bool {
        if ProcessInfo.processInfo.arguments.contains("IS_RUNNING_UITEST") {
            return true
        }
        return false
    }
}

