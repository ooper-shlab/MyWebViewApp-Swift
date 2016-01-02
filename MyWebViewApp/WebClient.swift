//
//  WebClient.swift
//  MyWebViewApp
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/19.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import Foundation

let WebClientErrorDomain = "WebClientErrorDomain"
let kWebClientDidNotResolve = 1

@objc protocol WebClientDelegate {
    optional func webClient(client: WebClient, didFindDomain domain: String)
    optional func webClient(client: WebClient, didFindService service: NSNetService)
    optional func webClient(client: WebClient, didResolveService service: NSNetService)
    optional func webClient(client: WebClient, didNotResolveWithError error: NSError)
}

extension UInt8 {
    var isdigit: Bool {
        return Darwin.isdigit(Int32(self)) != 0
    }
}

class WebClient: NSObject, NSNetServiceBrowserDelegate, NSNetServiceDelegate {
    weak var delegate: WebClientDelegate?
    
    private var netServiceBrowser: NSNetServiceBrowser? {
        willSet(newBrowser) {
            willSetNetServiceBrowser(newBrowser)
        }
    }
    private var currentResolve: NSNetService?
    
    private func willSetNetServiceBrowser(newBrowser: NSNetServiceBrowser?) {
        netServiceBrowser?.stop()
    }
    
    private func commonSetup() -> Bool {
        self.netServiceBrowser = NSNetServiceBrowser()
        if self.netServiceBrowser == nil {
            return false
        }

        self.netServiceBrowser!.delegate = self
        return true
    }

    func searchForBrowsableDomains() -> Bool {
        NSLog(__FUNCTION__)
        if !self.commonSetup() {return false}
        self.netServiceBrowser!.searchForBrowsableDomains()
        return true
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveDomain domain: String, moreComing: Bool) {
        NSLog(__FUNCTION__)
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindDomain domain: String, moreComing: Bool) {
        NSLog(__FUNCTION__)
        if domain == kWebServiceDomain {
            self.delegate?.webClient?(self, didFindDomain: domain)
        }
    }
    
    func searchForRegistrationDomains() -> Bool {
        NSLog(__FUNCTION__)
        if !self.commonSetup() {return false}
        self.netServiceBrowser!.searchForRegistrationDomains()
        return true
    }
    
    private var searchingName: String?
    func searchForServicesOfType(type: String, inDomain domain: String, withName name: String) -> Bool {
        NSLog(__FUNCTION__)
        
        self.stopCurrentResolve()
        self.netServiceBrowser?.stop()
        
        let aNetServiceBrowser = NSNetServiceBrowser()
        
        aNetServiceBrowser.delegate = self
        self.netServiceBrowser = aNetServiceBrowser
        self.searchingName = name
        self.netServiceBrowser!.searchForServicesOfType(type, inDomain: domain)
        
        return true
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool) {
        NSLog(__FUNCTION__)
        if self.currentResolve != nil && service == self.currentResolve! {
            self.stopCurrentResolve()
        }
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool) {
        NSLog(__FUNCTION__)
        if service.name == searchingName {
            self.stopCurrentResolve()
            self.delegate?.webClient?(self, didFindService: service)
        }
    }
    
    func resolve(service: NSNetService) {
        NSLog(__FUNCTION__)
        if self.currentResolve != nil {
            self.stopCurrentResolve()
        }
        
        self.currentResolve = service
        self.currentResolve!.delegate = self
        
        self.currentResolve!.resolveWithTimeout(0.0)
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        NSLog(__FUNCTION__)
        self.stopCurrentResolve()
        let error = NSError(domain: WebClientErrorDomain, code: kWebClientDidNotResolve, userInfo: errorDict)
        self.delegate?.webClient?(self, didNotResolveWithError: error)
    }
    
    func netServiceDidResolveAddress(service: NSNetService) {
        NSLog(__FUNCTION__)
        assert(service === self.currentResolve)
        
        self.stopCurrentResolve()
        
        self.delegate?.webClient?(self, didResolveService: service)
    }
    
    private func stopCurrentResolve() {
        self.currentResolve?.stop()
        self.currentResolve = nil
    }
    
    
    deinit {
        self.stopCurrentResolve()
        self.netServiceBrowser?.stop()
    }
}