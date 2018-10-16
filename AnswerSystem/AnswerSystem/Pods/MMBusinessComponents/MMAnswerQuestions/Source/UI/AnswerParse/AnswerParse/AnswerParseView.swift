//
//  AnswerParseView.swift
//  MMBusinessComponents
//
//  Created by Mac on 2018/8/24.
//

import UIKit
import YYText

//答案解析
class AnswerParseView: UIView {
    
    fileprivate var nameLabel: UILabel!
    fileprivate var answerParseView: YYLabel!
    
    var answersParsing: AnswersParseModel? {
        didSet {
            if let answersParsing = answersParsing {
                //答案解析model
                let _ = AnswerSystemManager.shared.richText(richText: answerParseView, model: answersParsing.richtext)
                
                let bestSize = answerParseView.sizeThatFits(CGSize(width: self.width - 30, height: CGFloat.greatestFiniteMagnitude))
                answerParseView.snp.remakeConstraints { (make) in
                    make.left.equalTo(15)
                    make.right.equalTo(-15)
                    make.top.equalTo(nameLabel.snp.bottom).offset(5)
                    make.height.equalTo(bestSize.height + 5)
                    make.bottom.equalTo(-2)
                }
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        nameLabel = UILabel()
        nameLabel.text = "答案解析："
        nameLabel.font = RTBoldNormalFont
        nameLabel.textColor = RTTextColor
        addSubview(nameLabel)
        
        answerParseView = YYLabel(frame: frame)
        answerParseView.numberOfLines = 0
        addSubview(answerParseView)
        
        makeConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeConstraints() {
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(0)
            make.height.equalTo(23).priority(999)
        }
        
        answerParseView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(nameLabel.snp.bottom).offset(5).priority(999)
            make.bottom.equalTo(-2)
        }
    }
}
