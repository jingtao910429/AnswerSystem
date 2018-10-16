//
//  TopicModel.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/6.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import ObjectMapper
import MMToolHelper

// MARK: - Topic

public class TopicModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var content: RichTextModel?
    public var lastTime = ""
    public var name = ""
    public var id = ""
    public var parentId = ""
    public var canError = 0
    public var score = CGFloat(0)
    public var type = 0
    public var typeName = ""
    public var index = ""
    public var lineThickness = ""
    public var lineImg = ""
    public var lineColor = ""
    public var hasBeenDone = false
    public var answerStatus = 0
    public var personsRight = 0
    public var personsDone = 0

    public var questions: [TopicModel] = []
    public var postfix: RichTextModel?
    public var answers: [String] = []
    public var writeAnswers: [WriteAnswerModel] = []
    public var matchAnswers: [LinkOptionModel] = []
    public var chooseAnswers: [ChooseOptionModel] = []
    public var options: [TopicOptionsModel] = []
    public var subOptions: [TopicOptionSubOptionModel] = []
    public var words: [WordOptionModel] = []
    
    //用户答案
    public var userAnswer: [UserAnswerItemModel] = []
    //答案解析
    public var answersParsing: AnswersParseModel?
    //知识要点
    public var topics: [AnswerParseKnowleadgeContentModel] = []
    
    public init() {
    }
    
    public required init?(map: Map) {
        if shouldReturnNil(map) {
            return nil
        }
    }
    
    public var nonnilMapProperties: [String] {
        return []
    }
    
    public func mapping(map: Map) {
        //题目相关字段
        content <- (map["content"], RichTextJsonModelTransform())
        lastTime <- map["last_time"]
        name <- map["title"]
        id <- map["id"]
        parentId <- map["parentId"]
        canError <- map["canError"]
        score <- map["score"]
        type <- (map["typeId"], RichTextTransformInt())
        typeName <- map["typeName"]
        index <- map["number"]
        lineThickness <- map["lineThickness"]
        lineImg <- map["lineImg"]
        lineColor <- map["lineColor"]
        hasBeenDone <- map["hasBeenDone"]
        answerStatus <- map["answerStatus"]
        questions <- map["childQuestions"]
        postfix <- map["endnotes"]
        answers <- map["answers"]
        writeAnswers <- map["answers"]
        matchAnswers <- map["answers"]
        chooseAnswers <- map["answers"]
        options <- map["options"]
        subOptions <- map["options"]
        words <- map["words"]
        
        //树形结构接口相关，区别answers增加answerObj
        //用于获取标准答案和用户答案
        answers <- map["answerObj"]
        writeAnswers <- map["answerObj"]
        matchAnswers <- map["answerObj"]
        chooseAnswers <- map["answerObj"]
        userAnswer <- map["userAnswerObj"]
        
        //答案解析
        answersParsing <- map["answersParsing"]
        personsRight <- map["personsRight"]
        personsDone <- map["personsDone"]
        topics <- map["topics"]
    }
}

public struct TopicOptionsModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var index = ""
    public var richtext: RichTextContentModel?
    
    public init?(map: Map) {
        if shouldReturnNil(map) {
            return nil
        }
    }
    
    public var nonnilMapProperties: [String] {
        return []
    }
    
    public mutating func mapping(map: Map) {
        index <- map["index"]
        richtext <- map["richtext"]
    }
}

public struct AnswersParseModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var richtext: RichTextContentModel?
    
    public init?(map: Map) {
        if shouldReturnNil(map) {
            return nil
        }
    }
    
    public var nonnilMapProperties: [String] {
        return []
    }
    
    public mutating func mapping(map: Map) {
        richtext <- map["richtext"]
    }
}

public struct TopicOptionSubOptionModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var index = ""
    public var option: TopicOptionsModel?
    
    public init?(map: Map) {
        if shouldReturnNil(map) {
            return nil
        }
    }
    
    public var nonnilMapProperties: [String] {
        return []
    }
    
    public mutating func mapping(map: Map) {
        index <- map["index"]
        option <- map["option"]
    }
}

public struct WordOptionModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var index = ""
    public var chars: [[String: String]] = []
    public var datas: [String] = []
    public var desc: RichTextModel?
    
    public init?(map: Map) {
        if shouldReturnNil(map) {
            return nil
        }
    }
    
    public var nonnilMapProperties: [String] {
        return []
    }
    
    public mutating func mapping(map: Map) {
        index <- map["index"]
        chars <- map["chars"]
        datas <- map["datas"]
        desc <- map["desc"]
    }
}

public struct LinkOptionModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var left: RichTextModel?
    public var middle: RichTextModel?
    public var right: RichTextModel?
    
    public init?(map: Map) {
        if shouldReturnNil(map) {
            return nil
        }
    }
    
    public var nonnilMapProperties: [String] {
        return []
    }
    
    public mutating func mapping(map: Map) {
        left <- map["left"]
        middle <- map["middle"]
        right <- map["right"]
    }
}

public struct ChooseOptionModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var index = ""
    public var option: RichTextModel?
    public var answer = ""
    
    public init?(map: Map) {
        if shouldReturnNil(map) {
            return nil
        }
    }
    
    public var nonnilMapProperties: [String] {
        return []
    }
    
    public mutating func mapping(map: Map) {
        index <- map["index"]
        option <- map["option"]
        answer <- map["answer"]
    }
}

public struct WriteAnswerModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var answer = ""
    public var scores = 0
    public var index = ""
    public var isRight = 0
    
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
        scores <- map["scores"]
        index <- map["index"]
        isRight <- map["is_right"]
    }
}

public struct AnswerParseKnowleadgeContentModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    
    public var associatedTopics: [AnswerParseKnowleadgeContentModel] = []
    public var association = ""
    public var content = ""
    public var description = ""
    public var domain: AnswerParseKnowleadgeDomainContentModel?
    public var domainId = ""
    public var domainType = ""
    public var unitId = ""
    public var unitName = ""
    public var textbookId = ""
    public var favorite = false
    public var free = false
    public var img = ""
    public var split = ""
    public var tags: [AnswerParseKnowleadgeTagsModel] = []
    public var textbookSubscribed = false
    public var subjectId = ""
    public var subjectName = ""
    public var type = 0
    public var updateTime = ""
    public var textbooks: [AnswerParseKnowleadgeTextbooksModel] = []
    public var units: [AnswerParseKnowleadgeUnitDetailContentModel] = []
    
    public init?(map: Map) {
        if shouldReturnNil(map) {
            return nil
        }
    }
    
    public var nonnilMapProperties: [String] {
        return []
    }
    
    public mutating func mapping(map: Map) {
        domainId <- map["domainId"]
        domainType <- map["domainType"]
        unitId <- map["unitId"]
        unitName <- map["unitName"]
        textbookId <- map["textbookId"]
        content <- map["content"]
        domain <- map["domain"]
        description <- map["description"]
        tags <- map["tags"]
        img <- map["img"]
        split <- map["split"]
        association <- map["association"]
        associatedTopics <- map["associatedTopics"]
        favorite <- map["favorite"]
        free <- map["free"]
        textbookSubscribed <- map["textbookSubscribed"]
        subjectId <- map["subjectId"]
        subjectName <- map["subjectName"]
        type <- map["type"]
        updateTime <- map["updateTime"]
        textbooks <- map["textbooks"]
        units <- map["units"]
    }
}

public struct AnswerParseKnowleadgeDomainContentModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var id = ""
    public var textbookId = ""
    public var unitId = ""
    public var unitName = ""
    public var content = ""
    public var img = ""
    public var video = ""
    public var audio = ""
    public var phonogram = ""
    public var explain = ""
    public var source = ""
    public var spellUk = ""
    public var spellUs = ""
    public var audioUk = ""
    public var audioUs = ""
    
    public init?(map: Map) {
        if shouldReturnNil(map) {
            return nil
        }
    }
    
    public var nonnilMapProperties: [String] {
        return []
    }
    
    public mutating func mapping(map: Map) {
        id <- map["id"]
        textbookId <- map["textbookId"]
        unitId <- map["unitId"]
        unitName <- map["unitName"]
        content <- map["content"]
        img <- map["img"]
        video <- map["video"]
        audio <- map["audio"]
        phonogram <- map["phonogram"]
        explain <- map["explain"]
        source <- map["source"]
        spellUk <- map["spellUk"]
        spellUs <- map["spellUs"]
        audioUk <- map["audioUk"]
        audioUs <- map["audioUs"]
    }
}

public struct AnswerParseKnowleadgeTagsModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var createTime = ""
    public var deleted = false
    public var description = ""
    public var id = ""
    public var name = ""
    public var updateTime = ""
    
    public init?(map: Map) {
        if shouldReturnNil(map) {
            return nil
        }
    }
    
    public var nonnilMapProperties: [String] {
        return []
    }
    
    public mutating func mapping(map: Map) {
        createTime <- map["createTime"]
        deleted <- map["deleted"]
        description <- map["description"]
        name <- map["name"]
        id <- map["id"]
        updateTime <- map["updateTime"]
    }
}

public struct AnswerParseKnowleadgeTextbooksModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var id = ""
    public var name = ""
    
    public init?(map: Map) {
        if shouldReturnNil(map) {
            return nil
        }
    }
    
    public var nonnilMapProperties: [String] {
        return []
    }
    
    public mutating func mapping(map: Map) {
        name <- map["name"]
        id <- map["id"]
    }
}

public struct AnswerParseKnowleadgeUnitDetailContentModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var id = ""
    public var name = ""
    public var topicsCount = 0
    public var hasFreeTopics = false
    public var lastStudyInfo = ""
    public var textbookName = ""
    public var textbookId = ""
    public var lastTopic: AnswerParseTopicKnowleadgeContentModel?
    
    public init?(map: Map) {
        if shouldReturnNil(map) {
            return nil
        }
    }
    
    public var nonnilMapProperties: [String] {
        return []
    }
    
    public mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        topicsCount <- map["topicsCount"]
        hasFreeTopics <- map["hasFreeTopics"]
        lastStudyInfo <- map["lastStudyInfo"]
        textbookName <- map["textbookName"]
        textbookId <- map["textbookId"]
        lastTopic <- map["lastTopic"]
    }
}

public struct AnswerParseTopicKnowleadgeContentModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var topicId = ""
    public var topicContent = ""
    public var unitId = ""
    public var textbookId = ""
    public var unitName = ""
    public var textbookName = ""
    public var available = ""
    
    public init?(map: Map) {
        if shouldReturnNil(map) {
            return nil
        }
    }
    
    public var nonnilMapProperties: [String] {
        return []
    }
    
    public mutating func mapping(map: Map) {
        topicId <- map["topicId"]
        topicContent <- map["topicContent"]
        unitId <- map["unitId"]
        textbookId <- map["textbookId"]
        textbookName <- map["textbookName"]
        unitName <- map["unitName"]
        available <- map["available"]
    }
}



