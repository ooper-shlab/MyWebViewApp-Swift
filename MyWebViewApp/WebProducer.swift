//
//  WebProducer.swift
//  MyWebViewApp
//
//  Created by 開発 on 2015/8/23.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

class WebProducer {
    private(set) static var _producer: WebProducer = WebProducer()
    class var currentProducer: WebProducer {
        return _producer
    }
    
    func respondToRequest(request: WebServerRequest) {
        let receiver = request.receiver
        let requestPath = receiver.path!
        let requestPathURL = NSURL(string: requestPath)!
        if acterRespondes(request) {
            return
        }
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
    
    func acterRespondes(request: WebServerRequest) -> Bool {
        var pathComponents: [String] = NSURL(string: request.receiver.path!)!.pathComponents!
        pathComponents.removeFirst() // remove first "/"
        guard pathComponents.count >= 2 else {return false}
        let method = pathComponents.popLast()! + ":"
        print(method)
        let className = /*WebProducer.MyNamespace +*/ "$".join(pathComponents)
        print(className)
        print(NSStringFromClass(bbb.self))
        if let classObj = NSClassFromString(className) as? NSObject.Type
        where classObj.instancesRespondToSelector(Selector(method)) {
            let actor = classObj.init()
            actor.performSelector(Selector(method), withObject: request)
            return true
        }
        return false
    }
    
    static let MyNamespace: String = {
        let className = NSStringFromClass(WebProducer.self)
        if let range = className.rangeOfString(".") {
            return className.substringToIndex(range.endIndex)
        } else {
            return ""
        }
    }()
}