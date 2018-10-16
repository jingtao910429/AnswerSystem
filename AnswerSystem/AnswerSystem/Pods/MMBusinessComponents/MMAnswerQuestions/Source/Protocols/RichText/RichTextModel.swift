//
//  RichTextModel.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/3/30.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import ObjectMapper
import MMToolHelper

//RichText协议控制
public struct RichTextModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
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

public struct RichTextContentModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var content: [RichTextContent] = []
    public var alignment = -1
    public var bgColor = ""
    public var bgImg = ""
    public var objectId = ""
    
    public init?(map: Map) {
        if shouldReturnNil(map) {
            return nil
        }
    }
    
    public var nonnilMapProperties: [String] {
        return []
    }
    
    public mutating func mapping(map: Map) {
        content <- map["content"]
        alignment <- map["alignment"]
        bgColor <- map["bg_color"]
        bgImg <- map["bg_img"]
        objectId <- map["object_id"]
    }
}

// MARK: - RichTextContent

public struct RichTextContent: RichTextMapperModelConvertible, RichTextNonnilMappable {
    public var tag = ""
    public var isBold = false
    public var isUnderline = 0
    public var txt = ""
    public var fontSize = ""
    public var isItalicSelected = ""
    public var tipsFont = ""
    public var tipsFontSize = ""
    public var tipsColor = ""
    public var bgColorSelected = ""
    public var fontFamily = ""
    public var bgColor = ""
    public var alignment = ""
    public var tipsIsItalic = false
    public var type = 0
    public var strType = "" {
        didSet {
            type = strType.intValue() ?? type
        }
    }
    public var isItalic = false
    public var fontColor = ""
    public var isBoldSelected = ""
    public var bgImg = ""
    public var feImgSelected = ""
    public var bgImgSelected = ""
    public var feImg = ""
    public var feImgPlaying = ""
    public var fileUrl = ""
    public var tips = ""
    public var fontColorSelected = ""
    public var width = ""
    public var height = ""
    public var inputBoxIdx = 0
    public var length = ""
    public var scriptType = 0
    public var answer = ""
    public var answers: [String] = []
    public var answerType = ""
    public var inputBoxes: [RichTextInputBoxesItemModel] = []
    
    public init?(map: Map) {
        if shouldReturnNil(map) {
            return nil
        }
    }
    
    public var nonnilMapProperties: [String] {
        return []
    }
    
    public mutating func mapping(map: Map) {
        tag <- map["tag"]
        isBold <- map["is_bold"]
        isUnderline <- map["is_underline"]
        txt <- map["txt"]
        fontSize <- map["font_size"]
        isItalicSelected <- map["is_italic_selected"]
        tipsFont <- map["tips_font"]
        tipsFontSize <- map["tips_font_size"]
        tipsColor <- map["tips_color"]
        bgColorSelected <- map["bg_color_selected"]
        fontFamily <- map["font_family"]
        bgColor <- map["bg_color"]
        alignment <- map["alignment"]
        tipsIsItalic <- map["tips_is_italic"]
        type <- map["type"]
        strType <- map["type"]
        isItalic <- map["is_italic"]
        fontColor <- map["font_color"]
        isBoldSelected <- map["is_bold_selected"]
        bgImg <- map["bg_img"]
        feImgSelected <- map["fe_img_selected"]
        bgImgSelected <- map["bg_img_selected"]
        feImg <- map["fe_img"]
        feImgPlaying <- map["fe_img_playing"]
        fileUrl <- map["file_url"]
        tips <- map["tips"]
        fontColorSelected <- map["font_color_selected"]
        width <- map["width"]
        height <- map["height"]
        inputBoxIdx <- map["input_box_idx"]
        length <- map["length"]
        scriptType <- map["script_type"]
        answer <- map["answer"]
        answers <- map["answer"]
        answerType <- map["answer_type"]
        inputBoxes <- map["input_boxes"]
    }
}

public struct RichTextInputBoxesItemModel: RichTextMapperModelConvertible, RichTextNonnilMappable {
    
    var left = 0
    var height = 0
    var width = 0
    var answer = ""
    var type = 0
    var top = 0
    var index = 0
    
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
        height <- map["height"]
        width <- map["width"]
        answer <- map["answer"]
        type <- map["type"]
        top <- map["top"]
        index <- map["index"]
    }
}
