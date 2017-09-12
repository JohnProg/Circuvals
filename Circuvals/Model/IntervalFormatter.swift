import Foundation

struct IntervalFormatter {
    let formatter = DateComponentsFormatter()
    
    func title(interval: Interval) -> String {
        if let title = interval.title {
            return title
        }
        else {
            return "\(type(interval:interval)) Interval"
        }
    }
    
    func type(interval: Interval) -> String {
        return interval.intervalType.readable()
    }
    
    func duration(interval: Interval) -> String {
        formatter.zeroFormattingBehavior = .dropLeading
        formatter.unitsStyle = .short
        return formatter.string(from: Double(interval.duration / 10))!
    }
    
    func indexedTitle(interval: Interval, index: Int) -> String {
        return "(\(index + 1)) \(title(interval: interval))"
    }
    
    func indexedDescription(interval: Interval, index: Int) -> String {
        return "(\(index + 1)) - \(description(interval: interval))"
    }
    
    func description(interval: Interval) -> String {
        return "\(type(interval: interval)),  \(duration(interval: interval))"
    }
    
    func accessibilityID(interval: Interval, index: Int) -> String {
        return "Interval\(index)"
    }
}
