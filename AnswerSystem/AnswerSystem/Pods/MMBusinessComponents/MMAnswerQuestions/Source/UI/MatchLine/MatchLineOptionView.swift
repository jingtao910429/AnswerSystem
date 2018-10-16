//
//  MatchLineOptionView.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/9.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class MatchLineOptionView: QuestionBaseView {
    
    fileprivate var matchLineView: MatchLineView!
    
    override var answers: [UserAnswerItemModel]? {
        didSet {
            //答案填充
            if let answers = answers {
                matchLineView.answers = answers
            }
        }
    }
    
    public override func fetchAnswers() -> [RichParameterType] {
        let parameters = matchLineView.fetchAnswers()
        self.isEdit = matchLineView.isEdit
        return parameters
    }
    
    override func updateAnswerParseConstraints() {
        super.updateAnswerParseConstraints()
        matchLineConstraints()
    }
    
    override var isUserInteracted: Bool {
        didSet {
            self.matchLineView.isUserInteracted = isUserInteracted
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        matchLineView = MatchLineView(frame: frame)
        questionScrollView.addSubview(matchLineView)
        
        makeConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        matchLineConstraints()
        
        answerParseContainerView?.snp.makeConstraints({ (make) in
            make.top.equalTo(matchLineView.snp.bottom).offset(15).priority(999)
            make.centerX.equalTo(questionScrollView)
            make.left.right.equalTo(self)
            make.bottom.equalTo(questionScrollView).offset(AnswerParseBottomHeight - 5)
        })
    }
    
    fileprivate func matchLineConstraints() {
        matchLineView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.baseRichTextView.snp.bottom).offset(15)
            make.left.equalTo(questionTitleLabel.snp.left)
            make.right.equalTo(questionTitleLabel.snp.right)
            if let isHidden = answerParseContainerView?.isHidden, isHidden {
                make.bottom.equalTo(answerParseStatus ? -25 : -50)
            }
        }
    }
    
    func loadData(topic: TopicModel?, matchAnswers: [LinkOptionModel]? = []) {
        self.topic = topic
        matchLineView.loadData(topic: topic, matchAnswers: matchAnswers)
    }
    
}
