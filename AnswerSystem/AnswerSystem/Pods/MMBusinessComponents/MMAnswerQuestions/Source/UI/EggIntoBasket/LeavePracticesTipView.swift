//
//  LeavePracticesTipView.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/11.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

public class LeavePracticesTipView: UIView {
    
    fileprivate var tipIconImageView: UIImageView!
    fileprivate var tipLabel: UILabel!
    
    public var tipContent: String? {
        didSet {
            if let tipContent = tipContent {
                tipLabel.text = "余\(tipContent)"
                if tipContent.len <= 2 {
                    tipIconImageView.snp.remakeConstraints { (make) in
                        make.edges.equalTo(0)
                        make.width.equalTo(45)
                    }
                } else {
                    tipIconImageView.snp.remakeConstraints { (make) in
                        make.edges.equalTo(0)
                        make.width.equalTo(60)
                    }
                }
            }
        }
    }
    
    public var questionsUnfinished: Int = 0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        tipIconImageView = UIImageView()
        tipIconImageView.image = AnswerSystemHelper.shared.imageSource(name: "exercise_leftAnswerQuestions")
        addSubview(tipIconImageView)
        
        tipLabel = UILabel()
        tipLabel.text = "余"
        tipLabel.font = UIFont.systemFont(ofSize: 14)
        tipLabel.textColor = UIColor.white
        addSubview(tipLabel)
        
        makeConstraints()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeConstraints() {
        tipIconImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
            make.width.equalTo(55)
        }
        
        tipLabel.snp.makeConstraints { (make) in
            make.right.top.bottom.equalTo(0)
            make.left.equalTo(10)
        }
    }
    
}
