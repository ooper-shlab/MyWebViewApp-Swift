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
    @objc optional func webClient(_ client: WebClient, didFindDomain domain: String)
    @objc optional func webClient(_ client: WebClient, didFindService service: NetService)
    @objc optional func webClient(_ client: WebClient, didResolveService service: NetService)
    @objc optional func webClient(_ client: WebClient, didNotResolveWithError error: Error)
}

extension UInt8 {
    var isdigit: Bool {
        return Darwin.isdigit(Int32(self)) != 0
    }
}

class WebClient: NSObject, NetServiceBrowserDelegate, NetServiceDelegate {
    weak var delegate: WebClientDelegate?
    
    private var netServiceBrowser: NetServiceBrowser? {
        willSet(newBrowser) {
            willSetNetServiceBrowser(newBrowser)
        }
    }
    private var currentResolve: NetService?
    
    private func willSetNetServiceBrowser(_ newBrowser: NetServiceBrowser?) {
        netServiceBrowser?.stop()
    }
    
    private func commonSetup() -> Bool {
        self.netServiceBrowser = NetServiceBrowser()
        if self.netServiceBrowser == nil {
            return false
        }

        self.netServiceBrowser!.delegate = self
        return true
    }

    @discardableResult func searchForBrowsableDomains() -> Bool {
        NSLog(#function)
        if !self.commonSetup() {return false}
        self.netServiceBrowser!.searchForBrowsableDomains()
        return true
    }
    
    func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didRemoveDomain domain: String, moreComing: Bool) {
        NSLog(#function)
    }
    
    func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didFindDomain domain: String, moreComing: Bool) {
        NSLog(#function)
        if domain == kWebServiceDomain {
            self.delegate?.webClient?(self, didFindDomain: domain)
        }
    }
    
    func searchForRegistrationDomains() -> Bool {
        NSLog(#function)
        if !self.commonSetup() {return false}
        self.netServiceBrowser!.searchForRegistrationDomains()
        return true
    }
    
    private var searchingName: String?
    @discardableResult func searchForServicesOfType(_ type: String, inDomain domain: String, withName name: String) -> Bool {
        NSLog(#function)
        
        self.stopCurrentResolve()
        self.netServiceBrowser?.stop()
        
        let aNetServiceBrowser = NetServiceBrowser()
        
        aNetServiceBrowser.delegate = self
        self.netServiceBrowser = aNetServiceBrowser
        self.searchingName = name
        self.netServiceBrowser!.searchForServices(ofType: type, inDomain: domain)
        
        return true
    }
    
    func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        NSLog(#function)
        if self.currentResolve != nil && service == self.currentResolve! {
            self.stopCurrentResolve()
        }
    }
    
    func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        NSLog(#function)
        if service.name == searchingName {
            self.stopCurrentResolve()
            self.delegate?.webClient?(self, didFindService: service)
        }
    }
    
    func resolve(_ service: NetService) {
        NSLog(#function)
        if self.currentResolve != nil {
            self.stopCurrentResolve()
        }
        
        self.currentResolve = service
        self.currentResolve!.delegate = self
        
        self.currentResolve!.resolve(withTimeout: 0.0)
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        NSLog(#function)
        self.stopCurrentResolve()
        let error = NSError(domain: WebClientErrorDomain, code: kWebClientDidNotResolve, userInfo: errorDict)
        self.delegate?.webClient?(self, didNotResolveWithError: error)
    }
    
    func netServiceDidResolveAddress(_ service: NetService) {
        NSLog(#function)
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
