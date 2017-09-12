import Foundation
import CoreData


extension Set {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Set> {
        return NSFetchRequest<Set>(entityName: "Set")
    }

    @NSManaged public var elapsed: Int64
    @NSManaged public var title: String
    @NSManaged public var index: Int64
    @NSManaged public var intervals: NSOrderedSet
    @NSManaged public var audioCountdown: Bool
    @NSManaged public var audioFeedback: Bool
    @NSManaged public var audioHalftime: Bool
    @NSManaged public var audioInterval: Bool
    @NSManaged public var isRepeating: Bool

    
    var intervalsArray : [Interval] {
        return intervals.array as! [Interval]
    }
    
}

// MARK: Generated accessors for intervals
extension Set {
    
    @objc(insertObject:inIntervalsAtIndex:)
    @NSManaged public func insertIntoIntervals(_ value: Interval, at idx: Int)
    
    @objc(removeObjectFromIntervalsAtIndex:)
    @NSManaged public func removeFromIntervals(at idx: Int)
    
    @objc(insertIntervals:atIndexes:)
    @NSManaged public func insertIntoIntervals(_ values: [Interval], at indexes: NSIndexSet)
    
    @objc(removeIntervalsAtIndexes:)
    @NSManaged public func removeFromIntervals(at indexes: NSIndexSet)
    
    @objc(replaceObjectInIntervalsAtIndex:withObject:)
    @NSManaged public func replaceIntervals(at idx: Int, with value: Interval)
    
    @objc(replaceIntervalsAtIndexes:withIntervals:)
    @NSManaged public func replaceIntervals(at indexes: NSIndexSet, with values: [Interval])
    
    @objc(addIntervalsObject:)
    @NSManaged public func addToIntervals(_ value: Interval)
    
    @objc(removeIntervalsObject:)
    @NSManaged public func removeFromIntervals(_ value: Interval)
    
    @objc(addIntervals:)
    @NSManaged public func addToIntervals(_ values: NSOrderedSet)
    
    @objc(removeIntervals:)
    @NSManaged public func removeFromIntervals(_ values: NSOrderedSet)
    
}
