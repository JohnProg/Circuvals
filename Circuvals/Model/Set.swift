import CoreData

@objc(Set)
class Set: NSManagedObject {
    convenience init(title:String, context:NSManagedObjectContext) {
        self.init(context: context)
        self.title = title
    }

    var duration: Int64 {
        return intervalsArray.reduce(0, { (sum, interval) in sum + interval.duration })
    }
    
    var remaining: Int64 {
        return duration - elapsed
    }
    
    var stopTimes:[Int64] {
        var sum:Int64 = 0
        return intervalsArray.map( { (element) in
            sum += element.duration
            return sum
        } )
    }
    
    var startTimes:[Int64] {
        var sum:Int64 = 0
        return [0] + intervalsArray.dropLast().map( { (interval) in
            sum += interval.duration
            return sum
        })
    }

    var intervalIndex: Int? {
        if elapsed == duration && intervals.count > 0 {
            return intervals.count - 1
        }
        return stopTimes.index(where: { (e) in e > elapsed })
    }

    var currentInterval: Interval? {
        guard let index = intervalIndex else { return nil }
        return intervalsArray[index]
    }

    var elapsedInInterval: Int64? {
        guard let index = intervalIndex else { return 0 }
        return elapsed - startTimes[index]
    }
    
    var remainingInInterval: Int64? {
        guard let index = intervalIndex, let elapsedInInterval = elapsedInInterval else { return 0 }
        return intervalsArray[index].duration - elapsedInInterval
    }
    
    var durationOfInterval: Int64? {
        guard let index = intervalIndex else { return nil }
        return intervalsArray[index].duration
    }
    
    var isFinished: Bool {
        if elapsed < duration {
            return false
        }
        return true
    }

    var activeIntervals: [Interval] {
        return intervalsArray.filter { $0.isActive }
    }

    var activeDuration: Int64 {
        return activeIntervals.reduce(0, {$0 + $1.duration})
    }

    var activeElapsed: Int64? {
        guard let currentIndex = intervalIndex,
            let current = currentInterval,
            let elapsedInInterval = elapsedInInterval else { return nil }
        let activeElapsed = current.isActive ? elapsedInInterval : 0
        return intervalsArray[0..<currentIndex].filter { $0.isActive }.reduce(activeElapsed, {$0 + $1.duration})
    }

    var currentActiveInterval: Int? {
        guard let currentIndex = intervalIndex else {
            return nil
        }
        return intervalsArray[0...currentIndex].filter { $0.isActive }.count
    }
}
