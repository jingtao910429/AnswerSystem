//
//  PaperModel.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/6.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import ObjectMapper
import MMToolHelper

// MARK: - Paper

public struct PaperModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var bookId = ""
    public var subjectName = ""
    public var paperId = ""
    public var subjectId = ""
    public var paperPrice = 0
    public var doneTopicTotal = 0
    public var doneQuestionTotal = 0
    public var questionTotal = 0
    public var scores = 0
    public var bookName = ""
    public var termId = ""
    public var paperName = ""
    public var topicTotal = ""
    public var termName = ""
    public var isDone = -1
    public var paperScore = ""
    public var topics: [TopicModel] = []
    public var bookImg = ""
    public var last_question: LastquestionModel?
    
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
        subjectName <- map["subject_name"]
        paperId <- map["paper_id"]
        subjectId <- map["subject_id"]
        paperPrice <- map["paper_price"]
        doneTopicTotal <- map["done_topic_total"]
        doneQuestionTotal <- map["done_question_total"]
        questionTotal <- map["question_total"]
        scores <- map["scores"]
        bookName <- map["book_name"]
        termId <- map["term_id"]
        paperName <- map["paper_name"]
        topicTotal <- map["topic_total"]
        termName <- map["term_name"]
        isDone <- map["is_done"]
        paperScore <- map["paper_score"]
        topics <- map["topics"]
        bookImg <- map["book_img"]
        last_question <- map["last_question"]
    }
}
