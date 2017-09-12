import Foundation

struct IntervalFormatter {
    let formatter = DateComponentsFormatter()
    var interval: Interval
    
    init(interval: Interval) {
        self.interval = interval
        formatter.zeroFormattingBehavior = .dropLeading
        formatter.unitsStyle = .short
    }
    
    var title: String {
        if let title = interval.title, title != "" {
            return title
        }
        else {
            return "\(type) Interval"
        }
    }
    
    var type: String {
        return interval.intervalType.readable()
    }
    
    var duration: String {
        return formatter.string(from: Double(interval.duration / 10))!
    }
    
    func titleWith(index: Int) -> String {
        return "(\(index + 1)) \(title)"
    }
    
    func descriptionWith(index: Int) -> String {
        return "(\(index + 1)) - \(description)"
    }
    
    var description: String {
        return "\(type),  \(duration)"
    }
    
    func accessibilityIDWith(index: Int) -> String {
        return "Interval\(index)"
    }
}
