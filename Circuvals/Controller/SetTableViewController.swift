import UIKit

class SetTableViewController: UITableViewController, UITextFieldDelegate, SetInjectable, DataManagerInjectable {

    @IBOutlet weak var feedbackSwitch: UISwitch!
    @IBOutlet weak var countdownSwitch: UISwitch!
    @IBOutlet weak var halftimeSwitch: UISwitch!
    @IBOutlet weak var intervalSwitch: UISwitch!
    @IBOutlet weak var repeatSetSwitch: UISwitch!

    @IBOutlet weak var titleTextField: UITextField!

    @IBOutlet weak var intervalsCell: UITableViewCell!
    
    // Mark: - Depencency Injection
    var set: Set?
    
    func injectWith(set: Set) {
        self.set = set
    }
    
    var dataManager: DataManager!
    
    func injectWith(dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let set = set else {
            return
        }
        navigationItem.title = set.title
        
        titleTextField.text = set.title
        titleTextField.delegate = self
        
        feedbackSwitch.isOn  = set.audioFeedback
        countdownSwitch.isOn = set.audioCountdown
        halftimeSwitch.isOn  = set.audioHalftime
        intervalSwitch.isOn  = set.audioInterval
        
        repeatSetSwitch.isOn = set.isRepeating
        
        let decorator = SetFormatter()
        decorator.set = set
        intervalsCell.textLabel?.text = NSLocalizedString("settvc-cell-intervals", value: "Intervals", comment: "Text label of cell containing intervals")
        intervalsCell.detailTextLabel?.text = decorator.setDescription
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log.debug("Preparing for segue to IntervalListTableViewController")
        if let set = set {
            if let intervalListTableViewController = segue.destination as? IntervalListTableViewController {
                intervalListTableViewController.injectWith(dataManager: dataManager)
                intervalListTableViewController.injectWith(set: set)
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        log.debug("Resigning first responder")
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let title = textField.text {
            log.debug("End editing, updating title")
            set?.title = title
            navigationItem.title = title
        }
    }

    // MARK: - Action
    @IBAction func feedbackSwitchAction(_ sender: UISwitch) {
        if let set = set {
            set.audioFeedback = sender.isOn
        }
        log.debug("Feedback switch clicked")
    }
    
    @IBAction func countdownSwitchClicked(_ sender: UISwitch) {
        if let set = set {
            set.audioCountdown = sender.isOn
        }
        log.debug("Countdown switch clicked")
    }
    
    @IBAction func halftimeSwitchClicked(_ sender: UISwitch) {
        if let set = set {
            set.audioHalftime = sender.isOn
        }
        log.debug("Halftime switch clicked")
    }

    @IBAction func repeatSetSwitchClicked(_ sender: UISwitch) {
        if let set = set {
            set.isRepeating = sender.isOn
        }
        log.debug("repeat set switch clicked")
    }

    @IBAction func intervalSwitchClicked(_ sender: UISwitch) {
        if let set = set {
            set.audioInterval = sender.isOn
        }
        log.debug("countdown switch clicked")
    }

    @IBAction func cancel(_ sender: AnyObject) {
        log.debug("Cancel butten pressed")
        dataManager.persistentContainer.viewContext.rollback()
        log.debug("Rolling back Context")
        self.dismiss(animated: true, completion: {})
        
    }
    
    @IBAction func save(_ sender: AnyObject) {
        log.debug("Save butten pressed")
        do {
            try dataManager.persistentContainer.viewContext.save()
            log.debug("Saved Context")
        } catch {
                fatalError("Failure to save context: \(error)")
        }
        titleTextField.resignFirstResponder()
        self.dismiss(animated: true, completion: {})
        
    }
}
