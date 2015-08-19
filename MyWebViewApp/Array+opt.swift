//
//  Array+opt.swift
//  MyWebViewApp
//
//  Created by 開発 on 2015/8/20.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation
extension Array {
    func get(index: Int) -> Element? {
        if index >= 0 && index < self.count {
            return self[index]
        } else {
            return nil
        }
    }
    subscript(opt index: Int) -> Element? {
        if index >= 0 && index < self.count {
            return self[index]
        } else {
            return nil
        }
    }
}
