import Foundation
import CoreData


extension Interval {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Interval> {
        return NSFetchRequest<Interval>(entityName: "Interval");
    }

    @NSManaged public var duration: Int64
    @NSManaged public var type: String
    @NSManaged public var set: Set
    @NSManaged public var pause: Bool
    @NSManaged public var title: String?

}
