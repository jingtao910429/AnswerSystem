//
//  ExerciseQuestionsFeedBackView.swift
//  MMStudent
//
//  Created by Mac on 2018/7/31.
//  Copyright © 2018年 RanDian. All rights reserved.
//

import UIKit

public typealias ExerciseQuestionsFeedBackBlock = (() -> Void)

class ExerciseQuestionsFeedBackView: UIView {
    
    fileprivate var questionButton: UIButton!
    fileprivate var underLineView: UIView!
    fileprivate var questionIconImageView: UIImageView!
    
    var exerciseQuestionsFeedBackBlock: ExerciseQuestionsFeedBackBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.clear
        
        self.addRichTextTapGesture { [weak self] (tap) in
            guard let `self` = self else {
                return
            }
            self.exerciseQuestionsFeedBackBlock?()
        }
        
        questionButton = UIButton()
        questionButton.setTitle("问题反馈", for: .normal)
        questionButton.setTitleColor(RTLightGrayColor, for: .normal)
        questionButton.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        questionButton.isUserInteractionEnabled = false
        addSubview(questionButton)
        
        underLineView = UIView()
        underLineView.backgroundColor = RTLightGrayColor
        addSubview(underLineView)
        
        questionIconImageView = UIImageView()
        questionIconImageView.image = #imageLiteral(resourceName: "discover_edit")
        addSubview(questionIconImageView)
        
        makeConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeConstraints() {
        
        questionIconImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(12)
            make.centerY.equalTo(self)
            make.right.equalTo(-10)
        }
        
        questionButton.snp.makeConstraints { (make) in
            make.right.equalTo(questionIconImageView.snp.left).offset(-4)
            make.top.bottom.equalTo(0)
            make.height.equalTo(16).priority(999)
        }
        
        underLineView.snp.makeConstraints { (make) in
            make.left.equalTo(questionButton.snp.left)
            make.right.equalTo(questionButton.snp.right)
            make.bottom.equalTo(0)
            make.height.equalTo(0.5)
        }
        
    }
    
}
