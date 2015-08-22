//
//  WebServer.swift
//  MyWebView
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/22.
//
//

import UIKit

let kWebServiceType = "_http._tcp"
let kWebServiceDomain = "local."
let kWebServiceName = UIDevice.currentDevice().name

let WebServerErrorDomain = "WebServerErrorDomain"
let kWebServerCouldNotBindToIPv4Address = 1
let kWebServerCouldNotBindToIPv6Address = 2
let kWebServerNoSocketsAvailable = 3
let kWebServerCouldNotBindOrEstablishNetService = 4

@objc
class WebServer: NSObject, WebServerRequestDelegate, NSNetServiceDelegate {
    var connectionBag: Set<WebServerRequest> = []
    var netService: NSNetService?

    override init() {
        super.init()
        do {
            try self.setupServer()
        } catch let thisError as NSError {
            fatalError(thisError.localizedDescription)
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        self.teardown()
    }
    
    func netServiceDidPublish(sender: NSNetService) {
        NSLog(__FUNCTION__)
        self.netService = sender
    }
    func netService(sender: NSNetService, didNotPublish errorDict: [String: NSNumber]) {
        NSLog(__FUNCTION__)
        fatalError(errorDict.description)
    }
    
    func netService(sender: NSNetService, didAcceptConnectionWithInputStream readStream: NSInputStream, outputStream writeStream: NSOutputStream) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue)
            CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue)
            self.handleConnection(inputStream: readStream, outputStream: writeStream)
        }
    }
    
    func setupServer() throws {
        
        if self.netService != nil {
            // Calling [self run] more than once should be a NOP.
            return
        } else {
            
            if self.netService == nil {
                self.netService = NSNetService(domain: kWebServiceDomain, type: kWebServiceType, name: kWebServiceName, port: 0)
                self.netService?.delegate = self
            }
            
            if self.netService == nil {
                self.teardown()
                throw NSError(domain: WebServerErrorDomain, code: kWebServerCouldNotBindOrEstablishNetService, userInfo: nil)
            }
        }
    }
    
    func run() {
        do {
            try self.setupServer()
        } catch let thisError as NSError {
            fatalError(thisError.localizedDescription)
        }
        
        self.netService!.publishWithOptions(.ListenForConnections)
    }
    
    func handleConnection(inputStream readStream: NSInputStream, outputStream writeStream: NSOutputStream) {
        NSLog(__FUNCTION__)
        
        let newPeer = WebServerRequest(inputStream: readStream,
            outputStream: writeStream,
            delegate: self)
        
        self.connectionBag.insert(newPeer)
            
    }
    
    func webServerRequestDidFinish(request: WebServerRequest) {
        self.connectionBag.remove(request)
    }
    
    func webServerRequestDidReceiveError(request: WebServerRequest) {
        self.connectionBag.remove(request)
    }
    
    func webWerverRequestDidProcessBody(request: WebServerRequest) {
        //
        let receiver = request.receiver
        let requestPath = receiver.path!
        let requestPathURL = NSURL(string: requestPath)!
        let path = requestPathURL.path!
        let resourceURL = NSBundle.mainBundle().resourceURL!
        let documentURL = resourceURL.URLByAppendingPathComponent(path)
        var foundURL: NSURL? = nil
        let fileManager = NSFileManager.defaultManager()
        var isDir: ObjCBool = false
        if fileManager.fileExistsAtPath(documentURL.path!, isDirectory: &isDir) {
            if isDir {
                NSLog(documentURL.path!)
                for defPage in DEFAULTS {
                    let url = documentURL.URLByAppendingPathComponent(defPage)
                    if fileManager.fileExistsAtPath(url.path!) {
                        foundURL = url
                        break
                    }
                }
            } else {
                foundURL = documentURL
            }
        }
        NSLog(documentURL.path!)
        let transmitter = request.transmitter
        if let url = foundURL {
            let data = NSData(contentsOfURL: url)!
            let ext = url.pathExtension ?? ""
            if let contentType = TYPES[ext] {
                transmitter.headers["Content-Type"] = contentType
            } else {
                transmitter.headers["Content-Type"] = UNKNOWN_TYPE
            }
            transmitter.addResponse(data)
        } else {
            transmitter.headers["Content-Type"] = "text/html"
            let responseHtml = "\(HTTPStatus.NotFound.fullDescription)<br>" +
                "Requested resource \(path.HTMLEntitiesEncoded) does not exist on this server."
            transmitter.addResponse(responseHtml)
        }
        transmitter.startTransmission()
    }
    
    func teardown() {
        if self.netService != nil {
            self.netService!.stop()
            self.netService = nil
        }
    }
    
    deinit {
        self.teardown()
    }
    
}