//
//  WebServerRequest.swift
//  WebWeb
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/1.
//
//
import UIKit

@objc
protocol WebServerRequestDelegate {
    func WebServerRequestDidFinish(request: WebServerRequest)
    func WebServerRequestDidReceiveError(request: WebServerRequest)
}

@objc
class WebServerRequest: NSObject, NSStreamDelegate {
    
    var istr: NSInputStream
    var ostr: NSOutputStream
    var peerName: String
    weak var delegate: WebServerRequestDelegate?
    
    init(inputStream readStream: NSInputStream,
        outputStream writeStream: NSOutputStream,
        peer peerAddress: String,
        delegate anObject: WebServerRequestDelegate)
    {
        self.istr = readStream
        self.ostr = writeStream
        self.peerName = peerAddress
        self.delegate = anObject
    }
    
    func runProtocol() {
        
        self.istr.delegate = self
        self.istr.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        self.istr.open()
        self.ostr.delegate = self
        self.ostr.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        self.ostr.open()
    }
    
    var receiver: HTTPStreamReceiver? = nil
    var headerProcessed: Bool = false
    var bodyProcessed: Bool = false
    
    func stream(stream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
        case NSStreamEvent.HasSpaceAvailable:
            if stream === self.ostr {
//                if (stream as! NSOutputStream).hasSpaceAvailable {
//                    // Send a simple no header response
//                    self.sendResponse()
//                }
            }
        case NSStreamEvent.HasBytesAvailable:
            if let istream = stream as? NSInputStream
            where istream === self.istr {
                if let receiver = self.receiver {
                    receiver.receive()
                } else {
                    self.receiver = HTTPStreamReceiver(istream: istream)
                }
                if self.receiver!.headerFinished && !headerProcessed {
                    self.processHeader(self.receiver!.headerData)
                    headerProcessed = true
                }
                if self.receiver!.bodyFinished && !bodyProcessed {
                    self.processBody(self.receiver!.bodyData)
                    bodyProcessed = true
                }
            } else if stream == self.ostr {
                NSLog("Output stream closed unexpectedly")
            }
        case NSStreamEvent.EndEncountered:
            if let receiver = self.receiver
            where stream == self.istr {
                receiver.endReceive()
                if receiver.headerFinished {
                    if !headerProcessed {
                        self.processHeader(self.receiver!.headerData)
                        headerProcessed = true
                    }
                    if !bodyProcessed {
                        self.processBody(self.receiver!.bodyData)
                        bodyProcessed = true
                    }
                }
            }
        case NSStreamEvent.ErrorOccurred:
            NSLog("stream: %@", stream)
            delegate?.WebServerRequestDidReceiveError(self)
        default:
            break
        }
    }
    
    func processHeader(headerData: NSData) {
        print(headerData.length)
        let requestHeader = NSString(data: headerData, encoding: NSISOLatin1StringEncoding)! as String
        parseRequestHeader(requestHeader)
        print("headers:\r\n\(headers)")
        if let contentLength = headers["content-length"].flatMap({Int($0)}) {
            print("content-length: \(contentLength)")
            self.receiver!.estimatedBodyLength = contentLength
        } else if method == "GET" {
            self.receiver!.estimatedBodyLength = 0
        }
    }
    
    func processBody(bodyData: NSData) {
        print(bodyData.length)
        sendResponse()
    }
    
    func sendResponse() {
        let response = ("\r\nBonjour, le monde!" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
        self.ostr.write(UnsafePointer(response.bytes), maxLength: response.length)
        self.ostr.close()
    }
    
    deinit {
        istr.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        
        ostr.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        
        
    }
    
    var headers: HTTPValues = HTTPValues()
    var method: String?
    var path: String?
    var httpVersion: String?
    func parseRequestHeader(requestHeader: String) {
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