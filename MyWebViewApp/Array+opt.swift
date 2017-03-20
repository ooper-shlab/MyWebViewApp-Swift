//
//  Array+opt.swift
//  OOPUtils
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/20.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import Foundation
extension Array {
    func get(_ index: Int) -> Element? {
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
