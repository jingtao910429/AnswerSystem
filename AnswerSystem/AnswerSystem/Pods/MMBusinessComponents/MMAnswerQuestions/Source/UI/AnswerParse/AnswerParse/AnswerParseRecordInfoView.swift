//
//  AnswerParseRecordInfoView.swift
//  MMBusinessComponents
//
//  Created by Mac on 2018/8/24.
//

import UIKit

class AnswerParseRecordInfoView: UIView {
    
    fileprivate var lineView: UIView!
    fileprivate var contentLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        lineView = UIView()
        lineView.backgroundColor = RTSeperateColor
        addSubview(lineView)
        
        contentLabel = UILabel()
        contentLabel.font = RTSmallestFont
        contentLabel.textColor = RTOrangeRed
        addSubview(contentLabel)
        
        makeConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeConstraints() {
        lineView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(0.5)
        }
        
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(lineView.snp.bottom).offset(5)
            make.right.equalTo(-10)
            make.height.equalTo(18).priority(999)
            make.bottom.equalTo(-5)
        }
    }
}

extension AnswerParseRecordInfoView {
    
    func loadData(doNumber: Int, rate: CGFloat) {
        
        let rateInt = Int(rate * 100)
        
        let text = "\(doNumber)人做过该题目；正确率\(rateInt)%"
        let attributeText = NSMutableAttributedString(string: text)
        let textRange1 = NSString(string: text).range(of: "人做过该题目；正确率")
        attributeText.addAttributes([NSAttributedStringKey.foregroundColor : RTTextColor], range: textRange1)
        
        contentLabel.attributedText = attributeText
        
    }
}
