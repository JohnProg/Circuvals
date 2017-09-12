import CoreData
import Foundation

struct TestHelper {
    static let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Circuvals")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.configuration = "Default"
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
