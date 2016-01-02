//
//  HTTPStreamTransmitter.swift
//  MyWebViewApp
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/20.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import Foundation

class ResponseProvider {
    var length: Int {
        fatalError("ResponseProvider is an abstract class: implement \(__FUNCTION__) in the subclass.")
    }
    var availableBytes: Int {
        fatalError("ResponseProvider is an abstract class: implement \(__FUNCTION__) in the subclass.")
    }
    var finished: Bool {
        fatalError("ResponseProvider is an abstract class: implement \(__FUNCTION__) in the subclass.")
    }
    func sendResponse(ostream: NSOutputStream, length: Int) -> Int {
        fatalError("ResponseProvider is an abstract class: implement \(__FUNCTION__) in the subclass.")
    }
    func sendResponse(ostream: NSOutputStream) -> Int {
        return sendResponse(ostream, length: self.availableBytes)
    }
}

class DataResponseProvider: ResponseProvider {
    private var data: NSData
    private var offset: Int
    init(data: NSData) {
        self.data = data
        self.offset = 0
    }
    init(string: String) {
        self.data = (string as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
        self.offset = 0
    }
    override var length: Int {
        return data.length
    }
    override var availableBytes: Int {
        return data.length - offset
    }
    override var finished: Bool {
        return offset >= data.length
    }
    override func sendResponse(ostream: NSOutputStream, length: Int) -> Int {
        let lenSent = ostream.write(UnsafePointer(data.bytes) + offset, maxLength: length)
        offset += lenSent
        return lenSent
    }

}

//class FileResponseProvider: ResponseProvider {
//    private var fileURL: NSURL
//    private var offset: Int
//    init(fileURL: NSURL) {
//        self.fileURL = fileURL
//        self.offset = 0
//    }
//}

@objc protocol HTTPStreamTransmitterDelegate {
    optional func transmitterDidFinishTransmission(transmitter: HTTPStreamTransmitter)
    optional func transmitter(transmitter: HTTPStreamTransmitter, errorDidOccur error: NSError)
}

let kHTTPStreamTransmitterErrorDomain = "kHTTPStreamTransmitterErrorDomain"
let kHTTPStreamTransmitterUnknownError = 1

class HTTPStreamTransmitter: NSObject, NSStreamDelegate {
    private let ostream: NSOutputStream
    
    weak var delegate: HTTPStreamTransmitterDelegate?
    var transmissionStarted: Bool = false
    var transmissionDidFinishNotified = false
    var headers: HTTPValues = HTTPValues(caseInsensitive: true)
    
    private var responses: [ResponseProvider] = []
    
    private var headerGenerated: Bool = false
    var status: HTTPStatus = .OK
    var httpVersion: String = "HTTP/1.1"
    
    init(ostream: NSOutputStream) {
        self.ostream = ostream
        super.init()
        self.ostream.delegate = self
    }
    func run() {
        self.ostream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        self.ostream.open()
    }
    deinit {
        self.ostream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        self.ostream.close()
    }
    
    func sendResponse() {
        let response = DataResponseProvider(string: "\r\nBonjour, le monde!")
        self.addResponse(response)
        self.startTransmission()
    }

    @nonobjc func addResponse(string: String) {
        let response = DataResponseProvider(string: string)
        self.addResponse(response)
    }
    @nonobjc func addResponse(data: NSData) {
        let response = DataResponseProvider(data: data)
        self.addResponse(response)
    }
    
    @nonobjc func addResponse(response: ResponseProvider) {
        self.responses.append(response)
    }
    
    func startTransmission() {
        NSLog(__FUNCTION__)
        self.addHeaderResponse()
        self.transmissionStarted = true
        self.transmit()
    }
    
    func addHeaderResponse() {
        NSLog(__FUNCTION__)
        let data = NSMutableData()
        let statusLine = "\(httpVersion) \(status.fullDescription)\r\n"
        data.append(statusLine)
        if headers["Content-Length"] == nil {
            var length: Int = 0
            for response in responses {
                length += response.length
            }
            headers["Content-Length"] = String(length)
        }
        for header in headers {
            if let value = header.value {
                data.append("\(header.name): \(value)\r\n")
            } else {
                data.append("\(header.name): \r\n")
            }
        }
        data.append("\r\n")
        let response = DataResponseProvider(data: data)
        responses.insert(response, atIndex: 0)
    }
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        NSLog(__FUNCTION__)
        switch eventCode {
        case NSStreamEvent.HasSpaceAvailable:
            if aStream === self.ostream {
                transmit()
            }
        case NSStreamEvent.EndEncountered:
            if aStream === self.ostream {
                NSLog("Output stream closed unexpectedly")
            }
        case NSStreamEvent.ErrorOccurred:
            let error = aStream.streamError ?? NSError(domain: kHTTPStreamTransmitterErrorDomain, code: kHTTPStreamTransmitterUnknownError, userInfo: nil)
            NSLog("Error:\(error.description) in output stream")
            delegate?.transmitter?(self, errorDidOccur: error)
        default:
            break
        }
    }
    
    func transmit() {
        NSLog(__FUNCTION__)
        if transmissionStarted {
            while !responses.isEmpty && ostream.hasSpaceAvailable {
                let response = responses.first!
                response.sendResponse(ostream)
                if response.finished {
                    responses.removeFirst()
                }
            }
            if !transmissionDidFinishNotified {
                transmissionDidFinishNotified = true
                delegate?.transmitterDidFinishTransmission?(self)
            }
        }
    }
}