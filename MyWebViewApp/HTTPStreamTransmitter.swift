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
        fatalError("ResponseProvider is an abstract class: implement \(#function) in the subclass.")
    }
    var availableBytes: Int {
        fatalError("ResponseProvider is an abstract class: implement \(#function) in the subclass.")
    }
    var finished: Bool {
        fatalError("ResponseProvider is an abstract class: implement \(#function) in the subclass.")
    }
    func sendResponse(_ ostream: OutputStream, length: Int) -> Int {
        fatalError("ResponseProvider is an abstract class: implement \(#function) in the subclass.")
    }
    @discardableResult func sendResponse(_ ostream: OutputStream) -> Int {
        return sendResponse(ostream, length: self.availableBytes)
    }
}

class DataResponseProvider: ResponseProvider {
    fileprivate var data: Data
    fileprivate var offset: Int
    init(data: Data) {
        self.data = data
        self.offset = 0
    }
    init(string: String) {
        self.data = (string as NSString).data(using: String.Encoding.utf8.rawValue)!
        self.offset = 0
    }
    override var length: Int {
        return data.count
    }
    override var availableBytes: Int {
        return data.count - offset
    }
    override var finished: Bool {
        return offset >= data.count
    }
    override func sendResponse(_ ostream: OutputStream, length: Int) -> Int {
        let lenSent = ostream.write((data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count) + offset, maxLength: length)
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
    @objc optional func transmitterDidFinishTransmission(_ transmitter: HTTPStreamTransmitter)
    @objc optional func transmitter(_ transmitter: HTTPStreamTransmitter, errorDidOccur error: NSError)
}

let kHTTPStreamTransmitterErrorDomain = "kHTTPStreamTransmitterErrorDomain"
let kHTTPStreamTransmitterUnknownError = 1

class HTTPStreamTransmitter: NSObject, StreamDelegate {
    fileprivate let ostream: OutputStream
    
    weak var delegate: HTTPStreamTransmitterDelegate?
    var transmissionStarted: Bool = false
    var transmissionDidFinishNotified = false
    var headers: HTTPValues = HTTPValues(caseInsensitive: true)
    
    fileprivate var responses: [ResponseProvider] = []
    
    fileprivate var headerGenerated: Bool = false
    var status: HTTPStatus = .ok
    var httpVersion: String = "HTTP/1.1"
    
    init(ostream: OutputStream) {
        self.ostream = ostream
        super.init()
        self.ostream.delegate = self
    }
    func run() {
        self.ostream.schedule(in: RunLoop.current, forMode: RunLoopMode.commonModes)
        self.ostream.open()
    }
    deinit {
        self.ostream.remove(from: RunLoop.current, forMode: RunLoopMode.commonModes)
        self.ostream.close()
    }
    
    func sendResponse() {
        let response = DataResponseProvider(string: "\r\nBonjour, le monde!")
        self.addResponse(response)
        self.startTransmission()
    }

    @nonobjc func addResponse(_ string: String) {
        let response = DataResponseProvider(string: string)
        self.addResponse(response)
    }
    @nonobjc func addResponse(_ data: Data) {
        let response = DataResponseProvider(data: data)
        self.addResponse(response)
    }
    
    @nonobjc func addResponse(_ response: ResponseProvider) {
        self.responses.append(response)
    }
    
    func startTransmission() {
        NSLog(#function)
        self.addHeaderResponse()
        self.transmissionStarted = true
        self.transmit()
    }
    
    func addHeaderResponse() {
        NSLog(#function)
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
        let response = DataResponseProvider(data: data as Data)
        responses.insert(response, at: 0)
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        NSLog(#function)
        switch eventCode {
        case Stream.Event.hasSpaceAvailable:
            if aStream === self.ostream {
                transmit()
            }
        case Stream.Event.endEncountered:
            if aStream === self.ostream {
                NSLog("Output stream closed unexpectedly")
            }
        case Stream.Event.errorOccurred:
            let error = aStream.streamError ?? NSError(domain: kHTTPStreamTransmitterErrorDomain, code: kHTTPStreamTransmitterUnknownError, userInfo: nil)
            NSLog("Error:\(error) in output stream")
            delegate?.transmitter?(self, errorDidOccur: error as NSError)
        default:
            break
        }
    }
    
    func transmit() {
        NSLog(#function)
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
