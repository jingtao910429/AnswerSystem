//
//  LessonModel.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/6.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import ObjectMapper
import MMToolHelper

// MARK: - Lesson

public struct LessonModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var lessonId = ""
    public var papers: [PaperModel] = []
    public var lessonName = ""
    public var lessonIndex = ""
    public var isDone = 0
    
    public init?(map: Map) {
        if shouldReturnNil(map) {
            return nil
        }
    }
    
    public var nonnilMapProperties: [String] {
        return []
    }
    
    public mutating func mapping(map: Map) {
        lessonId <- map["lesson_id"]
        papers <- map["papers"]
        lessonName <- map["lesson_name"]
        lessonIndex <- map["lesson_index"]
        isDone <- map["is_done"]
    }
}
