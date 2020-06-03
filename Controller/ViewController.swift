//
//  ViewController.swift
//  WKWebView
//
//  Created by 黃仕杰 on 2020/6/3.
//  Copyright © 2020 shijie. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore

class ViewController: UIViewController, WKUIDelegate {

    var webView: WKWebView!;
    
    override func loadView() {
        
        createWebView();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadWebView();
    }
    
    private func createWebView(){
        let webConfiguration = WKWebViewConfiguration();
        webConfiguration.userContentController = WKUserContentController();
        webConfiguration.userContentController.add(self, name: "ToApp");
        webView = WKWebView(frame: .zero, configuration: webConfiguration);
        webView.uiDelegate = self;
        view = webView;
    }
    
    private func loadWebView(){
        let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "website")! ;
        
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.navigationDelegate = self
        webView.load(request);
        self.view.sendSubviewToBack(webView)
    }
}

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    }
}


extension ViewController: WKNavigationDelegate {
}

