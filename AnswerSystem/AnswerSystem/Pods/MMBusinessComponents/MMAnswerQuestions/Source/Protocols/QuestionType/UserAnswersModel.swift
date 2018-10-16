//
//  UserAnswersModel.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/7.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import ObjectMapper
import MMToolHelper

// MARK: - Question

public struct UserAnswersQuestionModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var score = 0
    public var paperId = ""
    public var answerStatus = 0
    public var answers: [UserAnswerItemModel] = []
    
    public init?(map: Map) {
        if shouldReturnNil(map) {
            return nil
        }
    }
    
    public var nonnilMapProperties: [String] {
        return []
    }
    
    public mutating func mapping(map: Map) {
        score <- map["score"]
        paperId <- map["paperId"]
        answerStatus <- map["answerStatus"]
        answers <- map["answers"]
    }
}

// MARK: - Answer

public struct UserAnswerItemModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var answer = ""
    public var optionAnswer = -1
    public var scores = 0
    public var isRight = 0
    public var optionIndex = -1 {
        didSet {
            if optionIndex != -1 {
                index = "\(optionIndex)"
            }
        }
    }
    public var index = ""
    public var left = ""
    public var middle = ""
    public var right = ""
    public var option = ""
    
    init() {
        
    }
    
    public init?(map: Map) {
        if shouldReturnNil(map) {
            return nil
        }
    }
    
    public var nonnilMapProperties: [String] {
        return []
    }
    
    public mutating func mapping(map: Map) {
        answer <- map["answer"]
        optionAnswer <- map["answer"]
        scores <- map["scores"]
        isRight <- map["is_right"]
        optionIndex <- map["index"]
        index <- map["index"]
        left <- map["left"]
        middle <- map["middle"]
        right <- map["right"]
        option <- map["option"]
    }
}
