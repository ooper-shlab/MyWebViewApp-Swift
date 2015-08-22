//
//  OOPRegularExpression.swift
//  OOPUtils
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/22.
//  Copyright (c) 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

//
//  Caution:
//  Each instance of this class contains a block, thus if the contained block is mutable,
//  -- if the contained block has captured variables and any of them may change or are thread-unsafe --
//  the instance cannot be thread-safe.
//
//  NSCoding not supported.
//
class OOPRegularExpression: NSRegularExpression {
    
    typealias ReplacementBlock = (NSTextCheckingResult, String, Int, String)->String
    typealias SimpleReplacementBlock = (String, Int)->String
    
    private var replacementBlock: ReplacementBlock
    
    init(pattern: String, options: NSRegularExpressionOptions, block: ReplacementBlock) throws {
        self.replacementBlock = block
        try super.init(pattern: pattern, options: options)
    }
    
    convenience init(pattern: String, options: NSRegularExpressionOptions, simpleBlock: SimpleReplacementBlock) throws {
        try self.init(pattern: pattern, options: options, block: {result,string,offset,_ in
            let matchedString = (string as NSString).substringWithRange(result.range)
            return simpleBlock(matchedString, offset)
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func replacementStringForResult(result: NSTextCheckingResult, inString string: String, offset: Int, template templ: String) -> String {
        return self.replacementBlock(result, string, offset, templ)
    }
    
    func stringByReplacingMatchesInString(string: String, options: NSMatchingOptions, range: NSRange) -> String {
        return super.stringByReplacingMatchesInString(string, options: options, range: range, withTemplate: "*")
    }
    
    func stringByReplacingMatchesInString(string: String, options: NSMatchingOptions = []) -> String {
        return self.stringByReplacingMatchesInString(string, options: options, range: NSRange(0..<string.utf16.count))
    }
    
    func replaceMatchesInString(string: NSMutableString, options: NSMatchingOptions, range: NSRange) -> Int {
        return super.replaceMatchesInString(string, options: options, range: range, withTemplate: "*")
    }
    
    func replaceMatchesInString(string: NSMutableString, options: NSMatchingOptions = []) -> Int {
        return self.replaceMatchesInString(string, options: options, range: NSRange(0..<string.length))
    }
}
