//
//  FileParser.swift
//  ObjectMapperExtension
//
//  Created by LyhDev on 2016/12/27.
//  Copyright © 2016年 LyhDev. All rights reserved.
//

import Cocoa



class StructModel {
    
    var name: String = ""
    var variables: [String] = []
    var constants: [String] = []
}

class FileParser: NSObject {

    
    func parser(content: String) -> [StructModel] {
        return analysis(content: formatString(from: content))
    }
    
    
    
    func formatString(from content: String) -> String {
        
        var formatStr: String = content
        
        
        /// 删除 `/* */`
        let searchPattern = "/\\*.*?\\*/"
        if let regex = try? NSRegularExpression(pattern: searchPattern, options: NSRegularExpression.Options.caseInsensitive) {
            let range = NSRange.init(location: 0, length: formatStr.characters.count)
            formatStr = regex.stringByReplacingMatches(in: formatStr, options: NSRegularExpression.MatchingOptions.reportCompletion, range: range, withTemplate: "")
        }
        
        
        /// 删除 `//`
        let searchPattern2 = "//[^\r\n]*"
        if let regex = try? NSRegularExpression(pattern: searchPattern2, options: NSRegularExpression.Options.caseInsensitive) {
            let range = NSRange.init(location: 0, length: formatStr.characters.count)
            formatStr = regex.stringByReplacingMatches(in: formatStr, options: NSRegularExpression.MatchingOptions.reportCompletion, range: range, withTemplate: "")
        }
        
        
        /// 删除多余空格
        let searchPattern3 = "(  )+"
        if let regex = try? NSRegularExpression(pattern: searchPattern3, options: NSRegularExpression.Options.caseInsensitive) {
            let range = NSRange.init(location: 0, length: formatStr.characters.count)
            formatStr = regex.stringByReplacingMatches(in: formatStr, options: NSRegularExpression.MatchingOptions.reportCompletion, range: range, withTemplate: " ")
        }
        
        /// 删除所有func
        let searchPattern4 = "func\\s+\\w+\\(.*\\)(\\s->\\s\\w*)*\\s*"
        if let regex = try? NSRegularExpression(pattern: searchPattern4, options: NSRegularExpression.Options.caseInsensitive) {
            let range = NSRange.init(location: 0, length: formatStr.characters.count)
            let results = regex.matches(in: formatStr, options: .reportProgress, range: range)
            if results.count > 0 {

                let funcStrList = results.map { (result) -> String in
                    let startIndex = formatStr.index(formatStr.startIndex, offsetBy: result.range.location)
                    var endIndex = formatStr.index(startIndex, offsetBy: result.range.length)
                    var closureCount: Int = 0
                    while true {
                        let nextIndex = formatStr.index(endIndex, offsetBy: 0)
                        let char = formatStr[nextIndex]
                        if char == "{" {
                            closureCount += 1
                        } else if char == "}" {
                            closureCount -= 1
                        }
                        
                        endIndex = formatStr.index(after: nextIndex)
                        if closureCount < 1 {
                            break
                        }
                    }
                    let range = Range<String.Index>.init(uncheckedBounds: (startIndex, formatStr.index(after: endIndex)))
                    return formatStr.substring(with: range)
                }
                
                for delStr in funcStrList {
                    formatStr = formatStr.replacingOccurrences(of: delStr, with: "")
                }
                
            }
        }
        
        
        /// 删除闭包变量
        let searchPattern5 = "(let|var)\\s+\\w+\\s*:\\s*\\(.*->\\s+\\w+\\s*[\\)\\!\\?]*(\\s*=\\s*\\w*)*\\s*"
        if let regex = try? NSRegularExpression(pattern: searchPattern5, options: NSRegularExpression.Options.caseInsensitive) {
            let range = NSRange.init(location: 0, length: formatStr.characters.count)
            let results = regex.matches(in: formatStr, options: .reportProgress, range: range)
            if results.count > 0 {
                
                let funcStrList = results.map { (result) -> String in
                    let startIndex = formatStr.index(formatStr.startIndex, offsetBy: result.range.location)
                    var endIndex = formatStr.index(startIndex, offsetBy: result.range.length)
                    var closureCount: Int = 0
                   
                    let nextIndex = formatStr.index(endIndex, offsetBy: 0)
                    if formatStr[nextIndex] != "{" {
                        let range = Range<String.Index>.init(uncheckedBounds: (startIndex, endIndex))
                        return formatStr.substring(with: range)
                    }
                    while true {
                        let nextIndex = formatStr.index(endIndex, offsetBy: 0)
                        let char = formatStr[nextIndex]
                        if char == "{" {
                            closureCount += 1
                        } else if char == "}" {
                            closureCount -= 1
                        }
                        
                        endIndex = formatStr.index(after: nextIndex)
                        if closureCount < 1 {
                            break
                        }
                    }
                    let range = Range<String.Index>.init(uncheckedBounds: (startIndex, formatStr.index(after: endIndex)))
                    return formatStr.substring(with: range)
                    
                }
                
                for delStr in funcStrList {
                    formatStr = formatStr.replacingOccurrences(of: delStr, with: "")
                }
            }
        }
        
        
        
        return formatStr
    }
    
    
    func analysis(content: String) -> [StructModel] {
        
        var array: [StructModel] = []
        
        let regex = Regex("struct (\\w+)[:\\w\\s]*\\{[^}]*")
        let matches = regex.allMatches(content)
        for matche in matches {
            
            let structModel = StructModel()
            let structString = matche.matchedString + "}"
            let structName = matche.captures[0]!
            structModel.name = structName
            
            let varRegex = Regex("(let|var)\\s+(\\w+)[\\s:]*([^\\n]*)")
            let matches = varRegex.allMatches(structString)
            for matche in matches {
                if matche.captures[0]! == "let" {
                    structModel.constants.append(matche.captures[1]!)
                } else {
                    structModel.variables.append(matche.captures[1]!)
                }
            }
            array.append(structModel)
        }
        
        return array
    }
    
    
    
}









