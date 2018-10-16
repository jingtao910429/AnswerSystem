//
//  AnswerParseKeyKnowleadgeView.swift
//  MMBusinessComponents
//
//  Created by Mac on 2018/8/24.
//

import UIKit
import TagListView

public typealias KeyKnowleadgeTapBlock = ((_ index: Int, _ tagView: TagView) -> Void)

//知识要点
class AnswerParseKeyKnowleadgeView: UIView {
    
    fileprivate var nameLabel: UILabel!
    fileprivate var tagListView: TagListView!
    fileprivate var tapBlock: KeyKnowleadgeTapBlock?
    fileprivate var topics: [AnswerParseKnowleadgeContentModel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        nameLabel = UILabel()
        nameLabel.text = "知识要点："
        nameLabel.font = RTBoldNormalFont
        nameLabel.textColor = RTTextColor
        addSubview(nameLabel)
        
        tagListView = TagListView(frame: CGRect(x: 0, y: 0, width: frame.width - 30, height: frame.height))
        tagListView.borderWidth = 0
        tagListView.tagBackgroundColor = RTBackGroundColor
        tagListView.tagSelectedBackgroundColor = RTBackGroundColor
        tagListView.textFont = RTSmallFont
        tagListView.textColor = RTTextColor
        tagListView.cornerRadius = 10
        tagListView.enableRemoveButton = false
        tagListView.tagLineBreakMode = .byTruncatingTail
        tagListView.paddingY = 8
        tagListView.marginY = 5
        tagListView.marginX = 5
        addSubview(tagListView)
        
        makeConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeConstraints() {
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(0)
            make.height.equalTo(23).priority(999)
        }
        
        tagListView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(nameLabel.snp.bottom).offset(5).priority(999)
            make.bottom.equalTo(-10)
        }
    }
}

extension AnswerParseKeyKnowleadgeView {
    
    func loadData(topics: [AnswerParseKnowleadgeContentModel], tapBlock: KeyKnowleadgeTapBlock?) {
        
        if topics.count == 0 {
            return
        }
        
        self.topics = topics
        tagListView.removeAllTags()
        
        var titles: [String] = []
        
        for knowleadgeTopic in topics {
            titles.append(knowleadgeTopic.content)
        }
        
        self.tapBlock = tapBlock
        for (index, title) in titles.enumerated() {
            tagListView.addTag(title).onTap = { [weak self] (tagView) in
                guard let `self` = self else {
                    return
                }
                self.tapBlock?(index, tagView)
            }
        }
    }
}
