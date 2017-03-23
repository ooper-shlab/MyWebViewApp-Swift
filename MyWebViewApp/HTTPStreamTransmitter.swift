//
//  HTTPStreamTransmitter.swift
//  MyWebViewApp
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/20.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import Foundation

public protocol ResponseProvider {
    var length: Int {get}
    var availableBytes: Int {get}
    var finished: Bool {get}
    func sendResponse(_ ostream: OutputStream, length: Int) -> Int
}

public extension ResponseProvider {
    @discardableResult func sendResponse(_ ostream: OutputStream) -> Int {
        return sendResponse(ostream, length: self.availableBytes)
    }
}

class DataResponseProvider: ResponseProvider {
    private var data: Data
    private var offset: Int
    init(data: Data) {
        self.data = data
        self.offset = 0
    }
    init(string: String) {
        self.data = string.data(using: .utf8)!
        self.offset = 0
    }
    var length: Int {
        return data.count
    }
    var availableBytes: Int {
        return data.count - offset
    }
    var finished: Bool {
        return offset >= data.count
    }
    func sendResponse(_ ostream: OutputStream, length: Int) -> Int {
        var length = length
        if offset + length > data.count {
            length = data.count - offset
        }
        let lenSent = data.withUnsafeBytes {bytes in
            ostream.write(bytes + offset, maxLength: length)
        }
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
    @objc optional func transmitter(_ transmitter: HTTPStreamTransmitter, errorDidOccur error: Error)
}

let kHTTPStreamTransmitterErrorDomain = "kHTTPStreamTransmitterErrorDomain"
let kHTTPStreamTransmitterUnknownError = 1

class HTTPStreamTransmitter: NSObject, StreamDelegate {
    var headers: HTTPValues = HTTPValues(caseInsensitive: true)
    
    private var headerGenerated: Bool = false
    var status: HTTPStatus = .ok
    var httpVersion: String = "HTTP/1.1"
    
    private let ostream: OutputStream
    
    weak var delegate: HTTPStreamTransmitterDelegate?
    private var transmissionStarted: Bool = false
    private var transmissionDidFinishNotified = false
    private var headerSent = false
    
    internal var responseHeader: ResponseProvider?
    internal var responses: [ResponseProvider] = []
    
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
        if transmissionStarted {
            return
        }
        self.transmissionStarted = true
        addHeaderResponse()
        self.transmit()
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
            delegate?.transmitter?(self, errorDidOccur: error)
        default:
            break
        }
    }
    
    func transmit() {
        NSLog(#function)
        if transmissionStarted {
            while let response = responseHeader, !response.finished && ostream.hasSpaceAvailable {
                response.sendResponse(ostream)
            }
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
    
    func addHeaderResponse() {
        if headerGenerated {
            return
        }
        NSLog(#function)
        let contentLength = responses.reduce(0, {$0 + $1.length})
        var data = Data()
        let statusLine = "\(httpVersion) \(status.fullDescription)\r\n"
        data.append(statusLine)
        if headers["Content-Length"] == nil {
            let length = contentLength
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
        responseHeader = response
        headerGenerated = true
    }
}
