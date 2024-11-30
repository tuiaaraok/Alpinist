//
//  SettingsViewController.swift
//  Alpinist
//
//  Created by Karen Khachatryan on 30.11.24.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet var settingsButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNaviagtionBackButton()
        setNavigationTitle(title: "Settings")
        settingsButtons.forEach({ $0.titleLabel?.font = .bold(size: 26) })
    }


    @IBAction func clickedContactUs(_ sender: UIButton) {
    }
    @IBAction func clickedPrivacyPolicy(_ sender: UIButton) {
    }
    @IBAction func clickedRateUs(_ sender: UIButton) {
    }
}
