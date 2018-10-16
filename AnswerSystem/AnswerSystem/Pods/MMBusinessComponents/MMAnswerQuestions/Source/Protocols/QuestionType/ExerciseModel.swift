//
//  ExercizeModel.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/6.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import ObjectMapper
import MMToolHelper

public struct ExerciseItemModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var bookId = ""
    public var basicPrice = 0
    public var subjectName = ""
    public var paperId = ""
    public var paperType = ""
    public var subjectId = ""
    public var doneTopicTotal = 0
    public var lastQuestion: LastquestionModel?
    public var bookName = ""
    public var questionTotal = 0
    public var discountAmount = 0
    public var scores = 0
    public var doneQuestionTotal = 0
    public var topicTotal = 0
    public var paperName = ""
    public var payType = 0
    public var termId = ""
    public var paperScore = ""
    public var isDone = 0
    public var termName = ""
    public var bookImg = ""
    public var paperPrice = 0
    
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
        basicPrice <- map["basic_price"]
        subjectName <- map["subject_name"]
        paperId <- map["paper_id"]
        paperType <- map["paper_type"]
        subjectId <- map["subject_id"]
        doneTopicTotal <- map["done_topic_total"]
        lastQuestion <- map["last_question"]
        bookName <- map["book_name"]
        questionTotal <- map["question_total"]
        discountAmount <- map["discountAmount"]
        scores <- map["scores"]
        doneQuestionTotal <- map["done_question_total"]
        topicTotal <- map["topic_total"]
        paperName <- map["paper_name"]
        payType <- map["payType"]
        termId <- map["term_id"]
        paperScore <- map["paper_score"]
        isDone <- map["is_done"]
        termName <- map["term_name"]
        bookImg <- map["book_img"]
        paperPrice <- map["paper_price"]
    }
}

// MARK: - Lastquestion

public struct LastquestionModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var lastCourse: LastcourseModel?
    public var lastTime = ""
    public var questionId = 0
    public var topicId = ""
    public var topicIndex = ""
    public var questionIndex = ""
    public var topicName = ""
    public var paperId = ""
    
    public init?(map: Map) {
        if shouldReturnNil(map) {
            return nil
        }
    }
    
    public var nonnilMapProperties: [String] {
        return []
    }
    
    public mutating func mapping(map: Map) {
        lastCourse <- map["last_course"]
        lastTime <- map["last_time"]
        questionId <- map["question_id"]
        topicId <- map["topic_id"]
        topicIndex <- map["topic_index"]
        questionIndex <- map["question_index"]
        topicName <- map["topic_name"]
        paperId <- map["paper_id"]
    }
}

// MARK: - Lastcourse

public struct LastcourseModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var unitId = ""
    public var lessonId = ""
    public var unitName = ""
    public var paperId = ""
    public var unitIndex = ""
    public var paperName = ""
    public var lessonIndex = ""
    public var lessonName = ""
    
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
        lessonId <- map["lesson_id"]
        unitName <- map["unit_name"]
        paperId <- map["paper_id"]
        unitIndex <- map["unit_index"]
        paperName <- map["paper_name"]
        lessonIndex <- map["lesson_index"]
        lessonName <- map["lesson_name"]
    }
}
