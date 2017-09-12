import UIKit

enum Section {
    case title
    case duration
    case type
    case pause
}

enum Row {
    case label
    case edit
    case inline
}

protocol EditCellDelegate {
    func pickerDidUpdateInterval()
}

protocol EditTitleDelegate {
    func textFieldDidUpdateTitle()
}

class IntervalTableViewController: UITableViewController, EditCellDelegate, EditTitleDelegate {

    
    @IBOutlet weak var pauseSwitch: UISwitch!
    
    var interval: Interval?
    
    var sections:[Section] = [.title, .duration, .type, .pause]
    var rows:[Section:[Row]] =
        [.title:[.inline],.duration: [.label], .type:[.label], .pause:[.inline]]

    func row(for indexPath: IndexPath) -> Row? {
        let section = sections[indexPath.section]
        return rows[section]?[indexPath.row]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let interval = interval {
            navigationItem.title = IntervalDecorator().title(interval: (interval))
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
        return String(describing: sections[section])
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
        let decorator = IntervalDecorator()
        switch (section, row) {
        case (.duration,.label):
            let cell = tableView.dequeueReusableCell(withIdentifier: "basic", for: indexPath)
            cell.textLabel?.text = decorator.duration(interval: interval)
            cell.accessibilityLabel = "Duration"
            return cell
        case (.duration,.edit):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "editDuration", for: indexPath)
                as? EditDurationTableViewCell else { return UITableViewCell() }
            cell.accessibilityLabel = "Edit Duration"
            cell.interval = interval
            cell.selectPickerRow(for: interval)
            cell.delegate = self
            return cell
        case (.type,.label):
            let cell = tableView.dequeueReusableCell(withIdentifier: "basic", for: indexPath)
            cell.textLabel?.text = decorator.type(interval: interval)
            cell.accessibilityLabel = "Type"
            return cell
        case (.type,.edit):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "editType", for: indexPath)
                as? EditTypeTableViewCell else { return UITableViewCell() }
            cell.accessibilityLabel = "Edit Type"
            cell.interval = interval
            cell.selectRow(for: interval)
            cell.delegate = self
            return cell
        case (.pause, .inline):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "editPause", for: indexPath) as? EditPauseTableViewCell else { return UITableViewCell() }
            cell.interval = interval
            return cell
        case (.title, .inline):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "editTitle", for: indexPath) as? EditTitleTableViewCell else { return UITableViewCell() }
            cell.interval = interval
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
                    log.debug("can becomeFirstResponder: \(cell.titleField.canBecomeFirstResponder)")
                    log.debug("isEnabled: \(cell.titleField.isEnabled)")
                DispatchQueue.main.async {
                    _ = cell.titleField.becomeFirstResponder()
                }
            }
            
        }
    }
    
    func closeEditViews() {
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
            navigationItem.title = IntervalDecorator().title(interval: (interval))
        }
    }
}
