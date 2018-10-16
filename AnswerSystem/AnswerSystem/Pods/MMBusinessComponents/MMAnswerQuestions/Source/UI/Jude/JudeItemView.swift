//
//  JudeItemView.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/11.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class JudeItemView: UIView {
    
    fileprivate var leftBracket: UILabel!
    fileprivate var rightBracket: UILabel!
    fileprivate var trueButton: UIButton!
    fileprivate var falseButton: UIButton!
    
    fileprivate let kBtnWidth = 40.0
    
    var isUserInteracted = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        leftBracket = UILabel()
        leftBracket.isHidden = true
        leftBracket.text = "("
        leftBracket.textColor = RTTextColor
        leftBracket.font = RTBigFont
        addSubview(leftBracket)
        
        rightBracket = UILabel()
        rightBracket.isHidden = true
        rightBracket.text = ")"
        rightBracket.textColor = RTTextColor
        rightBracket.font = RTBigFont
        addSubview(rightBracket)
        
        trueButton = UIButton()
        trueButton.setImage(bundleImage(name: "exercise_icon_right_nor"), for: .normal)
        trueButton.setImage(bundleImage(name: "exercise_icon_right_sel"), for: .selected)
        trueButton.layer.cornerRadius = CGFloat(kBtnWidth * 0.5)
        trueButton.layer.masksToBounds = true
        trueButton.addRichTextTapGesture { [weak self] (tap) in
            guard let `self` = self else { return }
            if self.isUserInteracted {
                self.chooseClick(button: self.trueButton)
            } else {
                AnswerSystemHelper.modifyStatusNotificationPost()
            }
        }
        addSubview(trueButton)
        
        falseButton = UIButton()
        falseButton.setImage(bundleImage(name: "exercise_icon_wrong_nor"), for: .normal)
        falseButton.setImage(bundleImage(name: "exercise_icon_wrong_sel"), for: .selected)
        falseButton.layer.cornerRadius = CGFloat(kBtnWidth * 0.5)
        falseButton.layer.masksToBounds = true
        falseButton.addRichTextTapGesture { [weak self] (tap) in
            guard let `self` = self else { return }
            if self.isUserInteracted {
                self.chooseClick(button: self.falseButton)
            } else {
                AnswerSystemHelper.modifyStatusNotificationPost()
            }
        }
        addSubview(falseButton)
        
        makeConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func makeConstraints() {
        leftBracket.snp.makeConstraints { (make) in
            if leftBracket.isHidden {
                make.left.centerY.equalTo(0).priority(999)
                make.width.equalTo(0)
            } else {
                make.left.centerY.equalTo(5)
                make.left.equalTo(5)
                make.width.equalTo(5)
            }
            make.top.bottom.equalTo(0)
        }
        
        falseButton.snp.makeConstraints { (make) in
            make.left.equalTo(leftBracket.snp.right).offset(6)
            make.top.bottom.equalTo(0)
            make.width.equalTo(kBtnWidth)
        }
        
        trueButton.snp.makeConstraints { (make) in
            make.right.equalTo(rightBracket.snp.left).offset(-6)
            make.top.bottom.equalTo(0)
            make.width.equalTo(kBtnWidth)
        }
        
        rightBracket.snp.makeConstraints { (make) in
            make.centerY.equalTo(0).priority(999)
            if rightBracket.isHidden {
                make.right.equalTo(0)
                make.width.equalTo(0)
            } else {
                make.right.equalTo(-5)
                make.width.equalTo(5)
            }
            make.top.bottom.equalTo(0)
        }
    }
    
    func chooseClick(button: UIButton) {
        
        func changeSelectUI (selButton: UIButton, unSelButton: UIButton) {
            selButton.isSelected = true
            unSelButton.isSelected = false
            
//            selButton.backgroundColor = UIColor.white
//            selButton.layer.borderWidth = 1
//            selButton.layer.borderColor = RTThemeColor.cgColor
//
//            unSelButton.isSelected = false
//            unSelButton.backgroundColor = UIColor.clear
//            unSelButton.layer.borderWidth = 0
        }
        
        button.isSelected = !button.isSelected
        
        if button == trueButton {
            changeSelectUI(selButton: button, unSelButton: falseButton)
        } else {
            changeSelectUI(selButton: button, unSelButton: trueButton)
        }
    }
    
    func loadData(isRight: Int) {
        if isRight == 1 {
            chooseClick(button: trueButton)
        } else if isRight == 0 {
            chooseClick(button: falseButton)
        }
    }
    
    func selectResult() -> Int {
        if trueButton.isSelected {
            return 1
        } else if falseButton.isSelected {
            return 0
        }
        return -1
    }
}
