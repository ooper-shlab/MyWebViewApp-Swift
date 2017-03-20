//
//  HTTPStatus.swift
//  SwiftWebServer
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/5/4.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import Foundation

enum HTTPStatus: Int {
    case `continue` = 100
    case switchingProtocols
    case processing
    
    case ok = 200
    case created
    case accepted
    case nonAuthoritativeInformation
    case noContent
    case resetContent
    case partialContent
    case multiStatus
    case imUsed
    
    case multipleChoices = 300
    case movedPermanently
    case found
    case seeOther
    case notModified
    case useProxy
    case __Unused__306
    case temporaryRedirect
    case permanentRedirect
    
    case badRequest = 400
    case unauthorized
    case paymentRequired
    case forbidden
    case notFound
    case methodNotAllowed
    case notAcceptable
    case proxyAuthenticationRequired
    case requestTimeout
    case conflict
    case gone
    case lengthRequired
    case preconditionFailed
    case requestEntityTooLarge
    case requestURITooLong
    case unsupportedMediaType
    case requestedRangeNotSatisfiable
    case expectationFailed
    case imATeapot
    
    case unprocessableEntity = 422
    case locked
    case failedDependency

    case upgradeRequired = 426
    
    case internalServerError = 500
    case notImplemented
    case badGateway
    case serviceUnavailable
    case gatewayTimeout
    case httpVersionNotSupported
    case variantAlsoNegotiates
    case insufficientStorage
    case bandwidthLimitExceeded
    case notExtended
}

extension HTTPStatus: CustomStringConvertible {
    var description: String {
        switch self {
            //1xx
        case .continue:
            return "Continue"
        case .switchingProtocols:
            return "Switching Protocols"
        case .processing:
            return "Processing"
            //2xx
        case .ok:
            return "OK"
        case .created:
            return "Created"
        case .accepted:
            return "Accepted"
        case .nonAuthoritativeInformation:
            return "Non-Authoritative Information"
        case .noContent:
            return "No Content"
        case .resetContent:
            return "Reset Content"
        case .partialContent:
            return "Partial Content"
        case .multiStatus:
            return "Multi-Status"
        case .imUsed:
            return "IM Used"
            //3xx
        case .multipleChoices:
            return "Multiple Choices"
        case .movedPermanently:
            return "Moved Permanently"
        case .found:
            return "Found"
        case .seeOther:
            return "See Other"
        case .notModified:
            return "Not Modified"
        case .useProxy:
            return "Use Proxy"
//        case __Unused__306
//            return ""
        case .temporaryRedirect:
            return "Temporary Redirect"
        case .permanentRedirect:
            return "Permanent Redirect"
            //4xx
        case .badRequest:
            return "Bad Request"
        case .unauthorized:
            return "Unauthorized"
        case .paymentRequired:
            return "Payment Required"
        case .forbidden:
            return "Forbidden"
        case .notFound:
            return "Not Found"
        case .methodNotAllowed:
            return "Method Not Allowed"
        case .notAcceptable:
            return "Not Acceptable"
        case .proxyAuthenticationRequired:
            return "Proxy Authentication Required"
        case .requestTimeout:
            return "Request Timeout"
        case .conflict:
            return "Conflict"
        case .gone:
            return "Gone"
        case .lengthRequired:
            return "Length Required"
        case .preconditionFailed:
            return "Precondition Failed"
        case .requestEntityTooLarge:
            return "Request Entity Too Large"
        case .requestURITooLong:
            return "Request-URI Too Long"
        case .unsupportedMediaType:
            return "Unsupported Media Type"
        case .requestedRangeNotSatisfiable:
            return "Requested Range Not Satisfiable"
        case .expectationFailed:
            return "Expectation Failed"
        case .imATeapot:
            return "I'm a teapot"
            
        case .unprocessableEntity:
            return "Unprocessable Entity"
        case .locked:
            return "Locked"
        case .failedDependency:
            return "Failed Dependency"
            
        case .upgradeRequired:
            return "Upgrade Required"
            //5xx
        case .internalServerError:
            return "Internal Server Error"
        case .notImplemented:
            return "Not Implemented"
        case .badGateway:
            return "Bad Gateway"
        case .serviceUnavailable:
            return "Service Unavailable"
        case .gatewayTimeout:
            return "Gateway Timeout"
        case .httpVersionNotSupported:
            return "HTTP Version Not Supported"
        case .variantAlsoNegotiates:
            return "Variant Also Negotiates"
        case .insufficientStorage:
            return "Insufficient Storage"
        case .bandwidthLimitExceeded:
            return "Bandwidth Limit Exceeded"
        case .notExtended:
            return "Not Extended"
            
        default:
            return "__unused__"
        }
    }
    
    var fullDescription: String {
        return "\(self.rawValue) \(self)"
    }
}
