//
//  ParserBase.swift
//  MyWebViewApp
//
//  Created by 開発 on 2015/8/23.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

class PatternBase<S: StateType, T: TokenBase where S.Element == S>: TokenBase {
    
    init(_ string: String) {
        super.init(string, 0)
    }
    
    var opt: OptPattern<S, T> {
        return OptPattern(pattern: self)
    }
    func or(pattern: PatternBase<S, T>)->AnyPattern<S, T> {
        if let anyPattern = pattern as? AnyPattern<S, T> {
            return AnyPattern([self] + anyPattern.patterns)
        } else {
            return AnyPattern([self, pattern])
        }
    }
    func concat(pattern: PatternBase<S, T>)->SequencePattern<S, T> {
        if let seqPattern = pattern as? SequencePattern<S, T> {
            return SequencePattern([self] + seqPattern.symbols)
        } else {
            return SequencePattern([self, pattern])
        }
    }
    
    func match(parser: ParserBase<S, T>) -> [[NodeBase]] {
        fatalError("Abstract method \(__FUNCTION__) not implemented")
    }
}

class OptPattern<S: StateType, T:TokenBase where S.Element == S>: PatternBase<S,T> {
    var basePattern: PatternBase<S,T>
    init(pattern: PatternBase<S,T>) {
        self.basePattern = pattern
        super.init("")
    }
}

class AnyPattern<S: StateType, T: TokenBase where S.Element == S>: PatternBase<S, T> {
    var patterns: [PatternBase<S, T>]
    init(_ patterns: [PatternBase<S, T>]) {
        self.patterns = patterns
        super.init("")
    }
    override func or(pattern: PatternBase<S, T>)->AnyPattern<S, T> {
        if let anyPattern = pattern as? AnyPattern<S, T> {
            return AnyPattern(self.patterns + anyPattern.patterns)
        } else {
            return AnyPattern(self.patterns + [pattern])
        }
    }
}

class NonTerminalBase<S: StateType, T: TokenBase where S.Element == S>: PatternBase<S, T> {
    var pattern: PatternBase<S, T>? = nil
    func addPattern(pattern: PatternBase<S, T>) {
        self.pattern = self.pattern?.or(pattern) ?? pattern
    }
    //???
    var nodeType: NodeBase.Type
    init(_ nodeType: NodeBase.Type) {
        self.nodeType = nodeType
        super.init(NSStringFromClass(nodeType))
    }
    
    override
    func match(parser: ParserBase<S, T>) -> [[NodeBase]] {
        let matches = pattern?.match(parser) ?? []
        return matches.map {nodes in
            return [nodeType.createNode(nodes)]
        }
    }
}

class TerminalBase<S: StateType, T: TokenBase where S.Element == S>: PatternBase<S, T> {
    var type: T.Type? = nil
    init(_ type: T.Type) {
        self.type = type
        super.init("")
    }
    
}

class Symbol<S: StateType, T: TokenBase where S.Element == S>: PatternBase<S, T>, StringLiteralConvertible {
    override init(_ string: String) {
        super.init(string)
    }
    required init(extendedGraphemeClusterLiteral value: String) {
        super.init(value)
    }
    required init(stringLiteral value: String) {
        super.init(value)
    }
    required init(unicodeScalarLiteral value: String) {
        super.init(value)
    }
    
}

class ToStateBase<S: StateType, T: TokenBase where S.Element == S>:  PatternBase<S, T> {
    var state: S
    init(state: S) {
        self.state = state
        super.init(String(state))
    }
}

class SequencePattern<S: StateType, T: TokenBase where S.Element == S>: PatternBase<S, T> {
    var symbols: [PatternBase<S, T>]
    init(_ symbols: [PatternBase<S, T>]) {
        self.symbols = symbols
        super.init("")
    }
    override func concat(pattern: PatternBase<S, T>)->SequencePattern<S, T> {
        if let seqPattern = pattern as? SequencePattern<S, T> {
            return SequencePattern(self.symbols + seqPattern.symbols)
        } else {
            return SequencePattern(self.symbols + [pattern])
        }
    }
}

infix operator |=> {precedence 90}
func |=> <S: StateType, T: TokenBase>(lhs: NonTerminalBase<S, T>, rhs: PatternBase<S, T>) {
    lhs.addPattern(rhs)
}
func | <S: StateType, T: TokenBase>(lhs: PatternBase<S, T>, rhs: PatternBase<S, T>)->AnyPattern<S, T> {
    return lhs.or(rhs)
}
infix operator ~ {}
func & <S: StateType, T: TokenBase>(lhs: Symbol<S, T>, rhs: Symbol<S, T>)->SequencePattern<S, T> {
    return lhs.concat(rhs)
}
func & <S: StateType, T: TokenBase>(lhs: PatternBase<S, T>, rhs: Symbol<S, T>)->SequencePattern<S, T> {
    return lhs.concat(rhs)
}
func & <S: StateType, T: TokenBase>(lhs: Symbol<S, T>, rhs: PatternBase<S, T>)->SequencePattern<S, T> {
    return lhs.concat(rhs)
}
func & <S: StateType, T: TokenBase>(lhs: PatternBase<S, T>, rhs: PatternBase<S, T>)->SequencePattern<S, T> {
    return lhs.concat(rhs)
}

class ParserBase<S: StateType, T: TokenBase where S.Element == S> {
    var tokenizerStates: [S] = []
    typealias ParserState = (S, Int)
    var parserStates: [ParserState] = []
    func setup() {
        fatalError("Abstract method \(__FUNCTION__) not implemented")
    }
    
    func parse(nt: NonTerminalBase<S, T>) -> NodeBase {
        assert(nt.pattern != nil)
        let matches = nt.pattern!.match(self)
        if matches.count > 1 {
            
        }
    }
}
