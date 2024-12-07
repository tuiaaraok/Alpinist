//
//  PrivacyViewController.swift
//  Alpinist
//
//  Created by Karen Khachatryan on 07.12.24.
//


import UIKit
import WebKit

class PrivacyViewController: UIViewController {
    private var webView: WKWebView!
    private let urlString = "https://docs.google.com/document/d/17GiiAK4QqSsG1RN_fL2klk19RqVvCoJHjpkFL_A7aZU/mobilebasic"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: self.view.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(webView)
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
