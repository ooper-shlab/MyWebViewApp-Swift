//
//  Parser.swift
//  MyWebViewApp
//
//  Created by 開発 on 2015/8/23.
//  Copyright (c) 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

class NonTerminal: NonTerminalBase<LexicalState, Token> {
    override init(_ nodeType: NodeBase.Type) {
        super.init(nodeType)
    }
}

class Terminal: TerminalBase<LexicalState, Token> {
    override init(_ type: Token.Type) {
        super.init(type)
    }
}

let Expression = NonTerminal(ExpressionNode)
let PrefixExpression = NonTerminal(PrefixExpressionNode)
let BinaryExpression = NonTerminal(BinaryExpressionNode)
//let ExpressionList = NonTerminal("ExpressionList")
let PrefixOperator = NonTerminal(PrefixOperatorNode)
//let InOutExpression = NonTerminal("InOutExpression")
//let TryOperaotr = NonTerminal("TryOperaotr")

class Parser: ParserBase<LexicalState, Token> {
    override func setup() {
        Expression |=> PrefixExpression & BinaryExpression.opt
//        ExpressionList |=> Expression & ("," & ExpressionList).opt
        PrefixExpression |=> PrefixOperator.opt & PrefixExpression
//        PrefixExpression |=> InOutExpression
//        InOutExpression |=> "&" & Terminal(IdentifierToken)
//        TryOperaotr |=> "try" & Symbol("!").opt
    }
    
}
