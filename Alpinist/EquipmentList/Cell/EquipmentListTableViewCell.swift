//
//  EquipmentListTableViewCell.swift
//  Alpinist
//
//  Created by Karen Khachatryan on 29.11.24.
//

import UIKit

protocol EquipmentListTableViewCellDelegate: AnyObject {
    func confirmed(by id: UUID)
}

class EquipmentListTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkBoxButton: CheckBoxButton!
    var id: UUID?
    weak var delegate: EquipmentListTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        nameLabel.font = .medium(size: 24)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        id = nil
    }
    
    func configure(equipment: EquipmentModel) {
        id = equipment.id
        nameLabel.text = equipment.name
        checkBoxButton.isSelected = equipment.isConfirmed
    }
    
    @IBAction func clickedCheckBox(_ sender: CheckBoxButton) {
        if let id = id {
            checkBoxButton.isSelected = !checkBoxButton.isSelected
            delegate?.confirmed(by: id)
        }
    }
}
