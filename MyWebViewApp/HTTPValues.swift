//
//  HTTPValues.swift
//  SwiftWebServer
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/5/3.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import Foundation

public typealias HTTPValueItem = (name: String, value: String?)

open class HTTPValues: CustomStringConvertible, Sequence,ExpressibleByDictionaryLiteral {
    public typealias Iterator = Array<HTTPValueItem>.Iterator
    let caseInsensitive: Bool
    private var scalarMapping: [String: String?] = [:]
    private var arrayMapping: [String: [String?]] = [:]
    private var items: [HTTPValueItem] = []
    
    convenience init(query: String) {
        self.init(caseInsensitive: false)
        for q in query.isEmpty ? [] : query.components(separatedBy: "&") {
            var name: String
            var value: String?
            if let equalPos = q.range(of: "=") {
                name = String(q[..<equalPos.lowerBound])
                value = String(q[equalPos.upperBound...])
            } else {
                name = q
                value = nil
            }
            self.append(value?.removingPercentEncoding,
                for: name.removingPercentEncoding!)
        }
    }
    init(caseInsensitive: Bool) {
        self.caseInsensitive = caseInsensitive
    }
    convenience init() {
        self.init(caseInsensitive: false)
    }
    
    open func append(_ item: HTTPValueItem) {
        self.append(item.value, for: item.name)
    }
    
    public func append(_ value: String?, for name: String) {
        var name = name
        items.append((name: name, value: value))
        if caseInsensitive {name = name.lowercased()}
        scalarMapping[name] = value
        if arrayMapping[name] == nil {
            arrayMapping[name] = [value]
        } else {
            arrayMapping[name]!.append(value)
        }
    }
    
    public func remove(_ name: String) {
        var name = name
        removeItemsForName(name)
        if caseInsensitive {name = name.lowercased()}
        scalarMapping.removeValue(forKey: name)
        arrayMapping.removeValue(forKey: name)
    }
    
    open subscript(name: String) -> String? {
        get {
            var name = name
            if caseInsensitive {name = name.lowercased()}
            return scalarMapping[name] ?? nil
        }
        set {
            let name = name
            remove(name)
            self.append(newValue, for: name)
        }
    }
    
    open subscript(all name: String) -> [String?] {
        get {
            var name = name
            if caseInsensitive {name = name.lowercased()}
            return arrayMapping[name] ?? []
        }
        set {
            let name = name
            remove(name)
            for value in newValue {
                self.append(value, for: name)
            }
        }
    }
    
    private func removeItemsForName(_ name: String) {
        if caseInsensitive {
            items = items.filter{$0.name.lowercased() != name.lowercased()}
        } else {
            items = items.filter{$0.name != name}
        }
    }
    
    open var description: String {
        var result: String = ""
        for item in items {
            result += "\(item.name): \(item.value ?? String())\r\n"
        }
        return result
    }
    
    open func makeIterator() -> Iterator {
        return items.makeIterator()
    }
    
    public required init(dictionaryLiteral elements: (String, String?)...) {
        self.caseInsensitive = false
        for (name, value) in elements {
            self.append(value, for: name)
        }
    }
}
