import UIKit

protocol TitleFieldDelegate {
    func fieldSetTo(title: String)
}

class EditTitleTableViewCell: UITableViewCell, UITextFieldDelegate {
    var titleField: UITextField = UITextField()
    var delegate: TitleFieldDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleField.delegate = self
        titleField.contentVerticalAlignment = .center
        titleField.clearButtonMode = .whileEditing
        titleField.placeholder = NSLocalizedString("edittitlecell-title-placeholder", value: "Add title", comment: "Placeholder of title textfield")
        self.contentView.addSubview(titleField)
        // Initialization code
    }
    
    let leftMarginForLabel: CGFloat = 15.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleField.frame = CGRect(x: leftMarginForLabel, y: 0, width: bounds.size.width - leftMarginForLabel, height: bounds.size.height)
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
            delegate?.fieldSetTo(title: title)
        }
    }

}
