//
//  TokenizerBase.swift
//  SwiftTemplateEngine
//
//  Created by 開発 on 2015/8/19.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

class InternedString {
    private static var internDictionary: [String: InternedString] = [:]
    let string: String
    private init(string: String) {
        self.string = string
    }
    
    class func intern(string: String) -> InternedString {
        if let result = internDictionary[string] {
            return result
        } else {
            return InternedString(string: string)
        }
    }
}
class TokenBase {
    var name: String
    ///position in UTF-16 in source
    var position: Int
    class func createToken(string: String) -> TokenBase {
        fatalError("Abstract method \(__FUNCTION__) not implemented")
    }
    
    init(_ string: String, _ position: Int) {
        self.name = string
        self.position = position
    }
}

protocol StateType: OptionSetType {
    static var Initial: Self {get}
//    static var AllStates: [Self] {get}
}
class TokenizerBase<S: StateType, T: TokenBase where S.Element == S> {
    
    typealias TokenizingProc = (String, Int)->T
    typealias TokenDefs = (pattern: String, state: S, proc: TokenizingProc)
    
    var currentState: S = .Initial
    ///position in UTF-16
    var currentPosition: Int = 0
    var parsingState: (S, Int) {
        get {return (currentState, currentPosition)}
        set {(currentState, currentPosition) = newValue}
    }
    
    private var string: String
    typealias TokenMatcher = (regex: NSRegularExpression, state: S, proc: TokenizingProc)
    private var matchers: [TokenMatcher] = []
    
    init(string: String, syntax: [TokenDefs]) {
        self.string = string
        //super.init()
        for syntaxDef in syntax {
            let regex = try! NSRegularExpression(pattern: "^" + syntaxDef.pattern, options: [])
            matchers.append((regex, syntaxDef.state, syntaxDef.proc))
        }
    }
    
    func getToken() -> T? {
        let range = NSRange(currentPosition..<string.utf16.count)
        for matcher in matchers
        where matcher.state.contains(currentState) {
            if let match = matcher.regex.firstMatchInString(string, options: [], range: range) {
                let range = match.numberOfRanges == 1 ? match.range : match.rangeAtIndex(1)
                let substring = (string as NSString).substringWithRange(range)
                let token = matcher.proc(substring, currentPosition)
                currentPosition += range.length
                return token
            }
        }
        return nil
    }

}
