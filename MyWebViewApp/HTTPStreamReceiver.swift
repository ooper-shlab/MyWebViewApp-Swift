//
//  HTTPStreamReceiver.swift
//  MyWebViewApp
//  (See HTTPReceiver.swift in SwiftWebServer.)
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/4/26.
//  Copyright (c) 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

extension NSData {
    func hasSuffix(bytes: UInt8...) -> Bool {
        if self.length < bytes.count { return false }
        let ptr = UnsafePointer<UInt8>(self.bytes)
        for (i, byte) in bytes.enumerate() {
            if ptr[self.length - bytes.count + i] != byte {
                return false
            }
        }
        return true
    }
}
let CR = UInt8(ascii: "\r")
let LF = UInt8(ascii: "\n")
private let BUFFER_SIZE = 1024
let emptyLineData = NSData(bytes: [CR, LF, CR, LF], length: 4)
private let MAXIMUM_BODY_SIZE = 65536
class HTTPStreamReceiver {
    
    private(set) var secure: Bool = false
    
    let istream: NSInputStream
    let headerData = NSMutableData(capacity: BUFFER_SIZE)!
    private(set) var endOfHeader = 0
    let bodyData = NSMutableData()
    
    init(istream: NSInputStream) {
        self.istream = istream
        self.receive()
    }
    
    private(set) var headerFinished: Bool = false
    private(set) var bodyFinished: Bool = false
    var estimatedBodyLength: Int = MAXIMUM_BODY_SIZE {
        didSet {
            if bodyData.length >= estimatedBodyLength {
                bodyFinished = true
            }
        }
    }
    
    func receive() {
        var buffer: [UInt8] = Array(count: BUFFER_SIZE, repeatedValue: 0)
        while istream.hasBytesAvailable && !bodyFinished {
            let len = self.istream.read(&buffer, maxLength: BUFFER_SIZE)
            if headerFinished {
                appendBody(buffer, length: len)
            } else {
                appendHeader(buffer, length: len)
            }
        }
        if bodyFinished {
            istream.close()
        }
    }
    
    func endReceive() {
        istream.close()
        bodyFinished = true
    }
    
    func appendHeader(bufferPtr: UnsafePointer<UInt8>, length: Int) {
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
        }
    }
    func appendBody(bufferPtr: UnsafePointer<UInt8>, length readLength: Int) {
        let length = estimatedBodyLength
        
        let len = (bodyData.length + readLength <= length) ? readLength : length - bodyData.length
        bodyData.appendBytes(bufferPtr, length: len)
        if bodyData.length >= length {
            bodyFinished = true
        }
    }
}