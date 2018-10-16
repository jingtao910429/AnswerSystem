//
//  LinkNode.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/6.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

//连线Node
class LinkNode {
    
    //存储属性
    var storeData: RichTextModel?
    //position: 0, 1, 2
    var positon = 0
    //后继
    weak var next: LinkNode?
    //前驱
    weak var prior: LinkNode?
    //关联PriorLine
    var priorline: CAShapeLayer?
    //关联NextLine
    var nextline: CAShapeLayer?
    //关联节点View
    var nodeView: UIView?
    
}
