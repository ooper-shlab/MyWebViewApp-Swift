//
//  LinkedDictionary
//  MyWebViewApp
//
//  Created by 開発 on 2015/8/23.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

class LinkedElement<Element> {
    weak var previous: LinkedElement<Element>?
    var next: LinkedElement<Element>?
    var element: Element
    init(element: Element) {
        self.element = element
    }
}

private class LinkedList<Element> {
    var first: LinkedElement<Element>?
    weak var last: LinkedElement<Element>?
    
    func remove(link: LinkedElement<Element>) {
        if let prev = link.previous {
            prev.next = link.next
        }
        if link === last {
            assert(link.next == nil)
            last = link.previous
        }
        if link === first {
            assert(link.previous == nil)
            first = link.next
        }
    }
    func append(link: LinkedElement<Element>) {
        link.previous = last
        last?.next = link
        last = link
        if first == nil {
            first = link
        }
    }
    func append(element: Element) {
        let link = LinkedElement(element: element)
        append(link)
    }
}

struct LinkedDictionary<Key: Hashable, Value>: DictionaryLiteralConvertible, SequenceType {
    var baseDictionary: [Key: LinkedElement<(Key, Value)>] = [:]
    private var linkedList = LinkedList<(Key,Value)>()
    init() {}
    init(dictionaryLiteral elements: (Key, Value)...) {
        baseDictionary = Dictionary(minimumCapacity: elements.count)
        for (key, value) in elements {
            self[key] = value
        }
    }
    subscript(key: Key) -> Value? {
        get {
            return baseDictionary[key]?.element.1
        }
        set(value) {
            assert(value != nil)
            self = self.mutatingSelf
            if let link = baseDictionary[key] {
                linkedList.remove(link)
                linkedList.append(link)
            } else {
                linkedList.append((key, value!))
                baseDictionary[key] = linkedList.last!
            }
            self = mutatingSelf
        }
    }
    func generate() -> LinkedDictionaryGenerator<Key, Value> {
        return LinkedDictionaryGenerator(base: self)
    }
    var mutatingSelf: LinkedDictionary<Key, Value>  {
        mutating get {
            if isUniquelyReferencedNonObjC(&linkedList) {
                return self
            } else {
                var result = LinkedDictionary()
                for (key, value) in self {
                    result[key] = value
                }
                return self
            }
        }
    }
}
/*
- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString  **)error {
    
    float floatResult;
    NSScanner *scanner;
    BOOL returnValue = NO;
    
    scanner = [NSScanner scannerWithString: string];
    [scanner scanString: @"$" intoString: NULL];    //ignore  return value
    if ([scanner scanFloat:&floatResult] && ([scanner isAtEnd])) {
        returnValue = YES;
        if (obj)
        *obj = [NSNumber numberWithFloat:floatResult];
    } else {
        if (error)
        *error = NSLocalizedString(@"Couldn’t convert  to float", @"Error converting");
    }
    return returnValue;
}
*/
class MyFormatter: NSFormatter {
    override func getObjectValue(obj: AutoreleasingUnsafeMutablePointer<AnyObject?>, forString string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>) -> Bool {
        var floatResult: Float = Float()
        var returnValue: Bool = false
        
        let scanner = NSScanner(string: string)
        scanner.scanString("$", intoString: nil)
        if scanner.scanFloat(&floatResult) && scanner.atEnd {
            returnValue = true
            if obj != nil {
                obj.memory = NSNumber(float: floatResult)
            }
        } else {
            if error != nil {
                error.memory = NSLocalizedString("Couldn’t convert  to float", comment: "Error converting")
            }
        }
        return returnValue
    }
}
struct LinkedDictionaryGenerator<Key: Hashable, Value>: GeneratorType {
    var base: LinkedDictionary<Key, Value>
    init(base: LinkedDictionary<Key, Value>) {
        self.base = base
        current = base.linkedList.first
    }
    private var current: LinkedElement<(Key, Value)>?
    mutating func next() -> (Key, Value)? {
        if let currentLink = current {
            current = currentLink.next
            return currentLink.element
        } else {
            return nil
        }
    }
}