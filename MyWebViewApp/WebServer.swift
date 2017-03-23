//
//  WebServer.swift
//  MyWebViewApp
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/22.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import UIKit

let WebServerErrorDomain = "WebServerErrorDomain"
let kWebServerCouldNotBindToIPv4Address = 1
let kWebServerCouldNotBindToIPv6Address = 2
let kWebServerNoSocketsAvailable = 3
let kWebServerCouldNotBindOrEstablishNetService = 4
//
let kWebServerDidNotPublish = 5

@objc
class WebServer: NSObject, WebServerRequestDelegate {
    var connectionBag: Set<WebServerRequest> = []
    var listenerSocket: OOPSocket?
    
    private(set) var listeningPort: in_port_t = 0

    override init() {
        super.init()
        do {
            try self.setupServer()
        } catch let thisError {
            fatalError(thisError.localizedDescription)
        }
    }
    
    func setupServer() throws {
        
        if self.listenerSocket != nil {
            // Calling [self run] more than once should be a NOP.
            return
        }
        self.listenerSocket = OOPSocket(forListening: .inet, .tcp) {s, addr, inputStream, outputStream in
            OperationQueue.main.addOperation {
                self.handleConnection(inputStream: inputStream, outputStream: outputStream)
            }
        }
        try self.listenerSocket!.listen(.init("127.0.0.1", 0))
        let localAddress = self.listenerSocket!.socketAddress!
        print(localAddress.port)
        self.listeningPort = localAddress.port
    }
    
    func run() {
        do {
            try self.setupServer()
        } catch let thisError {
            fatalError(thisError.localizedDescription)
        }
    }
    
    func handleConnection(inputStream readStream: InputStream, outputStream writeStream: OutputStream) {
        NSLog(#function)
        
        let newPeer = WebServerRequest(inputStream: readStream,
            outputStream: writeStream,
            delegate: self)
        
        self.connectionBag.insert(newPeer)
            
    }
    
    func webServerRequestDidProcessBody(_ serverRequest: WebServerRequest) {
        NSLog(#function)
        let producer = WebProducer.currentProducer
        producer.produce(serverRequest)
    }
    
    func webServerRequestDidFinish(_ serverRequest: WebServerRequest) {
        NSLog(#function)
        self.connectionBag.remove(serverRequest)
    }
    
    func webServerRequest(_ serverRequest: WebServerRequest, didReceiveError error: Error) {
        NSLog(error.localizedDescription)
        self.connectionBag.remove(serverRequest)
    }
    
    func teardown() {
        self.listenerSocket?.invalidate()
        self.listenerSocket = nil
        self.listeningPort = 0
    }
    
    deinit {
        self.teardown()
    }
    
}
