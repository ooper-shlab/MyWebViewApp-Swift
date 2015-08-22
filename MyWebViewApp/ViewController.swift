//
//  ViewController.swift
//  MyWebViewApp
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/19.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
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
    
    func webClient(client: WebClient, didFindDomain domain: String) {
        NSLog(__FUNCTION__)
        if domain == kWebServiceDomain {
            webClient.searchForServicesOfType(kWebServiceType, inDomain: domain, withName: kWebServiceName)
        }
    }
    
    func webClient(client: WebClient, didFindService service: NSNetService) {
        NSLog(__FUNCTION__)
        webClient.resolve(service)
    }
    
    func webClient(client: WebClient, didResolveService service: NSNetService) {
        let hostName = service.hostName!
        let port = service.port
        let urlString = "http://\(hostName):\(port)"
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
    }
    
    func webClient(client: WebClient, didNotResolveWithError error: NSError) {
        //
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

