//
//  MatchLineView.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/9.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import MMToolHelper

class MatchLineView: UIView {
    
    fileprivate var helper: AnswerSystemLineHelper = AnswerSystemLineHelper()
    //所有节点信息
    fileprivate var options: [LinkNode] = []
    fileprivate var lOptions: [EllipseButton] = []
    fileprivate var mOptions: [EllipseButton] = []
    fileprivate var rOptions: [EllipseButton] = []
    fileprivate var optionHeights: [CGFloat] = [CGFloat(0), CGFloat(0), CGFloat(0)]
    
    fileprivate var prior: LinkNode?
    
    fileprivate var backView: UIView!
    
    fileprivate var sortLeftAnswers: [RichTextModel] = []
    fileprivate var sortMiddleAnswers: [RichTextModel] = []
    fileprivate var sortRightAnswers: [RichTextModel] = []
    
    fileprivate var exerciseStyle: ExerciseStyle = .MatchLineTwoOption
    
    var isEdit = false
    
    var matchAnswers: [LinkOptionModel]? {
        didSet {
            if let matchAnswers = matchAnswers {
                if matchAnswers.count > 0 {
                    
                    sortLeftAnswers.removeAll()
                    sortMiddleAnswers.removeAll()
                    sortRightAnswers.removeAll()
                    
                    for item in matchAnswers {
                        
                        if let left = item.left {
                            sortLeftAnswers.append(left)
                        }
                        
                        if let middle = item.middle {
                            sortMiddleAnswers.append(middle)
                        }
                        
                        if let right = item.right {
                            sortRightAnswers.append(right)
                        }
                    }
                    
                }
                
            }
        }
    }
    
    var answers: [UserAnswerItemModel]? {
        didSet {
            //答案填充
            if let _ = answers {
                
                let deadlineTime = DispatchTime.now() + 0.2
                DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                    if self.sortMiddleAnswers.count != 0 {
                        self.matchLine(isLeft: true, isMiddle: true, isRight: false)
                        self.matchLine(isLeft: false, isMiddle: true, isRight: true)
                    } else {
                        self.matchLine(isLeft: true, isMiddle: false, isRight: true)
                    }
                })
            }
        }
    }
    
    var matchLineTopic: TopicModel? {
        didSet {
            if let topic = matchLineTopic {
                if topic.matchAnswers.count > 0 {
                    if let type = ExerciseStyle(rawValue: topic.type) {
                        self.exerciseStyle = type
                        if type == .MatchLineTwoOption {
                            JionLineTextBtnWidth = (frame.width - 70) / 3.0
                        } else {
                            JionLineTextBtnWidth = (frame.width - 70) / 5.0
                        }
                    }
                    lOptions.removeAll()
                    mOptions.removeAll()
                    rOptions.removeAll()
                    for linkOption in topic.matchAnswers {
                        
                        appendOptions(richText: linkOption.left, nodes: &options, options: &lOptions, position: 0)
                        
                        appendOptions(richText: linkOption.middle, nodes: &options, options: &mOptions, position: 1)
                        
                        appendOptions(richText: linkOption.right, nodes: &options, options: &rOptions, position: 2)
                    }
                    //lOptions = lOptions.randamArray()
                    
                    mOptions = mOptions.randamArray()
                    rOptions = rOptions.randamArray()
                    
                    distributeViews(options: lOptions, position: 0)
                    distributeViews(options: mOptions, position: 1)
                    distributeViews(options: rOptions, position: 2)
                    
                }
            }
        }
    }
    
    public func fetchAnswers() -> [RichParameterType] {
        
        var userAnswers: [RichParameterType] = []
        
        for (index, option) in lOptions.enumerated() {
            
            var leftId = ""
            var middleId = ""
            var rightId = ""
            
            var parameters: RichParameterType = [:]
            let node = searchNode(objectId: option.objectId)
            if let ellipseButton = node?.nodeView as? EllipseButton {
                leftId = ellipseButton.objectId
                if let next = node?.next {
                    if let nextEllipseButton = next.nodeView as? EllipseButton {
                        if mOptions.count != 0 {
                            middleId = nextEllipseButton.objectId
                            if let last = next.next {
                                if let lastEllipseButton = last.nodeView as? EllipseButton {
                                    rightId = lastEllipseButton.objectId
                                }
                            }
                        } else {
                            rightId = nextEllipseButton.objectId
                        }
                    }
                }
            }
            parameters["left"] = leftId
            parameters["middle"] = middleId
            parameters["right"] = rightId
            parameters["index"] = index
            parameters["is_right"] = true
            parameters["scores"] = 0
            
            var compareLeftId = ""
            var compareMiddleId = ""
            var compareRightId = ""
            
            for (formateIndex, _) in sortLeftAnswers.enumerated() {
                compareLeftId = sortLeftAnswers[formateIndex].richtext?.objectId ?? ""
                
                if leftId == compareLeftId {
                    
                    if sortMiddleAnswers.count > formateIndex {
                        compareMiddleId = sortMiddleAnswers[formateIndex].richtext?.objectId ?? ""
                    }
                    if sortRightAnswers.count > formateIndex {
                        compareRightId = sortRightAnswers[formateIndex].richtext?.objectId ?? ""
                    }
                    
                    if leftId == compareLeftId && middleId == compareMiddleId && rightId == compareRightId {
                        parameters["is_right"] = true
                    } else {
                        parameters["is_right"] = false
                    }
                    break
                }
            }
            
            userAnswers.append(parameters)
        }
        
        if let answers = self.answers, answers.count != 0 {
            //上次用户答案不为空
            //对比答案
            for (_, item) in answers.enumerated() {
                for (_, paras) in userAnswers.enumerated() {
                    if mOptions.count == 0 {
                        if let left = paras["left"] as? String, let right = paras["right"] as? String {
                            if left == item.left {
                                //找到对应选项
                                if right != item.right {
                                    self.isEdit = true
                                    break
                                }
                            }
                        }
                    } else {
                        if let left = paras["left"] as? String, let middle = paras["middle"] as? String, let right = paras["right"] as? String {
                            if left == item.left {
                                if right != item.right
                                    || middle != item.middle {
                                    self.isEdit = true
                                    break
                                }
                            }
                        }
                    }
                }
            }
        } else {
            //用户答案不存在
            for (_, paras) in userAnswers.enumerated() {
                if let left = paras["left"] as? String, let right = paras["right"] as? String, let middle = paras["middle"] as? String {
                    if self.sortMiddleAnswers.count == 0 {
                        //二连线
                        if left != "" && right != "" {
                            //编辑过
                            self.isEdit = true
                            break
                        }
                    } else {
                        //三连线
                        if left != "" && right != "" && middle != "" {
                            //编辑过
                            self.isEdit = true
                            break
                        }
                    }
                    
                }
            }
        }
        return userAnswers
    }
    
    var isUserInteracted = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width - 40, height: frame.height))
        addSubview(backView)
        
        backView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData(topic: TopicModel?, matchAnswers: [LinkOptionModel]? = []) {
        self.matchLineTopic = topic
        self.matchAnswers = matchAnswers
    }
    
    func distributeViews(options: [EllipseButton] = [], position: Int) {
        guard options.count != 0 else {
            return
        }
        
        var maxValue = CGFloat(0)
        var maxIndex = 0
        for (index, value) in optionHeights.enumerated() {
            if value > maxValue {
                maxValue = value
                maxIndex = index
            }
        }
        
        options.snp.distributeViewsAlong(axisType: .vertical, fixedSpacing: JionLineTextBtnVerSpace, leadSpacing: 0, tailSpacing: 0, confirmBottom: (position == maxIndex ? true : false))
        options.snp.makeConstraints({ (make) in
            if position == 0 {
                make.left.equalTo(backView.snp.left)
            } else if position == 1 {
                make.centerX.equalTo(backView.snp.centerX)
            } else if position == 2 {
                make.right.equalTo(backView.snp.right)
            }
        })
        
    }
    
    func searchNode(objectId: String?) -> LinkNode? {
        guard let objectId = objectId else {
            return nil
        }
        for node in options {
            let nodeObjectId = node.storeData?.richtext?.objectId
            if nodeObjectId == objectId {
                return node
            }
        }
        return nil
    }
    
    func appendOptions(richText: RichTextModel?, nodes: inout [LinkNode], options: inout  [EllipseButton], position: Int) {
        if let richText = richText {
            let node = LinkNode()
            node.storeData = richText
            nodes.append(node)
            
            let ellipseBtn = EllipseButton(frame: CGRect(x: 0, y: 0, width: JionLineTextBtnWidth, height: JionLineTextBtnHeight))
            ellipseBtn.objectId = richText.richtext?.objectId ?? ""
            ellipseBtn.loadData(richText: richText, position: position)
            ellipseBtn.chooseClickActionBlock = { [weak self] (clickButton) in
                guard let `self` = self else {
                    return
                }
                self.chooseClickAction(clickButton: clickButton)
            }
            
            optionHeights[position] += ellipseBtn.height
            
            node.positon = position
            node.nodeView = ellipseBtn
            backView.addSubview(ellipseBtn)
            options.append(ellipseBtn)
        }
    }
    
    @objc func chooseClickAction(clickButton: EllipseButton) {
        
        if !isUserInteracted {
            AnswerSystemHelper.modifyStatusNotificationPost()
            return
        }
        
        for node in options {
            let nodeObjectId = node.storeData?.richtext?.objectId
            let clickObjectId = clickButton.objectId
            if nodeObjectId == clickObjectId {
                
                func priorNone(node: LinkNode) {
                    
                    if node.positon == 1 {
                        if node.nextline != nil && node.priorline != nil {
                            delete(node: node, prior: false)
                            delete(node: node, prior: true)
                        } else {
                            if let prior = prior {
                                if prior.storeData?.richtext?.objectId == node.storeData?.richtext?.objectId {
                                    //删除
                                    delete(node: node, prior: false)
                                    delete(node: node, prior: true)
                                }
                            }
                        }
                    } else {
                        delete(node: node, prior: false)
                        delete(node: node, prior: true)
                    }
                    
                    nodeStatus(node: prior, isSelected: false)
                    nodeStatus(node: node, isSelected: true)
                    
                    prior = nil
                    prior = node
                }
                
                //查找相关node
                if prior == nil {
                    //首次点击Node节点
                    priorNone(node: node)
                    continue
                }
                
                if self.exerciseStyle == .MatchLineThreeOption {
                    
                    //三连线跨行
                    if let priorPostion = prior?.positon {
                        if abs(priorPostion - node.positon) > 1 {
                            priorNone(node: node)
                            return
                        }
                    }
                    
                }
                
                if node.positon == prior?.positon {
                    //同一组
                    priorNone(node: node)
                    return
                }
                
                var priorLinkNode: LinkNode?
                if node.positon != 1 && prior?.positon != 1 {
                    
                    if let prior = prior, prior.positon > node.positon {
                        delete(node: node, prior: false)
                        delete(node: prior, prior: true)
                    } else {
                        delete(node: node, prior: true)
                        delete(node: prior, prior: false)
                    }
                    
                    nodeStatus(node: prior, isSelected: false)
                    nodeStatus(node: node, isSelected: false)
                    
                } else {
                    //如果当前点击的是中间选项，则删除前驱后继
                    
                    if node.positon == 1 {
                        
                        priorLinkNode = middleNodeStatus(node: node)
                        
                        if node.nextline != nil && node.priorline != nil {
                            nodeStatus(node: node, isSelected: false)
                        } else {
                            if let button = node.nodeView as? EllipseButton, button.ellipseIsSelected {
                                if node.nextline != nil || node.priorline != nil {
                                    
                                } else {
                                    nodeStatus(node: prior, isSelected: false)
                                }
                                nodeStatus(node: node, isSelected: false)
                            } else {
                                //选中
                                nodeStatus(node: node, isSelected: true)
                                nodeStatus(node: prior, isSelected: false)
                            }
                        }
                        
                    } else if prior?.positon == 1 {
                        
                        if node.positon == 2 {
                            //删除原有后继
                            if let nodePrior = node.prior, let tPrior = prior, nodePrior.storeData?.richtext?.objectId == tPrior.storeData?.richtext?.objectId {
                                //右面与中间已经有连线
                                delete(node: node, prior: true)
                                nodeStatus(node: node, isSelected: true)
                                nodeStatus(node: prior, isSelected: false)
                                prior = node
                                return
                            }
                        }
                        
                        if node.positon == 0 {
                            if let nodePrior = node.next, let tPrior = prior, nodePrior.storeData?.richtext?.objectId == tPrior.storeData?.richtext?.objectId {
                                //右面与中间已经有连线
                                delete(node: node, prior: false)
                                nodeStatus(node: node, isSelected: true)
                                nodeStatus(node: prior, isSelected: false)
                                prior = node
                                return
                            }
                        }
                        
                        delete(node: node, prior: false)
                        delete(node: node, prior: true)
                        
                        if node.positon == 0 {
                            //删除原有前驱
                            delete(node: prior, prior: true)
                        }
                        
                        if node.positon == 2 {
                            //删除原有后继
                            delete(node: prior, prior: false)
                        }
                    }
                }
                
                //划线
                let shapeLayer = helper.addLine(left: prior?.nodeView, right: node.nodeView)
                
                if let layer = shapeLayer {
                    
                    self.layer.addSublayer(layer)
                    if let prior = prior, prior.positon > node.positon {
                        node.next = prior
                        prior.prior = node
                        node.nextline = layer
                        prior.priorline = layer
                    } else {
                        node.prior = prior
                        prior?.next = node
                        node.priorline = layer
                        prior?.nextline = layer
                    }
                }
                
                if node.positon != 1 && prior?.positon != 1 {
                    prior = nil
                } else {
                    if prior?.positon == 1 && node.positon != 1 {
                        if prior?.nextline != nil && prior?.priorline != nil {
                            nodeStatus(node: prior, isSelected: false)
                            prior = nil
                        }
                        nodeStatus(node: node, isSelected: false)
                    } else {
                        prior = priorLinkNode
                        if node.positon == 1 {
                            if node.nextline != nil && node.priorline != nil {
                                nodeStatus(node: node, isSelected: false)
                                prior = nil
                            }
                        }
                    }
                }
                
                break
            }
        }
    }
    
    fileprivate func nodeStatus(node: LinkNode?, isSelected: Bool) {
        if let nodeView = node?.nodeView, let btn = nodeView as? EllipseButton {
            btn.refresh(isSelected: isSelected)
        }
    }
    
    fileprivate func middleNodeStatus(node: LinkNode?) -> LinkNode? {
        guard let node = node else {
            return nil
        }
        
        var priorLinkNode: LinkNode? = node
        
        var isDeleteLine = false
        if node.nextline != nil && node.priorline != nil {
            if prior?.positon == 0 {
                isDeleteLine = false
                delete(node: node, prior: true)
            } else if prior?.positon == 2 {
                isDeleteLine = false
                delete(node: node, prior: false)
            } else {
                isDeleteLine = true
            }
        } else {
            if let button = node.nodeView as? EllipseButton, button.ellipseIsSelected {
                //已选中状态
                if node.nextline != nil || node.priorline != nil {
                    //取消并删除连线
                    isDeleteLine = true
                    priorLinkNode = nil
                }
            } else {
                //未被选中
                if prior?.positon == 0 {
                    delete(node: node, prior: true)
                }
                
                if prior?.positon == 2 {
                    delete(node: node, prior: false)
                }
            }
        }
        if isDeleteLine {
            delete(node: node, prior: true)
            delete(node: node, prior: false)
        }
        return priorLinkNode
    }
    
    @objc func doubleClickButton(doubleClickBtn: EllipseButton) {
        //双击预览图片
        if doubleClickBtn.imageUrl == "" {
            return
        }
        NotificationCenter.default.post(name: MMAnswerSystemPhotoBrowserNotification, object: doubleClickBtn.imageUrl)
    }
    
}

extension MatchLineView {
    
    func delete(node: LinkNode?, prior: Bool) {
        if prior {
            
            if let line = node?.priorline {
                helper.remove(line: line)
                node?.priorline = nil
            }
            
            if let line = node?.prior?.nextline {
                helper.remove(line: line)
                node?.prior?.nextline = nil
            }
            
            node?.prior?.next = nil
            node?.prior = nil
            
        } else {
            
            if let line = node?.nextline {
                print("line = \(line)")
                helper.remove(line: line)
                node?.nextline = nil
            }
            
            if let line = node?.next?.priorline {
                helper.remove(line: line)
                node?.next?.priorline = nil
            }
            node?.next?.prior = nil
            node?.next = nil
        }
    }
    
    func matchLine(isLeft: Bool, isMiddle: Bool, isRight: Bool) {
        
        if let answers = answers {
            for (_, answer) in answers.enumerated() {
                var leftNode: LinkNode?
                var rightNode: LinkNode?
                if isLeft && isRight {
                    leftNode = searchNode(objectId: answer.left)
                    rightNode = searchNode(objectId: answer.right)
                } else if isRight && isMiddle {
                    leftNode = searchNode(objectId: answer.middle)
                    rightNode = searchNode(objectId: answer.right)
                } else if isLeft && isMiddle {
                    leftNode = searchNode(objectId: answer.left)
                    rightNode = searchNode(objectId: answer.middle)
                }
                
                if let lNode = leftNode, let rNode = rightNode {
                    if mOptions.count != 0 && abs(lNode.positon - rNode.positon) == 2 {
                        continue
                    }
                    //连线
                    if rNode.prior != nil {
                        continue
                    }
                    if lNode.next != nil {
                        break
                    }
                    lNode.next = rNode
                    rNode.prior = lNode
                    if let layer = helper.addLine(left: lNode.nodeView, right: rNode.nodeView) {
                        self.layer.addSublayer(layer)
                        lNode.nextline = layer
                        rNode.priorline = layer
                    }
                }
                
            }
        }
    }
}

extension MatchLineView {
    override func layoutSubviews() {
        if sortLeftAnswers.count != 0 {
            
            for node in options {
                if let priorLine = node.priorline {
                    priorLine.removeFromSuperlayer()
                    if let prior = node.prior {
                        if let layer = helper.addLine(left: prior.nodeView, right: node.nodeView) {
                            node.priorline = layer
                            self.layer.addSublayer(layer)
                        }
                    }
                }
                
                if let nextLine = node.nextline {
                    nextLine.removeFromSuperlayer()
                    if let next = node.next {
                        if let layer = helper.addLine(left: next.nodeView, right: node.nodeView) {
                            node.nextline = layer
                            self.layer.addSublayer(layer)
                        }
                    }
                }
            }
            
        }
        
    }
}

