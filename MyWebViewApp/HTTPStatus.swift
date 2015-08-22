//
//  HTTPStatus.swift
//  SwiftWebServer
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/5/4.
//  Copyright (c) 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

enum HTTPStatus: Int {
    case Continue = 100
    case SwitchingProtocols
    case Processing
    
    case OK = 200
    case Created
    case Accepted
    case NonAuthoritativeInformation
    case NoContent
    case ResetContent
    case PartialContent
    case MultiStatus
    case IMUsed
    
    case MultipleChoices = 300
    case MovedPermanently
    case Found
    case SeeOther
    case NotModified
    case UseProxy
    case __Unused__306
    case TemporaryRedirect
    case PermanentRedirect
    
    case BadRequest = 400
    case Unauthorized
    case PaymentRequired
    case Forbidden
    case NotFound
    case MethodNotAllowed
    case NotAcceptable
    case ProxyAuthenticationRequired
    case RequestTimeout
    case Conflict
    case Gone
    case LengthRequired
    case PreconditionFailed
    case RequestEntityTooLarge
    case RequestURITooLong
    case UnsupportedMediaType
    case RequestedRangeNotSatisfiable
    case ExpectationFailed
    case ImATeapot
    
    case UnprocessableEntity = 422
    case Locked
    case FailedDependency

    case UpgradeRequired = 426
    
    case InternalServerError = 500
    case NotImplemented
    case BadGateway
    case ServiceUnavailable
    case GatewayTimeout
    case HTTPVersionNotSupported
    case VariantAlsoNegotiates
    case InsufficientStorage
    case BandwidthLimitExceeded
    case NotExtended
}

extension HTTPStatus: CustomStringConvertible {
    var description: String {
        switch self {
            //1xx
        case Continue:
            return "Continue"
        case SwitchingProtocols:
            return "Switching Protocols"
        case Processing:
            return "Processing"
            //2xx
        case OK:
            return "OK"
        case Created:
            return "Created"
        case Accepted:
            return "Accepted"
        case NonAuthoritativeInformation:
            return "Non-Authoritative Information"
        case NoContent:
            return "No Content"
        case ResetContent:
            return "Reset Content"
        case PartialContent:
            return "Partial Content"
        case MultiStatus:
            return "Multi-Status"
        case IMUsed:
            return "IM Used"
            //3xx
        case MultipleChoices:
            return "Multiple Choices"
        case MovedPermanently:
            return "Moved Permanently"
        case Found:
            return "Found"
        case SeeOther:
            return "See Other"
        case NotModified:
            return "Not Modified"
        case UseProxy:
            return "Use Proxy"
//        case __Unused__306
//            return ""
        case TemporaryRedirect:
            return "Temporary Redirect"
        case PermanentRedirect:
            return "Permanent Redirect"
            //4xx
        case BadRequest:
            return "Bad Request"
        case Unauthorized:
            return "Unauthorized"
        case PaymentRequired:
            return "Payment Required"
        case Forbidden:
            return "Forbidden"
        case NotFound:
            return "Not Found"
        case MethodNotAllowed:
            return "Method Not Allowed"
        case NotAcceptable:
            return "Not Acceptable"
        case ProxyAuthenticationRequired:
            return "Proxy Authentication Required"
        case RequestTimeout:
            return "Request Timeout"
        case Conflict:
            return "Conflict"
        case Gone:
            return "Gone"
        case LengthRequired:
            return "Length Required"
        case PreconditionFailed:
            return "Precondition Failed"
        case RequestEntityTooLarge:
            return "Request Entity Too Large"
        case RequestURITooLong:
            return "Request-URI Too Long"
        case UnsupportedMediaType:
            return "Unsupported Media Type"
        case RequestedRangeNotSatisfiable:
            return "Requested Range Not Satisfiable"
        case ExpectationFailed:
            return "Expectation Failed"
        case ImATeapot:
            return "I'm a teapot"
            
        case UnprocessableEntity:
            return "Unprocessable Entity"
        case Locked:
            return "Locked"
        case FailedDependency:
            return "Failed Dependency"
            
        case UpgradeRequired:
            return "Upgrade Required"
            //5xx
        case InternalServerError:
            return "Internal Server Error"
        case NotImplemented:
            return "Not Implemented"
        case BadGateway:
            return "Bad Gateway"
        case ServiceUnavailable:
            return "Service Unavailable"
        case GatewayTimeout:
            return "Gateway Timeout"
        case HTTPVersionNotSupported:
            return "HTTP Version Not Supported"
        case VariantAlsoNegotiates:
            return "Variant Also Negotiates"
        case InsufficientStorage:
            return "Insufficient Storage"
        case BandwidthLimitExceeded:
            return "Bandwidth Limit Exceeded"
        case NotExtended:
            return "Not Extended"
            
        default:
            return "__unused__"
        }
    }
    
    var fullDescription: String {
        return "\(self.rawValue) \(self)"
    }
}
