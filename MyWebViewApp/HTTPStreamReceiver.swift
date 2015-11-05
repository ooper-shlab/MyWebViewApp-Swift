//
//  HTTPStreamReceiver.swift
//  MyWebViewApp
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/22.
//  Copyright (c) 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

@objc protocol HTTPStreamReceiverDelegate {
    optional func receiverWillProcessBody(receiver: HTTPStreamReceiver)
    optional func receiverDidProcessBody(receiver: HTTPStreamReceiver)
    optional func receiver(receiver: HTTPStreamReceiver, errorDidOccur error: NSError)
}

private let BUFFER_SIZE = 1024
private let MAXIMUM_BODY_SIZE = 20 * 1024 * 1024

let kHTTPStreamReceiverErrorDomain = "kHTTPStreamReceiverErrorDomain"
let kHTTPStreamReceiverUnknownError = 1

class HTTPStreamReceiver: NSObject, NSStreamDelegate {
    
    let istream: NSInputStream
    weak var delegate: HTTPStreamReceiverDelegate?
    
    let headerData = NSMutableData(capacity: BUFFER_SIZE)!
    private(set) var headerFinished: Bool = false
    var headerProcessingStarted: Bool = false
    var headerProcessed: Bool = false
    private(set) var endOfHeader = 0
    
    let bodyData = NSMutableData()
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
    
    private var _query: HTTPValues? = nil
    var query: HTTPValues {
        if _query != nil {
            if let
                path = self.path,
                component = NSURLComponents(string: path),
                queryString = component.query
            {
                _query = HTTPValues(query: queryString)
            } else {
                _query = HTTPValues()
            }
        }
        return _query!
    }
    
    init(istream: NSInputStream) {
        self.istream = istream
        super.init()
        istream.delegate = self
    }
    
    deinit {
        self.istream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        self.istream.close()
    }
    
    func run() {
        NSLog(__FUNCTION__)
        istream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        istream.open()
        self.receive()
    }
    
    func stream(stream: NSStream, handleEvent eventCode: NSStreamEvent) {
        NSLog(__FUNCTION__)
        switch eventCode {
        case NSStreamEvent.HasBytesAvailable:
            if istream === self.istream {
                self.receive()
            }
        case NSStreamEvent.EndEncountered:
            if  stream == self.istream {
                endReceive()
                tryProcessHeader()
            }
        case NSStreamEvent.ErrorOccurred:
            let error = stream.streamError ?? NSError(domain: kHTTPStreamReceiverErrorDomain, code: kHTTPStreamReceiverUnknownError, userInfo: nil)
            NSLog("Error:\(error.description) in input stream")
            delegate?.receiver?(self, errorDidOccur: error)
        default:
            break
        }
    }
    
    
    func receive() {
        NSLog(__FUNCTION__)
        var buffer: [UInt8] = Array(count: BUFFER_SIZE, repeatedValue: 0)
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
        NSLog(__FUNCTION__)
        istream.close()
        bodyFinished = true
    }
    
    func appendHeader(bufferPtr: UnsafePointer<UInt8>, length: Int) {
        NSLog(__FUNCTION__)
        print("length=\(length)")
            headerData.appendBytes(bufferPtr, length: length)
        let emptyLine = headerData.rangeOfData(emptyLineData, options: [], range: NSRange(endOfHeader..<headerData.length))
        if emptyLine.location == NSNotFound {
            if headerData.hasSuffix(CR, LF, CR) {
                endOfHeader = headerData.length - 3
            } else if headerData.hasSuffix(CR, LF) {
                endOfHeader = headerData.length - 2
            } else if headerData.hasSuffix(CR) {
                endOfHeader = headerData.length - 1
            } else {
                endOfHeader = headerData.length
            }
        } else {
            endOfHeader = emptyLine.location
            headerFinished = true
        }
        if headerFinished {
            let startOfBody = NSRange(endOfHeader+4 ..< headerData.length)
            bodyData.appendData(headerData.subdataWithRange(startOfBody))
            headerData.length = endOfHeader+4
            tryProcessBody()
        }
    }
    func appendBody(bufferPtr: UnsafePointer<UInt8>, length readLength: Int) {
        NSLog(__FUNCTION__)
        let length = estimatedBodyLength
        
        let len = (bodyData.length + readLength <= length) ? readLength : length - bodyData.length
        bodyData.appendBytes(bufferPtr, length: len)
        tryProcessBody()
    }
    
    func tryProcessHeader() {
        NSLog(__FUNCTION__)
        if headerFinished && !headerProcessingStarted {
            processHeader()
        }
        tryProcessBody()
    }
    
    func processHeader() {
        NSLog(__FUNCTION__)
        headerProcessingStarted = true
        print(headerData.length)
        let requestHeader = NSString(data: headerData, encoding: NSISOLatin1StringEncoding)! as String
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
        NSLog(__FUNCTION__)
        if bodyData.length >= estimatedBodyLength {
            bodyFinished = true
        }
        if headerFinished && bodyFinished && !bodyProcessingStarted {
            processBody()
        }
        
    }
    
    func processBody() {
        NSLog(__FUNCTION__)
        delegate?.receiverWillProcessBody?(self)
        bodyProcessingStarted = true
        print(bodyData.length)
        //TODO:
        bodyProcessed = true
        delegate?.receiverDidProcessBody?(self)
    }
    
    func parseRequestHeader(requestHeader: String) {
        NSLog(__FUNCTION__)
        var lineNumber = 0
        let spaces = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        requestHeader.enumerateLines {line, stop in
            if lineNumber == 0 {
                let methods = line.componentsSeparatedByCharactersInSet(spaces)
                self.method = methods[opt: 0]
                self.path = methods[opt: 1]
                self.httpVersion = methods[opt: 2]
                NSLog("methods=%@", methods)
            } else {
                if let index = line.rangeOfString(":") {
                    let name = line.substringToIndex(index.startIndex)
                    let value = line.substringFromIndex(index.endIndex).stringByTrimmingCharactersInSet(spaces)
                    self.headers.append(value, forName: name)
                }
            }
            ++lineNumber
        }
    }
}