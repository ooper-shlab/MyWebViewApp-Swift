//
//  WebServerRequest.swift
//  MyWebView
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/22.
//
//
import UIKit

@objc
protocol WebServerRequestDelegate {
    optional func webServerRequestDidProcessBody(request: WebServerRequest)
    optional func webServerRequestDidFinish(request: WebServerRequest)
    optional func webServerRequest(request: WebServerRequest, didReceiveError error: NSError)
}

let WebServerRequestErrorDomain = "WebServerRequestErrorDomain"
let kWebServerRequestReceivedTransmissionError = 1

@objc
class WebServerRequest: NSObject, HTTPStreamReceiverDelegate, HTTPStreamTransmitterDelegate {
    
    var receiver: HTTPStreamReceiver
    var transmitter: HTTPStreamTransmitter
    weak var delegate: WebServerRequestDelegate?
    
    init(inputStream readStream: NSInputStream,
        outputStream writeStream: NSOutputStream,
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
    
    func receiverWillProcessBody(receiver: HTTPStreamReceiver) {
        NSLog(__FUNCTION__)
        //
    }
    
    func receiverDidProcessBody(receiver: HTTPStreamReceiver) {
        NSLog(__FUNCTION__)
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.webServerRequestDidProcessBody?(self)
        }
    }
    
    func receiver(receiver: HTTPStreamReceiver, errorDidOccur error: NSError) {
        NSLog(__FUNCTION__)
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.webServerRequest?(self, didReceiveError: error)
        }
    }
    
    func transmitterDidFinishTransmission(transmitter: HTTPStreamTransmitter) {
        NSLog(__FUNCTION__)
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.webServerRequestDidFinish?(self)
        }
    }
    
    func transmitter(transmitter: HTTPStreamTransmitter, errorDidOccur error: NSError) {
        NSLog(__FUNCTION__)
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.webServerRequest?(self, didReceiveError: error)
        }
    }
}