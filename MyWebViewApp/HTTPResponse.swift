//
//  HTTPResponse.swift
//  MyWebViewApp
//
//  Created by 開発 on 2017/3/23.
//  Copyright © 2017 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

@objc public class HTTPResponse: NSObject {
    var headers: HTTPValues {
        return transmitter.headers
    }

    var status: HTTPStatus {
        get {
            return transmitter.status
        }
        set {
            transmitter.status = newValue
        }
    }
    var httpVersion: String {
        get {
            return transmitter.httpVersion
        }
        set {
            transmitter.httpVersion = newValue
        }
    }
    
    private let transmitter: HTTPStreamTransmitter
    
    init(_ transmitter: HTTPStreamTransmitter) {
        self.transmitter = transmitter
    }
    
    public func send(_ string: String) {
        transmitter.addResponse(string)
        transmitter.startTransmission()
    }
    
    public func send() {
        transmitter.startTransmission()
    }
    
    @nonobjc public func addResponse(_ string: String) {
        transmitter.addResponse(string)
    }
    
    @nonobjc public func addResponse(_ data: Data) {
        transmitter.addResponse(data)
    }
    
    @nonobjc public func addResponse(_ response: ResponseProvider) {
        transmitter.addResponse(response)
    }
}
