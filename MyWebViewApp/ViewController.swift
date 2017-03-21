//
//  ViewController.swift
//  MyWebViewApp
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/19.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var frame = self.view!.bounds
        frame.origin.y += 20
        frame.size.height -= 20
        let webView = WKWebView(frame: frame)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.view!.addSubview(webView)
        self.webView = webView
        
        let port = (UIApplication.shared.delegate as! AppDelegate).serverPort
        let urlString = "http://127.0.0.1:\(port)/aaa/bbb/ccc"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        webView.load(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
