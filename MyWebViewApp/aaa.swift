//
//  aaa.swift
//  MyWebViewApp
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/24.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import Foundation

@objc(__$aaa$bbb)
class bbb: NSObject {
    func ccc(_ serverRequest: WebServerRequest) {
        var str = ""
        str += "<!DOCTYPE html>"
        str += "<html>"
        str += "<head>"
        str += "<meta charset=\"UTF-8\">"
        str += "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1.0\">"
        str += "</head>"
        str += "<body>"
        str += (serverRequest.receiver.httpVersion ?? "") + "<br>"
        str += (serverRequest.receiver.method ?? "") + "<br>"
        str += (serverRequest.receiver.path ?? "") + "<br>"
        str += "</body>"
        str += "</html>"
        serverRequest.transmitter.addResponse(str)
        serverRequest.transmitter.headers.append("text/html", for: "Content-Type")
        serverRequest.transmitter.startTransmission()
    }
    
    func ddd(_ request: HTTPRequest, _ response: HTTPResponse) {
        var str = ""
        str += "<!DOCTYPE html>"
        str += "<html>"
        str += "<head>"
        str += "<meta charset=\"UTF-8\">"
        str += "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1.0\">"
        str += "</head>"
        str += "<body>"
        str += (request.httpVersion ?? "") + "<br>"
        str += (request.method ?? "") + "<br>"
        str += (request.path ?? "") + "<br>"
        str += "<table>"
        for header in request.headers {
            str += "<tr><th>\(header.name.htmlEntitiesEncoded)</th><td>\(header.value?.htmlEntitiesEncoded ?? "")</td></tr>"
        }
        str += "</table>"
        str += "</body>"
        str += "</html>"
        response.addResponse(str)
        response.headers.append("text/html", for: "Content-Type")
    }
}
