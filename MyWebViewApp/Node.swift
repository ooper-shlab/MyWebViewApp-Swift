//
//  Node.swift
//  MyWebViewApp
//
//  Created by 開発 on 2015/8/27.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

class ExpressionNode: NodeBase {
    override class func createNode(childNodes: [NodeBase]) -> Self {
        fatalError()
    }
}

class PrefixExpressionNode: NodeBase {
    override class func createNode(childNodes: [NodeBase]) -> Self {
        fatalError()
    }
}

class BinaryExpressionNode: NodeBase {
    override class func createNode(childNodes: [NodeBase]) -> Self {
        fatalError()
    }
}

class PrefixOperatorNode: NodeBase {
    override class func createNode(childNodes: [NodeBase]) -> Self {
        fatalError()
    }
}
