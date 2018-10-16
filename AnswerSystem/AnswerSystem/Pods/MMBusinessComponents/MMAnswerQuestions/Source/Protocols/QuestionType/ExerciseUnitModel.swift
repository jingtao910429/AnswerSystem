//
//  ExerciseUnitModel.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/6.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import ObjectMapper
import MMToolHelper

public struct ExerciseUnitContentModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    
    public var bookId = ""
    public var bookName = ""
    public var units: [ExerciseUnitModel] = []
    
    public init?(map: Map) {
        if shouldReturnNil(map) {
            return nil
        }
    }
    
    public var nonnilMapProperties: [String] {
        return []
    }
    
    public mutating func mapping(map: Map) {
        bookId <- map["book_id"]
        bookName <- map["book_name"]
        units <- map["units"]
    }
    
}

public struct ExerciseUnitModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var unitId = ""
    public var unitName = ""
    public var unitIndex = ""
    public var isDone = 0
    public var lessons: [LessonModel] = []
    public var papers: [PaperModel] = []
    
    public init?(map: Map) {
        if shouldReturnNil(map) {
            return nil
        }
    }
    
    public var nonnilMapProperties: [String] {
        return []
    }
    
    public mutating func mapping(map: Map) {
        unitId <- map["unit_id"]
        unitName <- map["unit_name"]
        unitIndex <- map["unit_index"]
        isDone <- map["is_done"]
        lessons <- map["lessons"]
        papers <- map["papers"]
    }
}
