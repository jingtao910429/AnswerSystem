//
//  AnswerSystemExerciseHelper.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/9.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import YYText
import MMBaseComponents

class AnswerSystemExerciseHelper: NSObject {
    
    static let shared = AnswerSystemExerciseHelper()
    
    func addExerciseView(owner: UIView, style: ExerciseStyle, topic: TopicModel?, answers: [UserAnswerItemModel] = [], isUserInteracted: Bool = true) -> QuestionBaseView? {
        
        for subView in owner.subviews {
            if subView is QuestionBaseView {
                subView.removeConstraints(subView.constraints)
                subView.removeFromSuperview()
            }
        }
        let rect = CGRect(x: 0, y: 0, width: owner.frame.width, height: owner.frame.height)
        switch style {
        case .Fill:
            let fillBlankView = FillBlankView(frame: rect)
            fillBlankView.isUserInteracted = isUserInteracted
            fillBlankView.loadData(fillBlankTopic: topic)
            owner.addSubview(fillBlankView)
            return fillBlankView
        case .ChooseShowCode,
             .ChooseNoShowCode,
             .ChooseShowCodeOnePosition,
             .ChooseNoShowCodeOnePosition:
            let chooseView = ChooseView(frame: rect)
            chooseView.isUserInteracted = isUserInteracted
            chooseView.loadData(style: style, chooseTopic: topic)
            owner.addSubview(chooseView)
            return chooseView
        case .ChooseFillShowCode,
             .ChooseFillNoShowCode,
             .ChooseFillShowCodeOnePosition,
             .ChooseFillNoShowCodeOnePosition:
            let chooseFillView = ChooseOptionContainerView(frame: rect)
            chooseFillView.isUserInteracted = isUserInteracted
            chooseFillView.loadData(style: style, chooseTopic: topic)
            owner.addSubview(chooseFillView)
            return chooseFillView
        case .Jude:
            let judeView = JudeView(frame: rect)
            judeView.isUserInteracted = isUserInteracted
            judeView.loadData(judeTopic: topic)
            owner.addSubview(judeView)
            return judeView
        case .Read, .PinyinRead:
            let readView = ReadView(frame: rect)
            readView.isUserInteracted = isUserInteracted
            readView.loadData(readTopic: topic, style: style)
            owner.addSubview(readView)
            return readView
        case .AppendCharcterProduceSentence, .AppendCharcterProduceSentenceConditonOne:
            let appendCharacterView = AppendCharcterProduceSentenceView(frame: rect)
            appendCharacterView.isUserInteracted = isUserInteracted
            appendCharacterView.loadData(style: style, sentenceTopic: topic)
            owner.addSubview(appendCharacterView)
            return appendCharacterView
        case .MatchLineTwoOption, .MatchLineThreeOption:
            let matchLineTwoOptionView = MatchLineOptionView(frame: rect)
            matchLineTwoOptionView.isUserInteracted = isUserInteracted
            matchLineTwoOptionView.loadData(topic: topic, matchAnswers: topic?.matchAnswers)
            owner.addSubview(matchLineTwoOptionView)
            return matchLineTwoOptionView
        case .WriteCharacter:
            let writeCharacterView = WriteCharacterView(frame: rect)
            writeCharacterView.isUserInteracted = isUserInteracted
            let url = "\(domain)\(writeWebUrl)?q=\(0)&w=\(300)&l=1"
            writeCharacterView.loadData(topic: topic, url: url)
            owner.addSubview(writeCharacterView)
            return writeCharacterView
        case .WriteUploadImage:
            let writeUploadImageView = WriteView(frame: rect)
            writeUploadImageView.isUserInteracted = isUserInteracted
            writeUploadImageView.loadData(writeTopic: topic)
            owner.addSubview(writeUploadImageView)
            return writeUploadImageView
        case .EggIntoBaskets:
            let eggIntoBasketView = EggIntoBasketView(frame: rect)
            eggIntoBasketView.isUserInteracted = isUserInteracted
            eggIntoBasketView.loadData(eggTopic: topic)
            owner.addSubview(eggIntoBasketView)
            return eggIntoBasketView
        default:
            let questionBaseView = QuestionBaseView(frame: rect)
            questionBaseView.topic = topic
            owner.addSubview(questionBaseView)
            return questionBaseView
        }
    }
    
    //生成组件视图
    func produceChooseOptionClose(style: ExerciseStyle, index: Int, chooseOptionCloseDelegate: ChooseOptionCloseDelegate, topicOptionsModel: TopicOptionsModel?, formateAnswer: RichTextContent? = nil, width: CGFloat = CGFloat(0)) -> TextAttachmentContent {
        
        let appendoptionView = ChooseOptionCloseView()
        appendoptionView.formateRichTextContent = formateAnswer
        appendoptionView.chooseOptionCloseDelegate = chooseOptionCloseDelegate
        appendoptionView.loadData(style: style, topicOptionsModel: topicOptionsModel, width: width)
        appendoptionView.sizeToFit()
        
        let tattachment = YYTextAttachment(content: appendoptionView)
        let textContent = TextAttachmentContent()
        textContent.index = index
        textContent.textContent = tattachment
        return textContent
    }
    
    //生成空组件视图
    func produceEmptyOption(style: ExerciseStyle, chooseEmptyIndex: Int, chooseEmptyViewDelegate: ChooseEmptyViewDelegate, formateAnswer: RichTextContent? = nil) -> TextAttachmentContent {
        
        let view = ChooseEmptyView(frame: CGRect(x: 0, y: 0, width: 60.0, height: 35))
        view.richTextContent = formateAnswer
        view.chooseEmptyIndex = chooseEmptyIndex
        view.style = style
        view.chooseEmptyViewDelegate = chooseEmptyViewDelegate
        view.sizeToFit()
        
        let tattachment = YYTextAttachment(content: view)
        
        let textContent = TextAttachmentContent()
        textContent.range = NSRange(location: 0, length: 1)
        textContent.textContent = tattachment
        
        return textContent
    }
    
}
