//
//  RequestValue.swift
//  MyWebViewApp
//
//  Created by 開発 on 2015/8/20.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation
enum RequestValue {
    case Text(String)
    case Array([String])
}
extension RequestValue {
    func asArray() -> [String] {
        switch self {
        case Text(let value):
            return [value]
        case Array(let values):
            return values
        }
    }
    func asText() -> String {
        switch self {
        case Text(let value):
            return value
        case Array(let values):
            return values.first ?? ""
        }
    }
    func asInt() -> Int? {
        switch self {
        case Text(let value):
            return Int(value)
        case Array(let values):
            return values.first.flatMap{Int($0)}
        }
    }
}
