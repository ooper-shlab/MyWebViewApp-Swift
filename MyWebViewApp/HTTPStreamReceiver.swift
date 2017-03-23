//
//  HTTPStreamReceiver.swift
//  MyWebViewApp
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/22.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import Foundation

@objc protocol HTTPStreamReceiverDelegate {
    @objc optional func receiverWillProcessBody(_ receiver: HTTPStreamReceiver)
    @objc optional func receiverDidProcessBody(_ receiver: HTTPStreamReceiver)
    @objc optional func receiver(_ receiver: HTTPStreamReceiver, errorDidOccur error: Error)
}

private let BUFFER_SIZE = 1024
private let MAXIMUM_BODY_SIZE = 20 * 1024 * 1024

let kHTTPStreamReceiverErrorDomain = "kHTTPStreamReceiverErrorDomain"
let kHTTPStreamReceiverUnknownError = 1

class HTTPStreamReceiver: NSObject, StreamDelegate {
    
    let istream: InputStream
    weak var delegate: HTTPStreamReceiverDelegate?
    
    var headerData = Data(capacity: BUFFER_SIZE)
    private(set) var headerFinished: Bool = false
    var headerProcessingStarted: Bool = false
    var headerProcessed: Bool = false
    private(set) var endOfHeader = 0
    
    var bodyData = Data()
    var bodyProcessingStarted: Bool = false
    var bodyProcessed: Bool = false
    private(set) var bodyFinished: Bool = false
    var estimatedBodyLength: Int = MAXIMUM_BODY_SIZE {
        didSet {
            tryProcessBody()
        }
    }
    
    var headers: HTTPValues = HTTPValues()
    var method: String?
    var path: String?
    var httpVersion: String?
    
    //Moved to `HTTPRequest`.
//    private var _query: HTTPValues? = nil
//    var query: HTTPValues {
//        if _query != nil {
//            if let
//                path = self.path,
//                let component = URLComponents(string: path),
//                let queryString = component.query
//            {
//                _query = HTTPValues(query: queryString)
//            } else {
//                _query = HTTPValues()
//            }
//        }
//        return _query!
//    }
    
    init(istream: InputStream) {
        self.istream = istream
        super.init()
        istream.delegate = self
    }
    
    deinit {
        self.istream.remove(from: RunLoop.current, forMode: RunLoopMode.commonModes)
        self.istream.close()
    }
    
    func run() {
        NSLog(#function)
        istream.schedule(in: RunLoop.current, forMode: RunLoopMode.commonModes)
        istream.open()
        self.receive()
    }
    
    func stream(_ stream: Stream, handle eventCode: Stream.Event) {
        NSLog(#function)
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            if istream === self.istream {
                self.receive()
            }
        case Stream.Event.endEncountered:
            if  stream == self.istream {
                endReceive()
                tryProcessHeader()
            }
        case Stream.Event.errorOccurred:
            let error = stream.streamError ?? NSError(domain: kHTTPStreamReceiverErrorDomain, code: kHTTPStreamReceiverUnknownError, userInfo: nil)
            NSLog("Error:\(error) in input stream")
            delegate?.receiver?(self, errorDidOccur: error)
        default:
            break
        }
    }
    
    
    func receive() {
        NSLog(#function)
        var buffer: [UInt8] = Array(repeating: 0, count: BUFFER_SIZE)
        while istream.hasBytesAvailable && !bodyFinished {
            let len = self.istream.read(&buffer, maxLength: BUFFER_SIZE)
            if headerFinished {
                appendBody(buffer, length: len)
            } else {
                appendHeader(buffer, length: len)
            }
            tryProcessHeader()
        }
        if bodyFinished {
            istream.close()
        }
    }
    
    func endReceive() {
        NSLog(#function)
        istream.close()
        bodyFinished = true
    }
    
    func appendHeader(_ bufferPtr: UnsafePointer<UInt8>, length: Int) {
        NSLog(#function)
        print("length=\(length)")
            headerData.append(bufferPtr, count: length)
        if let emptyLine = headerData.range(of: emptyLineData, options: [], in: endOfHeader..<headerData.count) {
            endOfHeader = emptyLine.lowerBound
            headerFinished = true
        } else {
            if headerData.hasSuffix(CR, LF, CR) {
                endOfHeader = headerData.count - 3
            } else if headerData.hasSuffix(CR, LF) {
                endOfHeader = headerData.count - 2
            } else if headerData.hasSuffix(CR) {
                endOfHeader = headerData.count - 1
            } else {
                endOfHeader = headerData.count
            }
        }
        if headerFinished {
            let startOfBody: Range<Int> = endOfHeader+4 ..< headerData.count
            bodyData.append(headerData.subdata(in: startOfBody))
            headerData.count = endOfHeader+4
            tryProcessBody()
        }
    }
    func appendBody(_ bufferPtr: UnsafePointer<UInt8>, length readLength: Int) {
        NSLog(#function)
        let length = estimatedBodyLength
        
        let len = (bodyData.count + readLength <= length) ? readLength : length - bodyData.count
        bodyData.append(bufferPtr, count: len)
        tryProcessBody()
    }
    
    func tryProcessHeader() {
        NSLog(#function)
        if headerFinished && !headerProcessingStarted {
            processHeader()
        }
        tryProcessBody()
    }
    
    func processHeader() {
        NSLog(#function)
        headerProcessingStarted = true
        print(headerData.count)
        let requestHeader = String(data: headerData, encoding: .isoLatin1)!
        parseRequestHeader(requestHeader)
        print("headers:\r\n\(headers)")
        headerProcessed = true
        if let contentLength = headers["content-length"].flatMap({Int($0)}) {
            print("content-length: \(contentLength)")
            self.estimatedBodyLength = contentLength
        } else if method == "GET" {
            self.estimatedBodyLength = 0
        }
    }
    
    func tryProcessBody() {
        NSLog(#function)
        if bodyData.count >= estimatedBodyLength {
            bodyFinished = true
        }
        if headerFinished && bodyFinished && !bodyProcessingStarted {
            processBody()
        }
        
    }
    
    func processBody() {
        NSLog(#function)
        delegate?.receiverWillProcessBody?(self)
        bodyProcessingStarted = true
        print(bodyData.count)
        //TODO:
        bodyProcessed = true
        delegate?.receiverDidProcessBody?(self)
    }
    
    func parseRequestHeader(_ requestHeader: String) {
        NSLog(#function)
        var lineNumber = 0
        let spaces = CharacterSet.whitespacesAndNewlines
        requestHeader.enumerateLines {line, stop in
            if lineNumber == 0 {
                let methods = line.components(separatedBy: spaces)
                self.method = methods[opt: 0]
                self.path = methods[opt: 1]
                self.httpVersion = methods[opt: 2]
                NSLog("methods=%@", methods)
            } else {
                if let index = line.range(of: ":") {
                    let name = line.substring(to: index.lowerBound)
                    let value = line.substring(from: index.upperBound).trimmingCharacters(in: spaces)
                    self.headers.append(value, for: name)
                }
            }
            lineNumber += 1
        }
    }
}
