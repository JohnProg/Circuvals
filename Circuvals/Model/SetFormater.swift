import Foundation

class SetFormatter {
    var set: Set?
    var formatter = DateComponentsFormatter()
    
    var remainingInInterval: String {
        return format(time: set?.remainingInInterval)
    }
    
    var remaining: String {
        return format(time: set?.remaining)
    }
    
    var elapsed: String {
        return format(time: set?.elapsed)
    }
    
    var elapsedInInterval: String {
        return format(time: set?.elapsedInInterval)
    }
    
    var currentIntervalType: String {
        guard let intervalType = set?.currentInterval?.type else { return "-" }
        return intervalType.capitalized
    }
    
    var intervalOfIntervals: String {
        guard let set = set, let intervalIndex = set.intervalIndex else { return "-/-" }
        return String(intervalIndex + 1) + "/" + String(set.intervals.count)
    }
    
    var intervalOfActiveIntervals: String {
        guard let set = set, let currentActiveInterval = set.currentActiveInterval else { return "-/-" }
        return String(currentActiveInterval) + "/" + String(set.activeIntervals.count)
    }
    
    var intervalOfActiveIntervalsSpoken: String {
        guard let set = set, let currentActiveInterval = set.currentActiveInterval else { return "" }
        return String(currentActiveInterval) + " of " + String(set.activeIntervals.count)
    }

    var title: String {
        guard let title = set?.title else { return "No Title" }
        return title
    }
    
    func interval(amount: Int) -> String {
        return amount == 1 ? "Interval" : "Intervals"
    }
    
    var setDescription: String {
        guard let set = set else { return "" }
        let intervalCount = set.activeIntervals.count
        let intervalString = interval(amount: intervalCount)
        formatter.zeroFormattingBehavior = .dropAll
        formatter.unitsStyle = .short
        let durationString = formatter.string(from: Double(set.duration / 10))!
        return "\(intervalCount) \(intervalString), \(durationString)"
    }

    func format(time: Int64) -> String {
        let time = Int(time)
        let seconds = (time % 600) / 10
        let minutes = (time / 600)
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func format(time: Int64?) -> String {
        guard let time = time else { return "-" }
        return format(time: time)
    }
}
