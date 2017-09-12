import Foundation
import CoreData

class DataManager {
//    static let sharedInstance: DataManager = {
//        return DataManager()
//    }()
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Circuvals")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func testData() {
        let moc = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Set.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            log.debug("Deleting all sets")
            try moc.execute(batchDeleteRequest)
            
        } catch {
            log.debug("Error deleting entities")
        }
        //initalData()
        let set0 = SetFactory.littleMethodSet(context: moc)
        set0.index = 0
        let set1 = SetFactory.tabataSet(context: moc)
        set1.index = 1
        let set2 = SetFactory.basicSet(context: moc)
        set2.index = 2
        
    }
    
    func initalData() {
        let moc = persistentContainer.viewContext
        log.debug("Adding sample Data")
        _ = SetFactory.basicSet(context: moc)
        _ = SetFactory.tabataSet(context: moc)
        _ = SetFactory.littleMethodSet(context: moc)
    }

}
