//
//  ExerciseQuestionsListModel.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/6.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import ObjectMapper
import MMToolHelper

public struct ExerciseQuestionsContentModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    
    public var paperId = ""
    public var paperName = ""
    public var paperScore = 0
    public var scores = 0
    public var topics: [TopicModel] = []
    
    public init?(map: Map) {
        if shouldReturnNil(map) {
            return nil
        }
    }
    
    public var nonnilMapProperties: [String] {
        return []
    }
    
    public mutating func mapping(map: Map) {
        paperId <- map["paper_id"]
        paperName <- map["paper_name"]
        paperScore <- map["paper_score"]
        scores <- map["scores"]
        topics <- map["topics"]
    }
}
