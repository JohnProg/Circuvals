import UIKit

@IBDesignable class SettingTableViewCell: UITableViewCell {
    var pauseSwitch: UISwitch = UISwitch()
    
    override func prepareForInterfaceBuilder() {
        self.accessoryView = pauseSwitch
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryView = pauseSwitch
    }
}
