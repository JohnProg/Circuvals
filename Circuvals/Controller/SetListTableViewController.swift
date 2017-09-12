import UIKit
import CoreData

class SetListTableViewController: UITableViewController, DataManagerInjectable {
    // Mark: - Depencency Injection
    private var dataManager: DataManager!
    private var fetchedResultsController: NSFetchedResultsController<Set>!
    
    func injectWith(dataManager: DataManager) {
        self.dataManager = dataManager
        let request: NSFetchRequest<Set> = Set.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: dataManager.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: "root")
    }
    
    private let formatter = SetFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchedResultsController.delegate = self
        self.tableView.allowsSelectionDuringEditing = true
        do {
            log.debug("Fetching saved sets")
            try fetchedResultsController.performFetch()
        }
        catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        //enable rollback on cancel
        log.debug("Saving Context for rollback")
        dataManager.saveContext()
        // self.clearsSelectionOnViewWillAppear = false
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "unwindToTimer"?:
            prepareUnwindToTimer(segue)
        case "SetListTableVCToSetTableVC"?:
                prepareSetTableViewController(segue, sender: sender)
        default:
            log.error("No case for Segue identifier \(String(describing: segue.identifier))")
            break
        }
    }
    
    func prepareUnwindToTimer(_ segue: UIStoryboardSegue) {
        log.debug("Prepare Segue unwindToTimer")
        if let timerViewController = segue.destination as? TimerViewController {
            timerViewController.injectWith(dataManager: dataManager)
            if let indexPath = tableView.indexPathForSelectedRow {
                timerViewController.injectWith(set: fetchedResultsController.object(at: indexPath))
            }
        }
        else {
            fatalError()
        }
    }
    
    func prepareSetTableViewController(_ segue: UIStoryboardSegue, sender: Any?) {
        log.debug("Preparing SetTableViewController")
        if  let navigationController = segue.destination as? UINavigationController,
            let setTableViewController = navigationController.visibleViewController as? SetTableViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            setTableViewController.injectWith(set: fetchedResultsController.object(at: indexPath))
            setTableViewController.injectWith(dataManager: dataManager)
        }
        else {
            fatalError()
        }
    }
    
    // MARK: - Action
    @IBAction func backButtonPressed(_ sender: Any) {
        log.debug("Back Button pressed")
        performSegue(withIdentifier: "unwindToTimer",
                     sender: nil)
    }
    
    @IBAction func editTableButtonPressed(_ sender: AnyObject) {
        log.debug("Edit Button pressed")
        self.setEditing(!isEditing, animated: true)
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        log.debug("Add Button pressed")
        self.present(createAddSheet(dataManager: dataManager), animated: true)
    }
}

// MARK: - Table view delegate
extension SetListTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        log.debug("did select row \(indexPath)")
        if isEditing {
            log.debug("Save Context for Rollback")
            dataManager.saveContext()
            log.debug("Perform Segue: SetListVCToSetTableVC")
            performSegue(withIdentifier: "SetListTableVCToSetTableVC",
                         sender: fetchedResultsController.fetchedObjects?[indexPath.row])
        }
        else {
            log.debug("Performe Segue unwindToTimer")
            performSegue(withIdentifier: "unwindToTimer",
                         sender: tableView.cellForRow(at: indexPath))
        }
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteText = NSLocalizedString("setlisttvc-act-delete", value: "Delete", comment: "Label of button to delete set")
        let deleteAction = UITableViewRowAction(style: .default, title: deleteText, handler:{action, indexpath in
            log.debug("Delete Action pressed")
            // TODO Refactor to DataManagerService
            let set = self.fetchedResultsController.object(at: indexPath)
            //Delete Set
            self.dataManager.persistentContainer.viewContext.delete(set)
            self.dataManager.persistentContainer.viewContext.processPendingChanges()
            //Update Index of remaining
            if let sets = self.fetchedResultsController.fetchedObjects {
                for (index, set) in (sets.enumerated()) {
                    set.index = Int64(index)
                }
            }
            self.dataManager.persistentContainer.viewContext.processPendingChanges()
        })
        deleteAction.accessibilityLabel = NSLocalizedString("setlisttcv-act-a11-delete", value: "Delete Set", comment: "Accessibility label of button to delete set")
        let editText = NSLocalizedString("setlisttvc-act-edit", value: "Edit", comment: "Label of button to edit set")
        let editAction = UITableViewRowAction(style: .default, title: editText, handler:{action, indexpath in
            log.debug("Edit Action pressed")
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            self.performSegue(withIdentifier: "SetListTableVCToSetTableVC",
                              sender: self)
        })
        editAction.backgroundColor = UIColor.blue
        editAction.accessibilityLabel = NSLocalizedString("setlisttvc-act-ac11-edit", value: "Edit Set", comment: "Accessibility label of button to edit set")
        return [deleteAction, editAction]
    }
}

// MARK: - Table view data source
extension SetListTableViewController {
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else {
            return
        }
        let thing = fetchedResultsController.object(at: fromIndexPath)
        var things = fetchedObjects
        things.remove(at: fromIndexPath.row)
        things.insert(thing, at: to.row)
        for (index, set) in (things.enumerated()) {
            set.index = Int64(index)
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if isEditing {
            return .none
        }
        return .delete
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        return sections[section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Set", for: indexPath)
        return configure(cell, at: indexPath)
    }
    
    private func configure(_ cell: UITableViewCell, at indexPath: IndexPath) -> UITableViewCell {
        let set = fetchedResultsController.object(at: indexPath)
        formatter.set = set
        cell.editingAccessoryType = .disclosureIndicator
        cell.accessoryType = .none
        cell.textLabel?.text = set.title
        cell.detailTextLabel?.text = formatter.setDescription + " " + "(\(set.index))"
        
        cell.accessibilityLabel = set.title
        cell.accessibilityIdentifier = "Set" + String(describing: indexPath.row)
        return cell
    }
}

// MARK: - NSFetchedResultControllerDelegate
extension SetListTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch(type) {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            tableView.selectRow(at: newIndexPath, animated: true, scrollPosition: .none)
            performSegue(withIdentifier: "SetListTableVCToSetTableVC", sender: self)
        case .delete:
            if let deletePath = indexPath {
                tableView.deleteRows(at: [deletePath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                let _ = configure(cell, at: indexPath)
            }
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
}
