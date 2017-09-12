import UIKit
import CoreData

struct IntervalListViewModel {
    let title: String
    let description: String
    let accessabilityID: String
}

class IntervalListPresenter {
    func present(model: [Interval]) -> [IntervalListViewModel] {
        let viewModel = model.enumerated().map { (index, interval) -> IntervalListViewModel in
            present(model: interval, index: index)
        }
        return viewModel
    }
    
    func present(model: Interval, index: Int) -> IntervalListViewModel {
        let formatter = IntervalFormatter(interval: model)
        let title = formatter.title
        let description = formatter.descriptionWith(index: index)
        let accID = formatter.accessibilityIDWith(index: index)
        return IntervalListViewModel(title: title, description: description, accessabilityID: accID)
    }
}

class IntervalListTableViewController: UITableViewController, DataManagerInjectable, SetInjectable {
    
    // Mark: - Depencency Injection
    var set: Set?
    
    func injectWith(set: Set) {
        self.set = set
    }
    
    var dataManager: DataManager!
    
    func injectWith(dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    override func viewDidLoad() {
        self.tableView.allowsSelectionDuringEditing = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return set?.intervals.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let set  = set  else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Interval", for: indexPath)
        let viewModel = IntervalListPresenter().present(model: set.intervalsArray[indexPath.row], index: indexPath.row)
        cell.textLabel?.text = viewModel.title
        cell.detailTextLabel?.text = viewModel.description
        cell.accessibilityIdentifier = viewModel.accessabilityID
        cell.editingAccessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let set = set else { return }
            log.debug("Delete index path: \(indexPath)")
            //set.removeFromIntervals(at: indexPath.row)
            //tableView.deleteRows(at: [indexPath], with: .automatic)
            dataManager.persistentContainer.viewContext.delete(set.intervalsArray[indexPath.row])
            dataManager.persistentContainer.viewContext.processPendingChanges()
            tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        if let set = set {
            log.debug("Move table cell from \(fromIndexPath) to \(to)")
            let fromInterval = set.intervalsArray[fromIndexPath.row]
            set.removeFromIntervals(at: fromIndexPath.row)
            set.insertIntoIntervals(fromInterval, at: to.row)
        }
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        log.debug("table cell at \(indexPath) selected")
        performSegue(withIdentifier: "showInterval",
                     sender: self)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let intervalTableViewController = segue.destination as? IntervalTableViewController,
            let indexPath = tableView.indexPathForSelectedRow,
            let interval = set?.intervalsArray[indexPath.row]  {
                log.debug("Prepare segue to SectionIntervalTableViewController")
                intervalTableViewController.interval = interval
        }
    }
    
    // MARK: - Action
    @IBAction func editTable(_ sender: Any) {
        log.debug("Edit butten pressed")
        setEditing(!isEditing, animated: true)
    }
    
    @IBAction func addInterval(_ sender: Any) {
        log.debug("Add butten pressed")
        if let set = set {
            let newInterval = Interval(duration: 100, context: dataManager.persistentContainer.viewContext)
            let index = set.intervals.count
            set.addToIntervals(newInterval)
            let indexPath = IndexPath(row: index, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            performSegue(withIdentifier: "showInterval",
                         sender: self)
        }
    }
}
