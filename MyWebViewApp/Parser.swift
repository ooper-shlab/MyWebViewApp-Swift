//
//  Parser.swift
//  MyWebViewApp
//
//  Created by 開発 on 2015/8/23.
//  Copyright (c) 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

class Parser: PatternBase<LexicalState, Token> {
    
}

class NonTerminal: NonTerminalBase<LexicalState, Token> {
    //??? Why this cannot be inherited?
    override init(_ string: String) {
        super.init(string)
    }
}
final class Terminal: TerminalBase<LexicalState, Token> {
    required init(extendedGraphemeClusterLiteral value: String) {
        super.init(value)
    }
    required init(stringLiteral value: String) {
        super.init(value)
    }
    required init(unicodeScalarLiteral value: String) {
        super.init(value)
    }
    override init(_ string: String) {
        super.init(string)
    }
    override init(_ type: Token.Type) {
        super.init(type)
    }
}
let Expression = NonTerminal("Expression")
let PrefixExpression = NonTerminal("PrefixExpression")
let BinaryExpression = NonTerminal("BinaryExpression")
let ExpressionList = NonTerminal("ExpressionList")
func test() {
    Expression |=> PrefixExpression & BinaryExpression.opt
    ExpressionList |=> Expression & ("," & ExpressionList).opt
}
