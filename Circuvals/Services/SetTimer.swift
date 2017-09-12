import Foundation

enum SetTimerState {
    case reseted
    case started
    case paused
    case finished
    case empty
}

protocol SetTimerDelegate: class {
    func timerDidStart()
    func timerDidPause()
    func timerDidContinue()
    func timerDidReset()
    
    func timerDidUpdateTime()
    func timerDidStartInterval()
    func timerDidFinishInterval()
    func timerDidUpdateState()
    func timerDidFinish()
    func timerDidFinish1stHalf()

    func timerDidChangeSet()
}

class SetTimer {
    static let sharedInstance: SetTimer = {
        return SetTimer()
    }()
    
    var state: SetTimerState = .empty {
        didSet {
            delegate?.timerDidUpdateState()
        }
    }
    weak var delegate: SetTimerDelegate?

    var set: Set? {
        didSet {
            if let set = set, set.duration > 0 {
                state = .reseted
                set.elapsed = 0
            }
            else {
                state = .empty
            }
            timer?.invalidate()
            delegate?.timerDidChangeSet()
        }
    }

    var timer: Timer?
    var timeEnteredBackground: Date?

    func start() {
        guard state == .reseted || state == .paused else {
            return
        }
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                         selector: #selector(self.tick), userInfo: nil, repeats: true)
        if state == .paused {
            state = .started
            delegate?.timerDidContinue()
        }
        else {
            state = .started
            delegate?.timerDidStart()
        }
    }

    func pause() {
        guard state == .started else {
            return
        }
        timer?.invalidate()
        state = .paused
        delegate?.timerDidPause()
    }

    func reset() {
        guard state == .paused || state == .finished else {
            return
        }
        set?.elapsed = 0
        state = .reseted
        delegate?.timerDidReset()
    }

    func finish() {
        timer?.invalidate()
        state = .finished
        delegate?.timerDidFinish()
    }

    func toggle() {
        switch state {
        case .reseted, .paused:
            start()
        case .started:
            pause()
        case .finished, .empty:
            break
        }
    }
    
    private func startIntervalWith(_ set: Set) {
        if let pauseInterval = set.currentInterval?.pause {
            if pauseInterval {
                self.pause()
            }
        }
    }
    
    @objc func tick() { //tick 10 times a second
        guard let set = set, set.intervals.count > 0, set.elapsed <= set.duration else {
            return
        }
        if set.elapsed == 0 {
            delegate?.timerDidStart()
        }
        if set.elapsedInInterval == 0 {
            if let interval = set.intervalIndex, interval > 0 {
                delegate?.timerDidFinishInterval()
            }
            delegate?.timerDidStartInterval()
            startIntervalWith(set)
        }
        if set.elapsedInInterval == set.remainingInInterval {
            delegate?.timerDidFinish1stHalf()
        }
        if set.elapsed % 10 == 0 { //update every second
            delegate?.timerDidUpdateTime()
        }
        if set.elapsed >= set.duration {
            finish()
            if set.isRepeating {
                reset()
                start()
            }
        }
        else {
            set.elapsed += 1
        }
        
    }
    
    func enterBackground() {
        print("timer entered background")
        if let timer = timer, timer.isValid {
            print("save current date")
            timeEnteredBackground = Date()
            timer.invalidate()
        }
    }
    
    func enterForground() {
        print("timer entered forground")
        if let time = timeEnteredBackground {
            let offset = (Int64(-time.timeIntervalSinceNow * 10))
            print("\(offset) 10s of seconds elapsed")
            self.set?.elapsed += offset
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                         selector: #selector(self.tick), userInfo: nil, repeats: true)
        }
        timeEnteredBackground = nil
    }
    
    func checkTimer() {
        guard let safeset = set else {
            set = nil
            return
        }
        if safeset.isDeleted {
            set = nil
        }
        if safeset.isUpdated {
            delegate?.timerDidChangeSet()
        }
    }
}
