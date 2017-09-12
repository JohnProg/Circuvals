import UIKit

protocol TypePickerDelegate {
    func pickerDidSelect(type: IntervalType)
}

//@IBDesignable
class EditTypeTableViewCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let types = IntervalType.values
    var delegate: TypePickerDelegate?

    @IBOutlet weak var picker: UIPickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        picker.delegate = self
        picker.dataSource = self
        picker.accessibilityLabel = NSLocalizedString("type-picer-a11", value: "Type Picker", comment: "Accessibility Label for Type Picker")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return types.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(describing: types[row % types.count].readable())
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        log.debug("did select component \(component) in row \(row)")
        delegate?.pickerDidSelect(type: types[row])
    }
    
    func selectRowFor(type: IntervalType) {
        if let index = types.index(of: type) {
            log.debug("did select row \(index)")
            picker.selectRow(index, inComponent: 0, animated: false)
        }
    }
}



