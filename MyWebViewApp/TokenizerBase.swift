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
    
    class func create(string: String) -> InternedString {
        if let result = internDictionary[string] {
            return result
        } else {
            return InternedString(string: string)
        }
    }
}
class TokenBase {
    var name: String
    class func createToken(string: String) -> TokenBase {
        fatalError("TokenBase is an abstract class. Define \(__FUNCTION__) in \(self)")
    }
    
    init(_ string: String) {
        self.name = string
    }
}

protocol StateType: OptionSetType {
    static var Initial: Self {get}
//    static var AllStates: [Self] {get}
}
class TokenizerBase<State: StateType> {
    
    typealias TokenizingProc = String->TokenBase
    typealias TokenDefs = (pattern: String, state: State, proc: TokenizingProc)
    
    var currentState: State = .Initial
}
