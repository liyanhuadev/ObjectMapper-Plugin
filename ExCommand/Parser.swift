//
//  Parser.swift
//  ObjectMapper-Plugin
//
//  Created by LyhDev on 2016/12/29.
//  Copyright © 2016年 LyhDev. All rights reserved.
//

import Cocoa

class Parser: NSObject {
    
    func parse(buffer: [String]) -> [Metadata] {
        
        var metadatas = [Metadata]()
        
        var contentStr = buffer.reduce("", +)
        // 计算属性
        // 闭包变量
        // 储存属性
        // 函数
        //
        
        /// Clean `/* */`
        if let regex = try? Regex.init(string: "/\\*.*?\\*/") {
            let range = NSRange.init(location: 0, length: contentStr.length)
            contentStr = regex.regularExpression.stringByReplacingMatches(in: contentStr, range: range, withTemplate: "")
        }
        
        /// Clean `//`
        if let regex = try? Regex.init(string: "//[^\r\n]*") {
            let range = NSRange.init(location: 0, length: contentStr.length)
            contentStr = regex.regularExpression.stringByReplacingMatches(in: contentStr, range: range, withTemplate: "")
        }
        
        if let regex = try? Regex.init(string: "(?:struct|class)[^{\\n]*") {
            let matches = regex.allMatches(contentStr)
            var removeList = [String]()
            for matche in matches {
                print("Model: \(matche.matchedString)")
                if let lower: Int = buffer.index(where: { $0.contains(matche.matchedString) }) {
                    if let blockStr = self.firstBlock(in: contentStr, after: matche.range.upperBound) {
                        let model = matche.matchedString + blockStr
                        let length = model.characters.filter({ char -> Bool in return char == "\n" }).count
                        let upper = lower + length
                        
                        let elements = self.parse(buffer: buffer[Range(lower+1..<upper)].map { $0 })
                        metadatas.append(Metadata.model(range: Range(lower...upper), elements: elements))
                        
                        removeList.append(model)
                    }
                }
            }

            for removeStr in removeList {
                contentStr = contentStr.replacingOccurrences(of: removeStr, with: "")
            }
        }
        
        
        
        
        /// Capture and Clean `Closure`
        //        ".*(?:let|var)\\s+\\w+[\\s:]*\\(.*->\\s+\\w+\\s*[\\)\\!\\?]*(\\s*=\\s*)*"
        if let regex = try? Regex.init(string: ".*(?:let|var)\\s+\\w+[\\s:]*\\(.*->.*\\)[!?]*(\\s*=\\s*[^{])*") {
            
            let matches = regex.allMatches(contentStr)
            var removeList = [String]()
            for matche in matches {
                print("Closure: \(matche.matchedString)")
                if let lower: Int = buffer.index(where: { $0.contains(matche.matchedString) }) {
                    var upper = lower
                    var closure: String = matche.matchedString
                    if let blockStr = self.firstBlock(in: contentStr, after: matche.range.upperBound) {
                        closure += blockStr
                        let length = closure.characters.filter({ (char) -> Bool in return char == "\n" }).count
                        upper = lower + length
                    }
                    metadatas.append(Metadata.closureProperty(range: Range(lower...upper)))
                    
                    removeList.append(closure)
                }
            }
            for removeStr in removeList {
                contentStr = contentStr.replacingOccurrences(of: removeStr, with: "")
            }
        }
        
        
        /// Capture and Clean `func`
        if let regex = try? Regex.init(string: ".*func\\s+\\w+\\(.*\\)\\s*(->[^\\{\\n]*)?[^\\{\\n]*") {
            let matches = regex.allMatches(contentStr)
            var removeList = [String]()
            for matche in matches {
                print("Method: \(matche.matchedString)")
                
                if let lower: Int = buffer.index(where: { $0.contains(matche.matchedString) }) {
                    if let blockStr = self.firstBlock(in: contentStr, after: matche.range.upperBound) {
                        
                        var method = matche.matchedString
                        if !method.hasSuffix("\n") {
                            method.append("\n")
                        }
                        method += blockStr
                        let length = method.characters.filter({ (char) -> Bool in return char == "\n" }).count
                        let upper = lower + length
                        metadatas.append(Metadata.method(range: Range(lower...upper)))
                        
                        removeList.append(method)
                    }
                }
            }
            for removeStr in removeList {
                contentStr = contentStr.replacingOccurrences(of: removeStr, with: "")
            }
        }
        
        
        /// Capture and Clean `let/var`
        
        if let regex = try? Regex.init(string: ".*(?:let|var)\\s+\\w+\\s*:\\s+[^(].*") {
            let matches = regex.allMatches(contentStr)
            for matche in matches {
                print("Variable: \(matche.matchedString)")
                if let index: Int = buffer.index(where: { $0.contains(matche.matchedString) }) {
                    contentStr = contentStr.replacingOccurrences(of: buffer[index], with: "")
                    metadatas.append(Metadata.property(lineNumber: index))
                }
            }
        }
        
        return metadatas
    }
    
    
    func firstBlock(in content: String, after index: String.Index) -> String? {
        
        let tempStr = content.substring(from: index).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard tempStr.hasPrefix("{") else {
            return nil
        }
        
        var blockString: String? = nil
        var currentIndex: String.Index! = tempStr.startIndex
        var closureCount: Int = 0
        
        repeat {
            let currentChar = tempStr[currentIndex]
            if currentChar == "{" {
                closureCount += 1
            } else if currentChar == "}" {
                closureCount -= 1
            }
            currentIndex = tempStr.index(after: currentIndex)
            
            if closureCount < 1 {
                blockString = tempStr.substring(to: currentIndex)
                break
            }
            
        } while currentIndex < tempStr.endIndex
        
        return blockString
    }
    
    
}




extension String {
    
    var length: Int {
        return characters.count
    }
}
