//TODO: Put Speech Queue maybe somewhere else

import UIKit
import AVFoundation

class TimerViewController: UIViewController, SetTimerDelegate, DataManagerInjectable, SetInjectable {
    
    @IBOutlet weak var circleTimerView: CircleTimerView!
    
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var remaining: UILabel!
    @IBOutlet weak var remainingInInterval: UILabel!
    @IBOutlet weak var elapsed: UILabel!
    @IBOutlet weak var interval: UILabel!
    @IBOutlet weak var intervalType: UILabel!
    @IBOutlet weak var elapsedInInterval: UILabel!
    
    @IBOutlet weak var editSetButton: UIButton!
    @IBOutlet weak var setTitleButton: UIButton!
    
    private let speechQueue = SpeechQueue()
    private let setTimer = SetTimer.sharedInstance
    private let formatter = SetFormatter()
    
    private let intervalID = 0
    private let totalID = 2
    private let activeID = 1
    
    // Mark: - Depencency Injection
    var dataManger: DataManager!
    
    func injectWith(dataManager: DataManager) {
        self.dataManger = dataManager
    }
    
    func injectWith(set: Set) {
        self.setTimer.set = set
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTimer.delegate = self
        circleTimerView.circles[0].foreground.strokeColor = UIColor(red:0.30, green:0.62, blue:0.88, alpha:1.0).cgColor
        circleTimerView.circles[1].foreground.strokeColor = UIColor(red:0.47, green:0.41, blue:0.68, alpha:1.0).cgColor
        circleTimerView.circles[2].foreground.strokeColor = UIColor(red:0.23, green:0.70, blue:0.45, alpha:1.0).cgColor
        updateLabels()
        updateTitle()
        updateControls()
        initCircleView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateLabels() {
        log.debug("Updating labels")
        
        remaining.text = formatter.remaining
        remainingInInterval.text = formatter.remainingInInterval
        elapsed.text = formatter.elapsed
        elapsedInInterval.text = formatter.elapsedInInterval
        interval.text = formatter.intervalOfActiveIntervals
        intervalType.text = formatter.currentIntervalType
    }

    func updateControls() {
        log.debug("Updating controls")
        let startButtonText = NSLocalizedString("timervc-btn-start", value: "Start", comment: "Label of button to start the timer")

        switch setTimer.state {
        case .finished:
            toggleButton.setTitle(startButtonText, for: UIControlState())
            toggleButton.isEnabled = false
            resetButton.isEnabled = true
            editSetButton.isEnabled = true
        case .reseted:
            toggleButton.isEnabled = true
            toggleButton.setTitle(startButtonText, for: UIControlState())
            resetButton.isEnabled = false
            editSetButton.isEnabled = true
        case .paused:
            toggleButton.isEnabled = true
            toggleButton.setTitle(NSLocalizedString("timvervc-btn-continue", value: "Continue", comment: "Label of button to start the timer"), for: UIControlState())
            resetButton.isEnabled = true
            editSetButton.isEnabled = true
        case .started:
            toggleButton.isEnabled = true
            let pauseText = NSLocalizedString("timervc-btn-pause", value: "Pause", comment: "Label of button to start the timer")
            toggleButton.setTitle(pauseText, for: UIControlState())
            resetButton.isEnabled = false
            editSetButton.isEnabled = true
        case .empty:
            toggleButton.isEnabled = false
            toggleButton.setTitle(startButtonText, for: UIControlState())
            resetButton.isEnabled = false
            editSetButton.isEnabled = false
        }
    }
    
    func updateTitle() {
        if setTimer.set != nil {
            setTitleButton.setTitle(formatter.title, for: UIControlState())
            setTitleButton.accessibilityLabel = formatter.title
        }
        else {
            let emptyTitle = NSLocalizedString("timvervc-btn-selectset", value: "Select a Set", comment: "Label of button to select a set")
            setTitleButton.setTitle(emptyTitle, for: [])
            setTitleButton.accessibilityLabel = emptyTitle
        }
    }
    
    func setLocked(locked: Bool) {
        if locked {
            log.debug("Locking screen")
            resetButton.isEnabled = false
            toggleButton.isEnabled = false
            resetButton.isEnabled = false
            setTitleButton.isEnabled = false
            editSetButton.isEnabled = false
        }
        else {
            log.debug("Unlocking screen")
            setTitleButton.isEnabled = true
            editSetButton.isEnabled = true
            updateControls()
        }
    }
    
    func initCircleView() {
        //FIXME Ugly
        log.debug("Set circle views to 0")
        circleTimerView.setPercentage(0.0, at: intervalID)
        circleTimerView.setPercentage(0.0, at: totalID)
        circleTimerView.setPercentage(0.0, at: activeID)
    }
    
    func startIntervalCircle() {
        guard let set = setTimer.set,
            let remainingTimeInInterval = set.remainingInInterval else {
                return
        }
        log.debug("Maximum Value of IntervalCircle will be reached in \(Double(remainingTimeInInterval)/10.0) seconds")
        circleTimerView.setPercentage(0.0, at: intervalID)
        let remainingSecondsInInterval = Double(remainingTimeInInterval) / 10.0
        circleTimerView.setPercentage(1.0, at: intervalID, inTime: remainingSecondsInInterval)        
    }
    
    func pauseIntervalCircle() {
        guard let set = setTimer.set, let elapsedInInterval = set.elapsedInInterval,
            let durationOfInterval = set.durationOfInterval else { return }
        circleTimerView.setPercentage(Float(elapsedInInterval)/Float(durationOfInterval), at: intervalID)
    }
    
    func startTotalCircle() {
        guard let set = setTimer.set else { return }
        log.debug("Maximum Value of TotalCircle will be reached in \(Double(set.remaining)/10.0) seconds")
        circleTimerView.setPercentage(1.0, at: totalID, inTime: Double(set.remaining) / 10.0)
    }
    
    func pauseTotalCircle() {
        guard let set = setTimer.set else {
            return
        }
        circleTimerView.setPercentage(Float(set.elapsed)/Float(set.duration), at: totalID)
    }
    
    func startActiveCircle() {
        guard let set = setTimer.set,
            let currentInterval = set.currentInterval,
            let remainingInInterval = set.remainingInInterval,
            let activeElapsed = set.activeElapsed
        else { return }
        
        if currentInterval.isActive {
            let value = Float(activeElapsed + remainingInInterval)/Float(set.activeDuration)
            circleTimerView.setPercentage(value, at: activeID, inTime: Double(remainingInInterval)/10.0)
            log.debug("\(value) of ActiveCircle in \(remainingInInterval/10) seconds")
        }
    }
    
    func pauseActiveCircle() {
        guard let set = setTimer.set,
            let currentInterval = set.currentInterval,
            let activeElapsed = set.activeElapsed
            else { return }
        
        if currentInterval.isActive {
            let value = Float(activeElapsed)/Float(set.activeDuration)
            circleTimerView.setPercentage(value, at: activeID)
        }
    }
    
    // MARK: - IntervalTimerDelegate
    
    func timerDidStart() {
        guard let set = setTimer.set, set.remaining > 0  else { return }
        startTotalCircle()
        if set.audioFeedback {
            speechQueue.enque(text: "\(formatter.title) started")
            log.debug("audio: timer started")
        }
        log.debug("SetTimerDelegate: timer did start")
    }
    
    func timerDidStartInterval() {
        guard let set = setTimer.set, let currentInterval = set.currentInterval else {
            return
        }
        startIntervalCircle()
        startActiveCircle()
        if set.audioFeedback {
            speechQueue.enque(text: "\(IntervalFormatter(interval: currentInterval).title)")
        }
        if set.audioInterval && currentInterval.isActive {
            speechQueue.enque(text: formatter.intervalOfActiveIntervalsSpoken)
        }
        log.debug("SetTimerDelegate: timer did start interval")
    }

    func timerDidContinue() {
        log.debug("SetTimerDelegate: timer did continue")
        startTotalCircle()
        startIntervalCircle()
        startActiveCircle()
    }
    
    func timerDidPause() {
        guard let set = setTimer.set else {
            return
        }
        log.debug("SetTimerDelegate: timer did pause at \(set.elapsed)")
        if set.audioFeedback {
            log.debug("audio: pause")
            let text = NSLocalizedString("audio-pause", value: "Pause", comment: "Audio feedback when timer is paused")
            speechQueue.enque(text: text)
        }
        pauseTotalCircle()
        pauseIntervalCircle()
        pauseActiveCircle()
    }

    func timerDidReset() {
        log.debug("SetTimerDelegate: timer reset")
        initCircleView()
        updateLabels()
    }
    
    func timerDidUpdateTime() {
        guard let set = setTimer.set, let remaining = set.remainingInInterval else {
            return
        }
        log.debug("SetTimerDelegate: timer did update to \(set.elapsed)")
        updateLabels()
        if set.audioCountdown && remaining <= 30 && remaining > 0 {
            log.debug("audio: coundown \(remaining)")
            speechQueue.enque(text: String(describing: (remaining / 10)))
        }
    }
    
    func timerDidFinish1stHalf() {
        if let set = setTimer.set, set.audioHalftime {
            log.debug("audio: halftime")
            speechQueue.enque(text: NSLocalizedString("audio-halftime", value: "Halftime", comment: "Audio feedback when halftime is reached"))
        }
        log.debug("SetTimerDelegate: timer did finish 1st half")
    }
    
    func timerDidFinish() {
        if let set = setTimer.set, set.audioFeedback {
            log.debug("audio: set finished")
            speechQueue.enque(text: NSLocalizedString("audio-finished", value: "Set Finished", comment: "Audio feedback when set finished"))
        }
        log.debug("SetTimerDelegate: timer did finish")
    }    
    
    func timerDidFinishInterval() {
        if let set = setTimer.set, set.audioFeedback {
            //speechQueue.enque(text: "interval finished")
        }
        log.debug("SetTimerDelegate: timer did finish interval")
    }

    func timerDidUpdateState() {
        log.debug("SetTimerDelegate: Interval Timer did update to state: \(self.setTimer.state)")
        updateControls()
    }
    
    func timerDidChangeSet() {
        log.debug("SetTimerDelegate: Timer Did Change Set")
        formatter.set = setTimer.set
        updateControls()
        updateTitle()
        updateLabels()
        initCircleView()
    }
    
    // MARK: - Actions
    @IBAction func toggleAction(_ sender: AnyObject) {
        log.debug("Toggle Button pressed")
        setTimer.toggle()
    }

    @IBAction func resetAction(_ sender: AnyObject) {
        log.debug("Reset Button pressed")
        setTimer.reset()
    }

    @IBAction  func undwindToTimerView(_ sender: UIStoryboardSegue) {
        log.debug("Did unwind to: TimerViewController")
        setTimer.checkTimer()
    }
    
    var isLocked = false
    @IBAction func toggleLockScreen(_ sender: AnyObject) {
        log.debug("Lock Button Pressed")
        isLocked = !isLocked
        if isLocked {
            lockButton.setTitle(NSLocalizedString("timervc-btn-unlock", value: "Unlock", comment: "Label of button to lock/unlock timer screen"), for: .normal)
        }
        else {
            lockButton.setTitle(NSLocalizedString("timervc-btn-lock", value: "Lock", comment: "Label of button to lock/unlock timer screen"), for: .normal)
        }
        setLocked(locked: isLocked)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log.debug("Pausing timer for segue")
        setTimer.pause()
        switch segue.identifier {
        case "timerVCToSetTableVC"?:
            prepareSetTableViewController(segue, sender: sender)
        case "timerVCToSetListTableVC"?:
            prepareSetListTableViewController(segue, sender: sender)
        default:
            log.error("No case for Segue identifier \(String(describing: segue.identifier))")
            break
        }
    }

    private func prepareSetTableViewController(_ segue: UIStoryboardSegue, sender: Any?) {
        log.debug("Preparing SetTableViewController")
        if  let navigationController = segue.destination as? UINavigationController,
            let setTableViewController = navigationController.visibleViewController as? SetTableViewController,
            let set = setTimer.set {
                setTableViewController.injectWith(set: set)
                setTableViewController.injectWith(dataManager: dataManger)
        }
    }

    private func prepareSetListTableViewController(_ segue: UIStoryboardSegue, sender: Any?) {
        log.debug("Preparing SetListTableViewController")
        if  let navigationController = segue.destination as? UINavigationController,
            let setListTableViewController = navigationController.visibleViewController as? SetListTableViewController {
                setListTableViewController.injectWith(dataManager: dataManger)
        }
    }
}
