//
//  HTTPRequest.swift
//  MyWebViewApp
//
//  Created by 開発 on 2017/3/23.
//  Copyright © 2017 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

///Represents an HTTP request received by the server.
@objc public class HTTPRequest: NSObject {
    private var receiver: HTTPStreamReceiver
    
    init(_ receiver: HTTPStreamReceiver) {
        self.receiver = receiver
    }
    
    public var userInfo: [String: Any] = [:]
    
    private var _query: HTTPValues? = nil
    public var query: HTTPValues {
        if _query != nil {
            if let
                path = receiver.path,
                let component = URLComponents(string: path),
                let queryString = component.query
            {
                _query = HTTPValues(query: queryString)
            } else {
                _query = HTTPValues()
            }
        }
        return _query!
    }
    
    public var headers: HTTPValues {
        return receiver.headers
    }
    
    public var method: String? {
        return receiver.method
    }
    
    public var path: String? {
        return receiver.path
    }
    
    public var httpVersion: String? {
        return receiver.httpVersion
    }
}
