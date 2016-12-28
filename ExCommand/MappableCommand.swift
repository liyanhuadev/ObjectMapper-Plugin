//
//  SourceEditorCommand.swift
//  ObjectMapperEx
//
//  Created by LyhDev on 2016/12/27.
//  Copyright © 2016年 LyhDev. All rights reserved.
//

import Foundation
import XcodeKit

class MappableCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        let lines = invocation.buffer.lines.flatMap { "\($0)" }
        let content = lines.reduce("", +)
        let parser = FileParser()
        let structModelList = parser.parser(content: content)
        
        var newString = "\n\n"
        
        for structModel in structModelList {
            newString += String(format: "extension %@: Mappable {", structModel.name)
            newString += "\n\n\t"
            newString += "init?(map: Map) {"
            for value in structModel.constants {
                newString += "\n\t\t"
                newString += String(format: "%-20s = <#Value#>", (value as NSString).utf8String!)
            }
            newString += "\n}"
            newString += "\n\n\t"
            newString += "mutating func mapping(map: Map) {"
            for value in structModel.variables {
                newString += "\n\t\t"
                newString += String(format: "%-20s <- map[\"%@\"]", (value as NSString).utf8String!, value)
            }
            
            newString += "\n\t}"
            newString += "\n}"
        }
        
        invocation.buffer.lines.add(newString)
        
        completionHandler(nil)
    }
    
}




