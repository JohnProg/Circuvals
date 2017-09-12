 import CoreData

enum IntervalType:String {
    case high
    case low
    case relax
    case prepare
    case warmup
    case cooldown
    
    var isActive: Bool {
        switch self {
        case .high, .low, .warmup:
            return true
        case .cooldown, .prepare, .relax:   
            return false
        }
    }
    
    func readable() -> String {
        return self.rawValue.capitalized
    }
    
    static let values = [high, low, relax, prepare, cooldown, warmup]
}

@objc(Interval)
class Interval: NSManagedObject {
    
    convenience init(duration:Int64, context: NSManagedObjectContext) {
        self.init(context: context)
        self.duration = duration
        self.intervalType = .high
    }
    
    convenience init(duration: Int64, type: IntervalType, context: NSManagedObjectContext) {
        self.init(context: context)
        self.duration = duration
        self.intervalType = type
    }
    
    var intervalType: IntervalType {
        get {
            return IntervalType(rawValue: type)!
        }
        set {
            type = newValue.rawValue
        }
    }
    
    var isActive: Bool {
        return intervalType.isActive
    }

}
