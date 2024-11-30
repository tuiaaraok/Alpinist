//
//  MemberTableViewCell.swift
//  Alpinist
//
//  Created by Karen Khachatryan on 29.11.24.
//

import UIKit

protocol MemberTableViewCellDelegate: AnyObject {
    func changeName(cell: UITableViewCell, value: String?)
}

class MemberTableViewCell: UITableViewCell {

    @IBOutlet weak var nameTextField: BaseTextField!
    weak var delegate: MemberTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        nameTextField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(name: String?) {
        self.nameTextField.text = name
    }
}

extension MemberTableViewCell: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        delegate?.changeName(cell: self, value: textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
    }
}
