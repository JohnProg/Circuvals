import UIKit

protocol DurationPickerDelegate {
    func pickerDidSelect(minutes: Int, seconds: Int)
}

class EditDurationTableViewCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var picker: UIPickerView!
    var delegate: DurationPickerDelegate?
    
    let seconds = Array(0...60)
    let minutes = Array(0...15)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        picker.dataSource = self
        picker.delegate = self
        picker.accessibilityLabel = "Duration"
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return minutes.count * 3
        case 1:
            return seconds.count * 3
        default:
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return String(minutes[row % minutes.count]) + " min"
        case 1:
            return String(seconds[row % seconds.count]) + " sec"
        default:
            return ""
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        log.debug("did select component \(component) in row \(row)")
        let min = minutes[pickerView.selectedRow(inComponent: 0) % minutes.count]
        let sec = seconds[pickerView.selectedRow(inComponent: 1) % seconds.count]
        delegate?.pickerDidSelect(minutes: min, seconds: sec)
    }
    
    func selectRowsFor(duration: Int64) {
        let durationInSeconds = Int(duration/10)
        let min = Int(durationInSeconds / 60)
        let sec = Int(durationInSeconds % 60)
        log.debug("did move component 0 to row \(minutes.count + min)")
        picker.selectRow(minutes.count + min, inComponent: 0, animated: false)
        log.debug("did move component 1 to row \(seconds.count + sec)")
        picker.selectRow(seconds.count + sec, inComponent: 1, animated: false)
    }
}
