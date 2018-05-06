//
//  ImmutableMappableCommand.swift
//  ObjectMapperExtension
//
//  Created by LyhDev on 2016/12/27.
//  Copyright © 2016年 LyhDev. All rights reserved.
//

import Foundation
import XcodeKit

class ImmutableMappableCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {

        
        let lines = invocation.buffer.lines.flatMap { "\($0)" }
        
        var classModelImpl: [(Int, String)] = []
        
        let metadatas = Parser().parse(buffer: lines)
        
        for case let Metadata.model(range, elements) in metadatas {
            
            let modelBuffer = Array(lines[range])
            let pattern = ".*(struct|class)\\s+(\\w+)([^{\\n]*)"
            if let regex = try? Regex(string: pattern), let matche = regex.match(modelBuffer[0]) {
                
                let isStruct = matche.captures[0] == "struct"
                let modelName = matche.captures[1]!
                
                if matche.captures[0] == "class" {
                    let protocolStr = matche.captures[2]!.contains(":") ? ", ImmutableMappable " : ": ImmutableMappable "
                    var str = modelBuffer[0]
                    str.replaceSubrange(matche.range, with: matche.matchedString + protocolStr)
                    invocation.buffer.lines[range.lowerBound] = str
                }
                
                var initial = String(format: "\n\n\t%@ init(map: Map) throws {", isStruct ? "" : "required ")
                var mapping = String(format: "\n\n\t%@func mapping(map: Map) {", isStruct ? "mutating " : "")
                for case let Metadata.property(lineNumber) in elements {
                    if let regex = try? Regex(string: "(.*)(let|var)\\s+(\\w+)\\s*:"),
                        let matche = regex.match(modelBuffer[lineNumber+1]) {
                        if matche.captures[0]!.contains("static") {
                            continue
                        }
                        let value = matche.captures[2]!
                        if matche.captures[1] == "var" {
                            mapping += String(format: "\n\t\t%-20s <- map[\"%@\"]", (value as NSString).utf8String!, value)
                        } else {
                            mapping += String(format: "\n\t\t%-20s >>> map[\"%@\"]", (value as NSString).utf8String!, value)
                        }
                        
                        initial += String(format: "\n\t\t%-20s = try map.value(\"%@\")", (value as NSString).utf8String!, value)
                        
                    }
                }
                initial += "\n\t}"
                mapping += "\n\t}"
                
                if isStruct {
                    let protocolImpl = String(format: "\n\nextension %@: ImmutableMappable {%@%@\n}", modelName, initial, mapping)
                    invocation.buffer.lines.add(protocolImpl)
                } else {
                    let protocolImpl = String(format: "%@%@", initial, mapping)
                    classModelImpl.append((range.upperBound-1, protocolImpl))
                }
            }
        }
        
        classModelImpl.sort { (args1, args2) -> Bool in return args1.0 > args2.0 }
        for (index, impl) in classModelImpl {
            invocation.buffer.lines.insert(impl, at: index)
        }
        
        completionHandler(nil)    }
}
