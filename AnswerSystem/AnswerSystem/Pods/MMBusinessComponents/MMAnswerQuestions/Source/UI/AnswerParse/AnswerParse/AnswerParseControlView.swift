//
//  AnswerParseControlView.swift
//  MMBusinessComponents
//
//  Created by Mac on 2018/8/24.
//

import UIKit

typealias AnswerParseControlBlock = ((_ status: Bool) -> Void)
//答案解析控制视图
class AnswerParseControlView: UIView {
    
    fileprivate var lineView: UIView!
    fileprivate var tipView: UIView!
    fileprivate var tipButton: UIButton!
    fileprivate var tipArrowImageView: UIImageView!
    fileprivate var tipLineView: UIView!
    fileprivate var expendStatus: Bool = false
    
    var answerParseControlBlock: AnswerParseControlBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        lineView = UIView()
        lineView.backgroundColor = RTThemeColor
        addSubview(lineView)
        
        tipView = UIView()
        tipView.backgroundColor = UIColor.white
        addSubview(tipView)
        
        tipButton = UIButton()
        tipButton.setTitle("点击打开答案解析", for: .normal)
        tipButton.setTitleColor(RTLightGrayColor, for: .normal)
        tipButton.titleLabel?.textAlignment = .center
        tipButton.titleLabel?.font = RTSmallFont
        tipView.addSubview(tipButton)
        
        tipButton.addRichTextTapGesture { [weak self] (tap) in
            guard let `self` = self else {
                return
            }
            self.tipAction()
        }
        
        tipArrowImageView = UIImageView()
        tipArrowImageView.image = AnswerSystemHelper.shared.imageSource(name: "answerParseTipArrowUp")
        tipArrowImageView.contentMode = .scaleAspectFit
        tipView.addSubview(tipArrowImageView)
        
        tipLineView = UIView()
        tipLineView.backgroundColor = RTLightGrayColor
        tipView.addSubview(tipLineView)
        
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
        
        tipView.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom)
            make.centerX.equalTo(self)
            make.bottom.equalTo(0)
        }
        
        tipButton.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(0)
        }
        
        tipArrowImageView.snp.makeConstraints { (make) in
            make.right.top.bottom.equalTo(0)
            make.left.equalTo(tipButton.snp.right).offset(5)
        }
        
        tipLineView.snp.makeConstraints { (make) in
            make.bottom.equalTo(-3)
            make.left.right.equalTo(0)
            make.height.equalTo(0.5)
        }
    }
    
    func tipAction() {
        
        self.expendStatus = !self.expendStatus
        
        if self.expendStatus {
            tipButton.setTitle("点击收起答案解析", for: .normal)
            self.lineView.backgroundColor = RTSeperateColor
        } else {
            tipButton.setTitle("点击打开答案解析", for: .normal)
            self.lineView.backgroundColor = RTThemeColor
        }
        
        let image = self.expendStatus ? "answerParseTipArrowDown" : "answerParseTipArrowUp"
        self.tipArrowImageView.image = AnswerSystemHelper.shared.imageSource(name: image)
        self.answerParseControlBlock?(self.expendStatus)
    }
    
    func initData() {
        expendStatus = false
        let image = self.expendStatus ? "answerParseTipArrowDown" : "answerParseTipArrowUp"
        self.tipArrowImageView.image = AnswerSystemHelper.shared.imageSource(name: image)
    }
    
}
