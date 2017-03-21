//
//  ViewController.swift
//  MyWebViewApp
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/19.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import UIKit
import WebKit

class ViewController: UIViewController, WebClientDelegate, WKUIDelegate, WKNavigationDelegate {
    weak var webView: WKWebView!
    
    var webClient: WebClient!

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
        
        webClient = WebClient()
        webClient.delegate = self
        webClient.searchForBrowsableDomains()
    }
    
    func webClient(_ client: WebClient, didFindDomain domain: String) {
        NSLog(#function)
        if domain == kWebServiceDomain {
            webClient.searchForServicesOfType(kWebServiceType, inDomain: domain, withName: kWebServiceName)
        }
    }
    
    func webClient(_ client: WebClient, didFindService service: NetService) {
        NSLog(#function)
        webClient.resolve(service)
    }
    
    func webClient(_ client: WebClient, didResolveService service: NetService) {
        let hostName = service.hostName!
        let port = service.port
        let urlString = "http://\(hostName):\(port)/aaa/bbb/ccc"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func webClient(_ client: WebClient, didNotResolveWithError error: Error) {
        //
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
