//
//  PrivacyWebViewController.swift
//  Alpinist
//
//  Created by Karen Khachatryan on 07.12.24.
//


import UIKit
import WebKit

class PrivacyWebViewController: UIViewController, WKNavigationDelegate {

    private var webView: WKWebView!
    private var agreeButton: UIButton!
    var showAgreeButton: Bool = false
    var currentUrlString: String?
    var completion: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupAgreeButton()
        if let url = currentUrlString {
            loadUrl(url)
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
    func loadUrl(_ urlString: String) {
        self.currentUrlString = urlString
        guard let url = URL(string: urlString) else { return }
        webView.load(URLRequest(url: url))
    }

    private func setupWebView() {
        webView = WKWebView(frame: self.view.bounds)
        webView.navigationDelegate = self
        self.view.addSubview(webView)
    }
    
    private func setupAgreeButton() {
        agreeButton = BaseButton(frame: CGRect(x: 20, y: view.bounds.height - 80, width: view.bounds.width - 40, height: 60))
        agreeButton.titleLabel?.font = .bold(size: 26)
        agreeButton.backgroundColor = .baseGreen
        agreeButton.setTitleColor(.black, for: .normal)
        agreeButton.layer.cornerRadius = 12
        agreeButton.setTitle("I Agree", for: .normal)
        agreeButton.addTarget(self, action: #selector(clickedAgree), for: .touchUpInside)
        agreeButton.isHidden = true
        self.view.addSubview(agreeButton)
    }

    @objc private func clickedAgree() {
        agreeButton.isHidden = true
        webView.removeFromSuperview()
        UserDefaults.standard.set(true, forKey: "agreeButtonClickedInSession")
        self.navigationController?.popViewController(animated: false)
        self.completion?()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let urlString = navigationAction.request.url?.absoluteString {
            if urlString.contains("showAgreebutton") {
                UserDefaults.standard.set(true, forKey: "showAgreebuttonFlag")
                agreeButton.isHidden = false
            } else if !UserDefaults.standard.bool(forKey: "showAgreebuttonFlag") {
                (UIApplication.shared.delegate as? AppDelegate)?.saveUrl(urlString)
            }
        }
        decisionHandler(.allow)
    }
}


