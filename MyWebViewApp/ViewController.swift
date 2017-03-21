//
//  ViewController.swift
//  MyWebViewApp
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/19.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import UIKit

class ViewController: UIViewController, WebClientDelegate, UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView!
    
    var webClient: WebClient!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        webView.delegate = self
        
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
        webView.loadRequest(request)
    }
    
    func webClient(_ client: WebClient, didNotResolveWithError error: Error) {
        //
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
