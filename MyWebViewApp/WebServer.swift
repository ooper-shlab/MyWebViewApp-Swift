//
//  WebServer.swift
//  MyWebViewApp
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/22.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import UIKit

let kWebServiceType = "_http._tcp"
let kWebServiceDomain = "local."
let kWebServiceName = UIDevice.current.name

let WebServerErrorDomain = "WebServerErrorDomain"
let kWebServerCouldNotBindToIPv4Address = 1
let kWebServerCouldNotBindToIPv6Address = 2
let kWebServerNoSocketsAvailable = 3
let kWebServerCouldNotBindOrEstablishNetService = 4
//
let kWebServerDidNotPublish = 5

@objc
class WebServer: NSObject, WebServerRequestDelegate, NetServiceDelegate {
    var connectionBag: Set<WebServerRequest> = []
    var netService: NetService?

    override init() {
        super.init()
        do {
            try self.setupServer()
        } catch let thisError as NSError {
            fatalError(thisError.localizedDescription)
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.teardown()
    }
    
    func netServiceDidPublish(_ sender: NetService) {
        NSLog(#function)
        self.netService = sender
    }
    func netService(_ sender: NetService, didNotPublish errorDict: [String: NSNumber]) {
        NSLog(#function)
        fatalError(errorDict.description)
    }
    
    func netService(_ sender: NetService, didAcceptConnectionWith readStream: InputStream, outputStream writeStream: OutputStream) {
        OperationQueue.main.addOperation {
            CFReadStreamSetProperty(readStream, CFStreamPropertyKey(kCFStreamPropertyShouldCloseNativeSocket) , kCFBooleanTrue)
            CFWriteStreamSetProperty(writeStream, CFStreamPropertyKey(kCFStreamPropertyShouldCloseNativeSocket), kCFBooleanTrue)
            self.handleConnection(inputStream: readStream, outputStream: writeStream)
        }
    }
    
    func setupServer() throws {
        
        if self.netService != nil {
            // Calling [self run] more than once should be a NOP.
            return
        } else {
            
            if self.netService == nil {
                self.netService = NetService(domain: kWebServiceDomain, type: kWebServiceType, name: kWebServiceName, port: 0)
                self.netService?.delegate = self
            }
            
            if self.netService == nil {
                self.teardown()
                throw NSError(domain: WebServerErrorDomain, code: kWebServerCouldNotBindOrEstablishNetService, userInfo: nil)
            }
        }
    }
    
    func run() {
        do {
            try self.setupServer()
        } catch let thisError as NSError {
            fatalError(thisError.localizedDescription)
        }
        
        self.netService!.publish(options: .listenForConnections)
    }
    
    func handleConnection(inputStream readStream: InputStream, outputStream writeStream: OutputStream) {
        NSLog(#function)
        
        let newPeer = WebServerRequest(inputStream: readStream,
            outputStream: writeStream,
            delegate: self)
        
        self.connectionBag.insert(newPeer)
            
    }
    
    func webServerRequestDidProcessBody(_ request: WebServerRequest) {
        NSLog(#function)
        let producer = WebProducer.currentProducer
        producer.respondToRequest(request)
    }
    
    func webServerRequestDidFinish(_ request: WebServerRequest) {
        NSLog(#function)
        self.connectionBag.remove(request)
    }
    
    func webServerRequest(_ request: WebServerRequest, didReceiveError error: NSError) {
        NSLog(error.description)
        self.connectionBag.remove(request)
    }
    
    func teardown() {
        if self.netService != nil {
            self.netService!.stop()
            self.netService = nil
        }
    }
    
    deinit {
        self.teardown()
    }
    
}
