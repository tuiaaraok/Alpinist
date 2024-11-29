//
//  MenuViewController.swift
//  Alpinist
//
//  Created by Karen Khachatryan on 29.11.24.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet var sectionButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionButtons.forEach({ $0.titleLabel?.font = .bold(size: 26) })
    }

    @IBAction func clickedPlaces(_ sender: UIButton) {
        self.pushViewController(PlacesViewController.self)
    }
    
    @IBAction func clickedEquipmentList(_ sender: UIButton) {
    }
    @IBAction func clickedSettings(_ sender: UIButton) {
    }
}
