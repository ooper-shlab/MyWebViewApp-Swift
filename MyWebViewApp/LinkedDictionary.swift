//
//  LinkedDictionary
//  MyWebViewApp
//
//  Created by 開発 on 2015/8/23.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

class LinkedEntry<Element> {
    weak var previous: LinkedEntry<Element>?
    var next: LinkedEntry<Element>?
    var element: Element
    init(element: Element) {
        self.element = element
    }
}

private class LinkedList<Element> {
    var first: LinkedEntry<Element>?
    weak var last: LinkedEntry<Element>?
    
    func remove(link: LinkedEntry<Element>) {
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
    
    
    func append(link: LinkedEntry<Element>) {
        link.previous = last
        last?.next = link
        last = link
        if first == nil {
            first = link
        }
    }
    
    
    func append(element: Element) {
        let link = LinkedEntry(element: element)
        append(link)
    }
    
    func makeCopy() -> LinkedList<Element> {
        let newLinkedList = LinkedList<Element>()
        for var p = self.first; p != nil; p = p!.next {
            newLinkedList.append(p!.element)
        }
        return newLinkedList
    }
}

struct LinkedDictionary<Key: Hashable, Value>: DictionaryLiteralConvertible, SequenceType {
    private var baseDictionary: [Key: LinkedEntry<(Key, Value)>] = [:]
    private var linkedList = LinkedList<(Key,Value)>()

    private var movesToLastOnUpdate: Bool = false
    
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
            self.mutatingSelf
            if let entry = baseDictionary[key] {
                if movesToLastOnUpdate {
                    linkedList.remove(entry)
                    linkedList.append(entry)
                } else {
                    entry.element = (key, value!)
                }
            } else {
                linkedList.append((key, value!))
                baseDictionary[key] = linkedList.last!
            }
        }
    }
    
    func generate() -> LinkedDictionaryGenerator<Key, Value> {
        return LinkedDictionaryGenerator(base: self)
    }
    
    var mutatingSelf: LinkedDictionary<Key, Value>  {
        mutating get {
            if !isUniquelyReferencedNonObjC(&linkedList) {
                self.linkedList = self.linkedList.makeCopy()
            }
            return self
        }
    }
}


struct LinkedDictionaryGenerator<Key: Hashable, Value>: GeneratorType {
    var base: LinkedDictionary<Key, Value>
    init(base: LinkedDictionary<Key, Value>) {
        self.base = base
        current = base.linkedList.first
    }
    private var current: LinkedEntry<(Key, Value)>?
    mutating func next() -> (Key, Value)? {
        if let currentLink = current {
            current = currentLink.next
            return currentLink.element
        } else {
            return nil
        }
    }
}