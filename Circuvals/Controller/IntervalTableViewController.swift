import UIKit

enum Section {
    case title
    case duration
    case type
    case settings
}

enum Row {
    case label
    case edit
    case inline
}

class IntervalTableViewController: UITableViewController, DurationPickerDelegate, TypePickerDelegate, TitleFieldDelegate {
    
    @IBOutlet weak var pauseSwitch: UISwitch!
    
    var interval: Interval?
    
    private var sections:[Section] = [.title, .duration, .type, .settings]
    private var rows:[Section:[Row]] =
        [.title:[.inline],.duration: [.label], .type:[.label], .settings:[.inline]]

    private func row(for indexPath: IndexPath) -> Row? {
        let section = sections[indexPath.section]
        return rows[section]?[indexPath.row]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let unwrappedInterval = interval {
            navigationItem.title = IntervalFormatter(interval: unwrappedInterval).title
            navigationController?.delegate = self
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section] {
        case .duration:
            return NSLocalizedString("intervaltvc-section-duration", value: "Duration", comment: "Duration of Interval")
        case .type:
            return NSLocalizedString("intervaltvc-section-type", value: "Type", comment: "Type of Interval")
        case .title:
            return NSLocalizedString("intervaltvc-section-title", value: "Title", comment: "Title of Interval")
        case .settings:
            return NSLocalizedString("intervaltvc-section-settings", value: "Settings", comment: "Settings of Interval")
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sec = sections[section]
        return rows[sec]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let rows = rows[section],
            let interval = interval else { return UITableViewCell() }
        let row = rows[indexPath.row]
        let formatter = IntervalFormatter(interval: interval)
        switch (section, row) {
        case (.duration,.label):
            let cell = tableView.dequeueReusableCell(withIdentifier: "basic", for: indexPath)
            cell.textLabel?.text = formatter.duration
            cell.accessibilityLabel = "Duration"
            return cell
        case (.duration,.edit):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "editDuration", for: indexPath)
                as? EditDurationTableViewCell else { return UITableViewCell() }
            cell.accessibilityLabel = "Edit Duration"
            cell.delegate = self
            cell.selectRowsFor(duration: interval.duration)
            return cell
        case (.type,.label):
            let cell = tableView.dequeueReusableCell(withIdentifier: "basic", for: indexPath)
            cell.textLabel?.text = formatter.type
            cell.accessibilityLabel = "Type"
            return cell
        case (.type,.edit):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "editType", for: indexPath)
                as? EditTypeTableViewCell else { return UITableViewCell() }
            cell.accessibilityLabel = "Edit Type"
            cell.delegate = self
            cell.selectRowFor(type: interval.intervalType)
            return cell
        case (.settings, .inline):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "editPause", for: indexPath) as? SettingTableViewCell else { return UITableViewCell() }
            cell.pauseSwitch.setOn(interval.pause, animated: false)
            cell.pauseSwitch.addTarget(self, action: #selector(pauseSwitchClicked(sender:)), for: UIControlEvents.valueChanged)
            cell.textLabel?.text = NSLocalizedString("intervaltvc-cell-pause-lable", value: "Settings", comment: "Pause at begin")
            return cell
        case (.title, .inline):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "editTitle", for: indexPath) as? EditTitleTableViewCell else { return UITableViewCell() }
            cell.titleField.text = interval.title ?? ""
            cell.titleField.isEnabled = false
            cell.delegate = self
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let row = row(for: indexPath) else {return }
        switch row {
        case .edit:
            log.debug("edit cell clicked")
            closeEditViews()
            let indices = IndexSet(sections.startIndex..<sections.endIndex)
            tableView.reloadSections(indices, with: .automatic)
        case .label:
            log.debug("label cell clicked")
            guard let rowsInSection = rows[sections[indexPath.section]] else { return }
            if rowsInSection == [.label, .edit] {
                log.debug("edit view open: closing edit view")
                rows[sections[indexPath.section]] = [.label]
            }
            else {
                closeEditViews()
                log.debug("opening edit view")
                rows[sections[indexPath.section]] = [.label, .edit]
            }
            let indices = IndexSet(sections.startIndex..<sections.endIndex)
            tableView.reloadSections(indices, with: .automatic)
        case .inline:
            log.debug("inline cell clicked")
            closeEditViews()
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.reloadData()
            if let cell = tableView.cellForRow(at: indexPath) as? EditTitleTableViewCell {
                    cell.titleField.isEnabled = true
                DispatchQueue.main.async {
                    _ = cell.titleField.becomeFirstResponder()
                }
            }
            
        }
    }
    
    private func closeEditViews() {
        log.debug("closing edit views")
        for section in sections {
            if let row = rows[section], row == [.label, .edit] {
                rows[section] = [.label]
            }
        }
    }
    
    //MARK: - EditCellDelegate
    func pickerDidUpdateInterval() {
        tableView.reloadData()
    }
    
    func textFieldDidUpdateTitle() {
        if let interval = interval {
            navigationItem.title = IntervalFormatter(interval: interval).title
        }
    }
    
    func pickerDidSelect(minutes: Int, seconds: Int) {
        interval?.duration = Int64((minutes * 60 + seconds) * 10)
    }
    
    func pickerDidSelect(type: IntervalType) {
        interval?.intervalType = type
    }
    
    func fieldSetTo(title: String) {
        interval?.title = title
    }
    
    @IBAction func pauseSwitchClicked(sender: UISwitch) {
        guard let interval = interval else {
            return
        }
        interval.pause = sender.isOn
    }



}

extension IntervalTableViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        (viewController as? IntervalListTableViewController)?.tableView.reloadData()
    }
}
