//
//  WebProducer.swift
//  MyWebViewApp
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/23.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import Foundation

let PERFORMER_PREFIX = "__$"
public protocol WebProducible {
    func produce(_ request: WebServerRequest)
}
class WebProducer: WebProducible {
    private(set) static var _producer: WebProducer = WebProducer()
    class var currentProducer: WebProducer {
        return _producer
    }
    
    func produce(_ request: WebServerRequest) {
        if performerResponds(request) {
            return
        }
        let receiver = request.receiver
        let requestPath = receiver.path!
        let requestPathURL = URL(string: requestPath)!
        let path = requestPathURL.path
        let resourceURL = Bundle.main.resourceURL!
        let staticContentURL = resourceURL.appendingPathComponent("StaticContents", isDirectory: true)
        let documentURL = staticContentURL.appendingPathComponent(path)
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
            "Requested resource \(path.htmlEntitiesEncoded) does not exist on this server."
            transmitter.addResponse(responseHtml)
        }
        transmitter.startTransmission()
    }
    
    func performerResponds(_ serverRequest: WebServerRequest) -> Bool {
        var pathComponents: [String] = URL(string: serverRequest.receiver.path!)!.pathComponents
        pathComponents.removeFirst() // remove first "/"
        guard pathComponents.count >= 2 else {return false}
        let methodName = pathComponents.popLast()! + ":"
        let className = PERFORMER_PREFIX + pathComponents.joined(separator: "$")
        print(className)
        if let classObj = NSClassFromString(className) as? NSObject.Type {
            print(classObj)
            let methodName2 = methodName + ":"
            let selector = Selector(methodName)
            let selector2 = Selector(methodName2)
            if classObj.instancesRespond(to: selector) {
                print(methodName)
                let actor = classObj.init()
                actor.perform(selector, with: serverRequest)
                return true
            } else if classObj.instancesRespond(to: selector2) {
                print(methodName2)
                let performer = classObj.init()
                let request = HTTPRequest(serverRequest.receiver)
                let response = HTTPResponse(serverRequest.transmitter)
                performer.perform(selector2, with: request, with: response)
                response.send()
                return true
            }
        }
        return false
    }
}
