import UIKit
import CoreData
import AVKit
import XCGLogger

let log: XCGLogger = {
    let log = XCGLogger.default
    #if DEBUG
        log.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true)
    #else
        log.setup(level: .severe, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true)
    #endif
    return log
}()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataManager = DataManager()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        log.debug("Circuvals did finish launching")
        if UIApplication.isFirstLaunch() {
            log.debug("This is the Application's first launch: Adding sample data...")
            dataManager.initalData()
        }
        if UIApplication.isRunningUITest() {
            log.debug("Application is running UITests...")
            dataManager.testData()
        }
        if let rvc = window!.rootViewController as? DataManagerInjectable {
            log.debug("Setting up dependencies")
            rvc.injectWith(dataManager: dataManager)
        }
        do {
            let setsCount = try dataManager.persistentContainer.viewContext.count(for: Set.fetchRequest())
            log.debug("Set Count: \(setsCount)")
            let intervalsCount = try dataManager.persistentContainer.viewContext.count(for: Interval.fetchRequest())
            log.debug("Interval Count: \(intervalsCount)")
        }
        catch {
            
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        SetTimer.sharedInstance.enterBackground()
        dataManager.saveContext()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        SetTimer.sharedInstance.enterForground()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
}
