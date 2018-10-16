//
//  InputTextFiled.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/6.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class InputTextFiled: UITextField {
    
    var input_box_idx = ""
    var answer_type = ""
    var answer = ""
    var answers: [String] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
