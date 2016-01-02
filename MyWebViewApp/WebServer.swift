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
let kWebServiceName = UIDevice.currentDevice().name

let WebServerErrorDomain = "WebServerErrorDomain"
let kWebServerCouldNotBindToIPv4Address = 1
let kWebServerCouldNotBindToIPv6Address = 2
let kWebServerNoSocketsAvailable = 3
let kWebServerCouldNotBindOrEstablishNetService = 4
//
let kWebServerDidNotPublish = 5

@objc
class WebServer: NSObject, WebServerRequestDelegate, NSNetServiceDelegate {
    var connectionBag: Set<WebServerRequest> = []
    var netService: NSNetService?

    override init() {
        super.init()
        do {
            try self.setupServer()
        } catch let thisError as NSError {
            fatalError(thisError.localizedDescription)
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        self.teardown()
    }
    
    func netServiceDidPublish(sender: NSNetService) {
        NSLog(__FUNCTION__)
        self.netService = sender
    }
    func netService(sender: NSNetService, didNotPublish errorDict: [String: NSNumber]) {
        NSLog(__FUNCTION__)
        fatalError(errorDict.description)
    }
    
    func netService(sender: NSNetService, didAcceptConnectionWithInputStream readStream: NSInputStream, outputStream writeStream: NSOutputStream) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue)
            CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue)
            self.handleConnection(inputStream: readStream, outputStream: writeStream)
        }
    }
    
    func setupServer() throws {
        
        if self.netService != nil {
            // Calling [self run] more than once should be a NOP.
            return
        } else {
            
            if self.netService == nil {
                self.netService = NSNetService(domain: kWebServiceDomain, type: kWebServiceType, name: kWebServiceName, port: 0)
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
        
        self.netService!.publishWithOptions(.ListenForConnections)
    }
    
    func handleConnection(inputStream readStream: NSInputStream, outputStream writeStream: NSOutputStream) {
        NSLog(__FUNCTION__)
        
        let newPeer = WebServerRequest(inputStream: readStream,
            outputStream: writeStream,
            delegate: self)
        
        self.connectionBag.insert(newPeer)
            
    }
    
    func webServerRequestDidProcessBody(request: WebServerRequest) {
        NSLog(__FUNCTION__)
        let producer = WebProducer.currentProducer
        producer.respondToRequest(request)
    }
    
    func webServerRequestDidFinish(request: WebServerRequest) {
        NSLog(__FUNCTION__)
        self.connectionBag.remove(request)
    }
    
    func webServerRequest(request: WebServerRequest, didReceiveError error: NSError) {
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