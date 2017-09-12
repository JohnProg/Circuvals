import Foundation

class SetFormatter {
    var set: Set?
    var formatter = DateComponentsFormatter()
    
    init() {
        formatter.zeroFormattingBehavior = .dropAll
        formatter.unitsStyle = .short
    }
    
    var remainingInInterval: String {
        return stringFromTime(set?.remainingInInterval)
    }
    
    var remaining: String {
        return stringFromTime(set?.remaining)
    }
    
    var elapsed: String {
        return stringFromTime(set?.elapsed)
    }
    
    var elapsedInInterval: String {
        return stringFromTime(set?.elapsedInInterval)
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
        guard let title = set?.title else {
            let noTitle = NSLocalizedString("set-formatter-tile-placeholder", value: "No Title", comment: "Placeholder Title")
            return noTitle
        }
        return title
    }
    
    func interval(amount: Int) -> String {
        let intervalSingular = NSLocalizedString("interval-interval-singular", value: "Interval", comment: "Interval Singular")
        let intervalPlural = NSLocalizedString("interval-interval-singular", value: "Intervals", comment: "Interval Plural")
        return amount == 1 ? intervalSingular : intervalPlural
    }
    
    var setDescription: String {
        guard let set = set else { return "" }
        let intervalCount = set.activeIntervals.count
        let intervalString = interval(amount: intervalCount)
        let durationString = formatter.string(from: Double(set.duration / 10)) ?? ""
        return "\(intervalCount) \(intervalString), \(durationString)"
    }

    private func stringFromTime(_ tenths: Int64) -> String {
        let seconds = (tenths % 600) / 10
        let minutes = (tenths / 600)
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func stringFromTime(_ tenths: Int64?) -> String {
        guard let tenths = tenths else { return "--:--" }
        return stringFromTime(tenths)
    }
}
