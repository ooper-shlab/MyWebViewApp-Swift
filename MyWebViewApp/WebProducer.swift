//
//  WebProducer.swift
//  MyWebViewApp
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/23.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import Foundation

let ACTER_PREFIX = "__$"
class WebProducer {
    private(set) static var _producer: WebProducer = WebProducer()
    class var currentProducer: WebProducer {
        return _producer
    }
    
    func respondToRequest(_ request: WebServerRequest) {
        let receiver = request.receiver
        let requestPath = receiver.path!
        let requestPathURL = URL(string: requestPath)!
        if acterResponds(request) {
            return
        }
        let path = requestPathURL.path
        let resourceURL = Bundle.main.resourceURL!
        let documentURL = resourceURL.appendingPathComponent(path)
        var foundURL: URL? = nil
        let fileManager = FileManager.default
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: documentURL.path, isDirectory: &isDir) {
            if isDir.boolValue {
                NSLog(documentURL.path)
                for defPage in DEFAULTS {
                    let url = documentURL.appendingPathComponent(defPage)
                    if fileManager.fileExists(atPath: url.path) {
                        foundURL = url
                        break
                    }
                }
            } else {
                foundURL = documentURL
            }
        }
        NSLog(documentURL.path)
        let transmitter = request.transmitter
        if let url = foundURL {
            let data = try! Data(contentsOf: url)
            let ext = url.pathExtension 
            if let contentType = TYPES[ext] {
                transmitter.headers["Content-Type"] = contentType
            } else {
                transmitter.headers["Content-Type"] = UNKNOWN_TYPE
            }
            transmitter.addResponse(data)
        } else {
            transmitter.headers["Content-Type"] = "text/html"
            let responseHtml = "\(HTTPStatus.notFound.fullDescription)<br>" +
            "Requested resource \(path.HTMLEntitiesEncoded) does not exist on this server."
            transmitter.addResponse(responseHtml)
        }
        transmitter.startTransmission()
    }
    
    func acterResponds(_ request: WebServerRequest) -> Bool {
        var pathComponents: [String] = URL(string: request.receiver.path!)!.pathComponents
        pathComponents.removeFirst() // remove first "/"
        guard pathComponents.count >= 2 else {return false}
        let method = pathComponents.popLast()! + ":"
        print(method)
        let className = ACTER_PREFIX + pathComponents.joined(separator: "$")
        print(className)
        print(NSStringFromClass(bbb.self))
        if let classObj = NSClassFromString(className) as? NSObject.Type
        , classObj.instancesRespond(to: Selector(method)) {
            let actor = classObj.init()
            actor.perform(Selector(method), with: request)
            return true
        }
        return false
    }
}
