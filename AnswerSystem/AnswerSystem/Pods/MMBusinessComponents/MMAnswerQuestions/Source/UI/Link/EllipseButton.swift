//
//  EllipseButton.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/6.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import MMBaseComponents

typealias ChooseClickActionBlock = ((_ button: EllipseButton) -> Void)

class EllipseButton: UIButton {
    
    var ellipseIsSelected = false
    
    var richTextLabel: YYLabel!
    
    var objectId: String = ""
    //0: left 1:middle 2:right
    var position = 0
    var imageUrl = ""
    
    var richText: RichTextContentModel?
    
    var chooseClickActionBlock: ChooseClickActionBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentMode = .scaleAspectFit
        
        self.layer.cornerRadius = 5
        self.layer.borderColor = UIColor(hexString: "#E5E7E9")?.cgColor
        self.layer.borderWidth = 0.8
        
        richTextLabel = YYLabel()
        richTextLabel.numberOfLines = 0
        richTextLabel.isUserInteractionEnabled = true
        richTextLabel.addRichTextTapGesture { [weak self] (tap) in
            guard let `self` = self else {
                return
            }
            self.chooseClickActionBlock?(self)
        }
        self.addSubview(richTextLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData(richText: RichTextModel?, position: Int) {
        if let richText = richText?.richtext {
            
            self.richText = richText
            self.objectId = richText.objectId
            self.position = position
            self.layer.cornerRadius = 5
            
            let size = CGSize(width: JionLineTextBtnWidth, height: JionLineTextBtnHeight)
            let _ = AnswerSystemManager.shared.richText(richText: richTextLabel, model: richText, answerSystemType: .match)
            
            let fitSize = richTextLabel.sizeThatFits(size)
            
            //self.richTextW = fitSize.width < size.width ? size.width : fitSize.width
            self.richTextW = size.width
            self.richTextH = fitSize.height < size.height ? size.height : fitSize.height
            
            self.snp.remakeConstraints { (make) in
                make.width.equalTo(self.richTextW)
                make.height.equalTo(self.richTextH)
            }
            
            self.frame = CGRect(x: 0, y: 0, width: self.richTextW, height: self.richTextH)
            
            richTextLabel.textAlignment = .center
            
            richTextLabel.snp.remakeConstraints { (make) in
                make.edges.equalTo(0)
            }
        }
    }
    
    func refresh(isSelected: Bool) {
        self.ellipseIsSelected = isSelected
        self.backgroundColor = UIColor.white
        if isSelected {
            //self.backgroundColor = RRTThemeColor.withAlphaComponent(0.2)
            self.layer.borderColor = RTThemeColor.cgColor
        } else {
            //self.backgroundColor = UIColor.white
            self.layer.borderColor = UIColor(hexString: "#E5E7E9")?.cgColor
        }
        
    }
    
}
