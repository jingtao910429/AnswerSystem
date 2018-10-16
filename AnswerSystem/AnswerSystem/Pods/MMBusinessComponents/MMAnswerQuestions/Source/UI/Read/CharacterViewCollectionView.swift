//
//  CharacterViewCollectionViewCell.swift
//  Pods
//
//  Created by Mac on 2018/4/24.
//

import UIKit

class CharacterViewCollectionViewCell: UICollectionViewCell {
    
    fileprivate var pinyinLabel: UILabel!
    fileprivate var characterLabel: UILabel!
    
    var characterIsShow: Bool? {
        didSet {
            if let characterIsShow = characterIsShow {
                pinyinLabel.isHidden = !characterIsShow
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        pinyinLabel = UILabel()
        pinyinLabel.textColor = RTTextColor
        pinyinLabel.textAlignment = .center
        pinyinLabel.font = RTSmallLessFont
        self.contentView.addSubview(pinyinLabel)
        
        characterLabel = UILabel()
        characterLabel.textColor = RTTextColor
        characterLabel.textAlignment = .center
        characterLabel.font = RTBiggestFont
        self.contentView.addSubview(characterLabel)
        
        makeConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeConstraints() {
        pinyinLabel.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(self.contentView)
            make.height.equalTo(30)
        }
        characterLabel.snp.makeConstraints { (make) in
            make.top.equalTo(pinyinLabel.snp.bottom)
            make.left.bottom.right.equalTo(self.contentView)
            make.height.equalTo(30)
        }
    }
    
    func loadData(pinyin: String, character: String, count: Int) {
        pinyinLabel.text = pinyin
        characterLabel.text = character
        if count > 0 && count < 5 {
            characterLabel.font = UIFont.systemFont(ofSize: 60)
            pinyinLabel.font = UIFont.systemFont(ofSize: 18)
            pinyinLabel.snp.remakeConstraints { (make) in
                make.left.top.right.equalTo(self.contentView)
                if characterIsShow! {
                    make.height.equalTo(30)
                } else {
                    make.height.equalTo(1)
                }
            }
            characterLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(pinyinLabel.snp.bottom)
                make.left.bottom.right.equalTo(self.contentView)
                make.height.equalTo(40)
            }
        }
    }
    
}
