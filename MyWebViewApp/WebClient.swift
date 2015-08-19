//
//  WebClient.swift
//  MyWebViewApp
//
//  Created by 開発 on 2015/8/19.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

let WebClientErrorDomain = "WebClientErrorDomain"
let kWebClientDidNotResolve = 1

@objc protocol WebClientDelegate {
    optional func webClient(client: WebClient, didFindDomain domain: String)
    optional func webClient(client: WebClient, didFindService service: NSNetService?)
    optional func webClient(client: WebClient, didResolveService service: NSNetService?)
    optional func webClient(client: WebClient, didNotResolveWithError error: NSError)
}

extension UInt8 {
    var isdigit: Bool {
        return Darwin.isdigit(Int32(self)) != 0
    }
}

class WebClient: NSObject, NSNetServiceBrowserDelegate, NSNetServiceDelegate {
    weak var delegate: WebClientDelegate?
    
    private var domains: [String] = []
    private var netServiceBrowser: NSNetServiceBrowser? {
        willSet(newBrowser) {
            willSetNetServiceBrowser(newBrowser)
        }
    }

    private var services: [NSNetService] = []
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
        if !self.commonSetup() {return false}
        self.netServiceBrowser!.searchForBrowsableDomains()
        return true
    }
    
    func searchForRegistrationDomains() -> Bool {
        if !self.commonSetup() {return false}
        self.netServiceBrowser!.searchForRegistrationDomains()
        return true
    }
    
    private func transmogrify(aString: String) -> String {

        let buflen = aString.utf8.count + 1
        let ostr: UnsafeMutablePointer<CChar> = aString.withCString {tmp in
            let ostr = UnsafeMutablePointer<CChar>.alloc(buflen)
            var cstr = UnsafePointer<UInt8>(tmp)
            var ptr = UnsafeMutablePointer<UInt8>(ostr)

            while cstr.memory != 0 {
                var c = (cstr++).memory
                if c == UInt8(ascii: "\\") {
                    c = (cstr++).memory
                    if cstr[-1].isdigit && cstr[0].isdigit && cstr[1].isdigit {
                        let v0 = cstr[-1] - UInt8(ascii: "0")
                        let v1 = cstr[ 0] - UInt8(ascii: "0")
                        let v2 = cstr[ 1] - UInt8(ascii: "0")
                        let val = v0 * 100 + v1 * 10 + v2
                        if (val <= 255) { c = UInt8(val); cstr += 2; }
                    }
                }
                (ptr++).memory = c
            }
            ptr--
            ptr.memory = 0
            return ostr
        }
        let result = String.fromCString(ostr)!
        ostr.dealloc(buflen)
        return result
    }

    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveDomain domain: String, moreComing: Bool) {
        self.domains.removeAtIndex(self.domains.indexOf(transmogrify(domain))!)
    }

    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindDomain domain: String, moreComing: Bool) {
        let tmp = self.transmogrify(domain)
        if !self.domains.contains(tmp) {
            self.domains.append(tmp)
            self.delegate?.webClient?(self, didFindDomain: tmp)
        }
    }
    
    func searchForServicesOfType(type: String, inDomain domain: String) -> Bool {
        
        self.stopCurrentResolve()
        self.netServiceBrowser?.stop()
        self.services.removeAll()
        
        let aNetServiceBrowser = NSNetServiceBrowser()
        
        aNetServiceBrowser.delegate = self
        self.netServiceBrowser = aNetServiceBrowser
        self.netServiceBrowser!.searchForServicesOfType(type, inDomain: domain)
        
        return true
    }
    func resolve(service: NSNetService) {
        if self.currentResolve != nil {
            self.stopCurrentResolve()
        }
        
        self.currentResolve = service
        self.currentResolve!.delegate = self
        
        self.currentResolve!.resolveWithTimeout(0.0)
    }
    
    private func stopCurrentResolve() {
        self.currentResolve?.stop()
        self.currentResolve = nil
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool) {
        if self.currentResolve != nil && service == self.currentResolve! {
            self.stopCurrentResolve()
        }
        self.services.removeAtIndex(self.services.indexOf(service)!)
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool) {
        self.services.append(service)
        self.delegate?.webClient?(self, didFindService: service)
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        self.stopCurrentResolve()
        let error = NSError(domain: WebClientErrorDomain, code: kWebClientDidNotResolve, userInfo: errorDict)
        self.delegate?.webClient?(self, didNotResolveWithError: error)
    }
    
    func netServiceDidResolveAddress(service: NSNetService) {
        assert(service === self.currentResolve)
        
        self.stopCurrentResolve()
        
        self.delegate?.webClient?(self, didResolveService: service)
    }
    
    
    func cancelAction() {
        self.delegate?.webClient?(self, didResolveService: nil)
    }
    
    
    deinit {
        self.stopCurrentResolve()
        self.netServiceBrowser?.stop()
        
    }
}