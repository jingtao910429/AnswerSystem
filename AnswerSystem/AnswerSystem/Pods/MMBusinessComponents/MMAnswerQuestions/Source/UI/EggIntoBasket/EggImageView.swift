//
//  EggImageView.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/11.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class EggImageView: UIView {
    
    var backView: UIView!
    var shadeView: UIButton!
    var desLabel: UILabel!
    
    var option: RichTextContent? {
        didSet {
            if let option = option {
                desLabel.text = "\(option.txt)"
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isUserInteractionEnabled = true
        
        backView = UIView(frame: frame)
        backView.isUserInteractionEnabled = true
        addSubview(backView)
        
        shadeView = UIButton(frame: frame)
        
        shadeView.setImage(bundleImage(name: "exercise_egg"), for: .normal)
        shadeView.setImage(bundleImage(name: "exercise_egg_sel"), for: .selected)
        shadeView.addTarget(self, action: #selector(selectEggButtonClick), for: .touchUpInside)
        backView.addSubview(shadeView)
        
        desLabel = UILabel()
        desLabel.text = "a"
        desLabel.textAlignment = .center
        desLabel.font = RTLessNormalFont
        desLabel.textColor = RTTextColor
        backView.addSubview(desLabel)
        
        makeConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func selectEggButtonClick() {
        shadeView.isSelected = !shadeView.isSelected
    }
    
    func makeConstraints() {
        
        backView.snp.makeConstraints { (make) in
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.top.equalTo(5)
            make.bottom.equalTo(-5)
        }
        
        shadeView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        desLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
    
}
