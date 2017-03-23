//
//  WebServerRequest.swift
//  MyWebViewApp
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/22.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//
import UIKit

@objc
protocol WebServerRequestDelegate {
    @objc optional func webServerRequestDidProcessBody(_ request: WebServerRequest)
    @objc optional func webServerRequestDidFinish(_ request: WebServerRequest)
    @objc optional func webServerRequest(_ request: WebServerRequest, didReceiveError error: Error)
}

let WebServerRequestErrorDomain = "WebServerRequestErrorDomain"
let kWebServerRequestReceivedTransmissionError = 1

@objc
public class WebServerRequest: NSObject, HTTPStreamReceiverDelegate, HTTPStreamTransmitterDelegate {
    
    var receiver: HTTPStreamReceiver
    var transmitter: HTTPStreamTransmitter
    weak var delegate: WebServerRequestDelegate?
    
    //Moved to `HTTPRequest`.
//    var userInfo: [String: AnyObject] = [:]
    
    init(inputStream readStream: InputStream,
        outputStream writeStream: OutputStream,
        delegate anObject: WebServerRequestDelegate)
    {
        self.receiver = HTTPStreamReceiver(istream: readStream)
        self.transmitter = HTTPStreamTransmitter(ostream: writeStream)
        self.delegate = anObject
        super.init()
        self.receiver.delegate = self
        self.receiver.run()
        self.transmitter.delegate = self
        self.transmitter.run()
    }
    
    func receiverWillProcessBody(_ receiver: HTTPStreamReceiver) {
        NSLog(#function)
        //
    }
    
    func receiverDidProcessBody(_ receiver: HTTPStreamReceiver) {
        NSLog(#function)
        DispatchQueue.main.async {
            self.delegate?.webServerRequestDidProcessBody?(self)
        }
    }
    
    func receiver(_ receiver: HTTPStreamReceiver, errorDidOccur error: Error) {
        NSLog(#function)
        DispatchQueue.main.async {
            self.delegate?.webServerRequest?(self, didReceiveError: error)
        }
    }
    
    func transmitterDidFinishTransmission(_ transmitter: HTTPStreamTransmitter) {
        NSLog(#function)
        DispatchQueue.main.async {
            self.delegate?.webServerRequestDidFinish?(self)
        }
    }
    
    func transmitter(_ transmitter: HTTPStreamTransmitter, errorDidOccur error: Error) {
        NSLog(#function)
        DispatchQueue.main.async {
            self.delegate?.webServerRequest?(self, didReceiveError: error)
        }
    }
}
