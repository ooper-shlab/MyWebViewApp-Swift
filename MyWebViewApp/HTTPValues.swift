//
//  HTTPValues.swift
//  SwiftWebServer
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/5/3.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import Foundation

public typealias HTTPValueItem = (name: String, value: String?)

public class HTTPValues: CustomStringConvertible, SequenceType,DictionaryLiteralConvertible {
    public typealias Generator = Array<HTTPValueItem>.Generator
    let caseInsensitive: Bool
    private var scalarMapping: [String: String?] = [:]
    private var arrayMapping: [String: [String?]] = [:]
    private var items: [HTTPValueItem] = []
    
    convenience init(query: String) {
        self.init(caseInsensitive: false)
        for q in query.isEmpty ? [] : query.componentsSeparatedByString("&") {
            var name: String
            var value: String?
            if let equalPos = q.rangeOfString("=") {
                name = q.substringToIndex(equalPos.startIndex)
                value = q.substringFromIndex(equalPos.endIndex)
            } else {
                name = q
                value = nil
            }
            self.append(value?.stringByRemovingPercentEncoding,
                forName: name.stringByRemovingPercentEncoding!)
        }
    }
    init(caseInsensitive: Bool) {
        self.caseInsensitive = caseInsensitive
    }
    convenience init() {
        self.init(caseInsensitive: false)
    }
    
    public func append(item: HTTPValueItem) {
        self.append(item.value, forName: item.name)
    }
    
    public func append(value: String?, var forName name: String) {
        items.append((name: name, value: value))
        if caseInsensitive {name = name.lowercaseString}
        scalarMapping[name] = value
        if arrayMapping[name] == nil {
            arrayMapping[name] = [value]
        } else {
            arrayMapping[name]!.append(value)
        }
    }
    
    public func remove(var name: String) {
        removeItemsForName(name)
        if caseInsensitive {name = name.lowercaseString}
        scalarMapping.removeValueForKey(name)
        arrayMapping.removeValueForKey(name)
    }
    
    public subscript(var name: String) -> String? {
        get {
            if caseInsensitive {name = name.lowercaseString}
            return scalarMapping[name] ?? nil
        }
        set {
            remove(name)
            self.append(newValue, forName: name)
        }
    }
    
    public subscript(var all name: String) -> [String?] {
        get {
            if caseInsensitive {name = name.lowercaseString}
            return arrayMapping[name] ?? []
        }
        set {
            remove(name)
            for value in newValue {
                self.append(value, forName: name)
            }
        }
    }
    
    private func removeItemsForName(name: String) {
        if caseInsensitive {
            items = items.filter{$0.name.lowercaseString != name.lowercaseString}
        } else {
            items = items.filter{$0.name != name}
        }
    }
    
    public var description: String {
        var result: String = ""
        for item in items {
            result += "\(item.name): \(item.value ?? String())\r\n"
        }
        return result
    }
    
    public func generate() -> Generator {
        return items.generate()
    }
    
    public required init(dictionaryLiteral elements: (String, String?)...) {
        self.caseInsensitive = false
        for (name, value) in elements {
            self.append(value, forName: name)
        }
    }
}