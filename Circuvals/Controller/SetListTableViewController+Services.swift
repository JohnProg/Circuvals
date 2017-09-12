import UIKit

extension SetListTableViewController {
    func createAddSheet(dataManager: DataManager) -> UIAlertController {
        let moc = dataManager.persistentContainer.viewContext
        let addNewSetTitle = NSLocalizedString("setlisttvc-act-add-title", value: "Add New Set", comment: "Title of action sheet to create a new set")
        let addNewSetMessage = NSLocalizedString("setlisttvc-act-add-msg", value: "Choose a template …", comment: "Message of action sheet to create a new set")
        let alert = UIAlertController(title: addNewSetTitle, message: addNewSetMessage, preferredStyle: .actionSheet)
        let tabataTitle = NSLocalizedString("setlisttvc-set-tabata", value: "Tabata", comment: "Title of tabata set")
        let addTabata = UIAlertAction(title: tabataTitle, style: .default, handler: {(action) in
            log.debug("Tabata Button pressed")
            dataManager.saveContext()
            _ = SetFactory.tabataSet(context: moc)
            moc.processPendingChanges()
        })
        let littleTitle = NSLocalizedString("setlisttvc-set-little", value: "Little Method", comment: "Title of little method set")
        let addLittle = UIAlertAction(title: littleTitle, style: .default, handler: {(action) in
            log.debug("Little Method Button pressed")
            dataManager.saveContext()
            _ = SetFactory.littleMethodSet(context: moc)
            moc.processPendingChanges()
        })
        let customTitle = NSLocalizedString("setlisttvc-set-custom", value: "Custom", comment: "Title of custom set")
        let addCustom = UIAlertAction(title: customTitle, style: .default, handler: {(action) in
            log.debug("Custom Button pressed")
            dataManager.saveContext()
            let set = Set(context: moc)
            let customSetTitle = NSLocalizedString("model-set-custom", value: "Custom Set", comment: "Title of a custom set")
            set.title = customSetTitle
            moc.processPendingChanges()
        })
        let cancelTitle = NSLocalizedString("setlisttvc-act-cancel", value: "Cancel", comment: "Title of cancel sheet action")
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: { (_) in log.debug("Cancel Button pressed")})
        alert.addAction(addTabata)
        alert.addAction(addLittle)
        alert.addAction(addCustom)
        alert.addAction(cancelAction)
        return alert
    }
}
