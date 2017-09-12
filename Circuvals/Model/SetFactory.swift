import CoreData

class SetFactory {
    static func tabataSet(context: NSManagedObjectContext) -> Set {
        let set = createSetWith(title: "Tabata Set", context: context)
        set.addToIntervals(Interval(duration: 100, type: .prepare, context: context))
        for _ in 1...8 {
            set.addToIntervals(Interval(duration: 200, type: .high, context: context))
            set.addToIntervals(Interval(duration: 100, type: .relax, context: context))
        }
        set.addToIntervals(Interval(duration: 600, type: .cooldown, context: context))
        return set
    }
    
    static func littleMethodSet(context: NSManagedObjectContext) -> Set {
        let set = createSetWith(title: "Little Method Set", context: context)
        set.addToIntervals(Interval(duration: 1800, type: .warmup, context: context))
        for _ in 1...12 {
            set.addToIntervals(Interval(duration: 600, type: .high, context: context))
            set.addToIntervals(Interval(duration: 750, type: .low, context: context))
        }
        set.addToIntervals(Interval(duration: 600, type: .cooldown, context: context))
        return set
    }
    
    static func basicSet(context: NSManagedObjectContext) -> Set {
        let set = createSetWith(title: "Basic Set", context: context)
        set.addToIntervals(Interval(duration: 100, type: .prepare, context: context))
        for _ in 1...3 {
            set.addToIntervals(Interval(duration: 200, type: .high, context: context))
            set.addToIntervals(Interval(duration: 100, type: .relax, context: context))
        }
        set.addToIntervals(Interval(duration: 600, type: .cooldown, context: context))
        return set
    }
    
    static func createSetWith(title: String, context: NSManagedObjectContext) -> Set {
        do {
            let index = try context.count(for: Set.fetchRequest())
            let set = Set(title: title, context: context)
            set.index = Int64(index)
            return set
        } catch {
            log.error("Could not count number of sets")
            return Set(title: title, context: context)
        }
    }
}
