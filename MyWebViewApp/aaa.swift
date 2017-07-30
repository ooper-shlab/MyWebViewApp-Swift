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
    @objc func ccc(_ serverRequest: WebServerRequest) {
        let str = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1.0">
        </head>
        <body>
        \(serverRequest.receiver.httpVersion ?? "")<br>
        \(serverRequest.receiver.method ?? "")<br>
        \(serverRequest.receiver.path ?? "")<br>
        <br><a href="/index.html">Back</a>
        </body>
        </html>
        """
        serverRequest.transmitter.addResponse(str)
        serverRequest.transmitter.headers.append("text/html", for: "Content-Type")
        serverRequest.transmitter.startTransmission()
    }
    
    @objc func ddd(_ request: HTTPRequest, _ response: HTTPResponse) {
        var str = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1.0">
        </head>
        <body>
        \(request.httpVersion ?? "")<br>
        \(request.method ?? "")<br>
        \(request.path ?? "")<br>
        <table>
        """
        for header in request.headers {
            str += "<tr><th>\(header.name.htmlEntitiesEncoded)</th><td>\(header.value?.htmlEntitiesEncoded ?? "")</td></tr>"
        }
        str += """
        </table>
        <br><a href="/index.html">Back</a>
        </body>
        </html>
        """
        response.addResponse(str)
        response.headers.append("text/html", for: "Content-Type")
    }
}
