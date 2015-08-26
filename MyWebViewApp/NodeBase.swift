//
//  NodeBase.swift
//  MyWebViewApp
//
//  Created by 開発 on 2015/8/27.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

class NodeBase {
    
    class func createNode(childNodes: [NodeBase]) -> Self {
        fatalError("Abstract method \(__FUNCTION__) not implemented")
    }
    
}