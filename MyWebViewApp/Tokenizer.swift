//
//  Tokenizer.swift
//  SwiftTemplateEngine
//
//  Created by 開発 on 2015/8/19.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation
/*
[1]`simple-expression
[2]`(expression)
[3]`{statement}
[4]`defer {...} -> NOT implemented
[5]`do {...} -> NOT implemented
[6]`for ... {...}
[7]`guard ... else {...} -> NOT implemented
[8]`if ... {...}
[9]`repeat {...} while(...)
[10]`while ... {...}
[11]`#... -> NOT implemented
[12]`* ... *` -> `(* ... *)
[13]`/ ...
[14]`:
[15]``
[16]`globals {...} -> NOT implemented
[17]`declare {...} -> NOT implemented
※namespace, classname, implements...
[18]`members {...} -> NOT implemented
[19]`init {...} -> NOT implemented
[20]`deinit {...} -> NOT implemented
[21]`load {...} -> NOT implemented
[22]`raw(...)
[23]`import ...; -> NOT implemented
*/
class Token: TokenBase {}

class HTMLText: Token {
    
}

class Identifier: Token {
    class func createInstance(string: String) -> Token {
        switch string {
        case "if":
            return IfToken(string)
        case "for":
            return ForToken(string)
        default:
            return Identifier(string)
        }
    }
    
}

class LeftParenthesis: Token {
    
}

class LeftBrace: Token {
    
}

class ForToken: Token {
    
}

class IfToken: Token {
    
}

class CommentStart: Token {
    
}

class CommentEnd: Token {
    
}
struct LexicalState: StateType {
    private(set) var rawValue: Int
    init(rawValue: Int) {self.rawValue = rawValue}
    
    static let HTML = LexicalState(rawValue: 1<<0)
    static let Simple = LexicalState(rawValue: 1<<1)
    static let Expression = LexicalState(rawValue: 1<<2)
    static let Comment = LexicalState(rawValue: 1<<3)

    static let Initial: LexicalState = .HTML
}
let lexicalSyntax: [Tokenizer.TokenDefs] = [
    ("((?:[^`]|``)+)", .HTML, {HTMLText($0)}),
    ("((?:[^`*]|``|\\*[^)])+)", .Comment, {HTMLText($0)}),
    ("`([_a-zA-Z][_a-zA-Z0-9]*)", .HTML, {Identifier.createInstance($0)}),
    ("`(\\(\\*)", [.HTML, .Comment], {CommentStart($0)}),
    ("`(\\()", [.HTML, .Comment], {LeftParenthesis($0)}),
    ("(\\()", [.Expression, .Simple], {LeftParenthesis($0)}),
    ("`(\\{)", [.HTML, .Comment], {LeftBrace($0)}),
    ("(\\{)", [.Expression, .Simple], {LeftBrace($0)}),
//    ("(\\*`)", {(state: LexicalState, string: String)->(LexicalState, TokenBase) in
//        guard case .Comment(let nest) = state else {return nil}
//        return (nest, CommentEnd(string))
//    }),
]
class Tokenizer: TokenizerBase<LexicalState> {
    
    var currenState: LexicalState = .Initial
}
