//
//  ReadView.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/9.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import YYText
import MMBaseComponents

class ReadView: QuestionBaseView {
    
    fileprivate var charactorSize = CGFloat(65)
    fileprivate var readMaxHeight = CGFloat(200)
    
    fileprivate var iFlyManager = IFlyManager()
    fileprivate var characterIsShow = true
    fileprivate var isRight = false
    
    var panelView: UIView!
    var panelShadowView: UIView!
    var contentLabel: YYLabel!
    
    var functionView: UIView!
    var soundButton: UIButton!
    var showButton: UIButton!
    var readButton: UIButton!
    var readImageView: UIImageView!
    
    lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
        layout.minimumLineSpacing = CGFloat.leastNormalMagnitude
        layout.minimumInteritemSpacing = CGFloat.leastNormalMagnitude
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: panelView.width - baseSpace, height: 150), collectionViewLayout: self.layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(CharacterViewCollectionViewCell.self, forCellWithReuseIdentifier: "CharacterViewCollectionViewCell")
        return collectionView
    }()
    
    fileprivate var pinyinArray: [String] = []
    fileprivate var charcterArray: [String] = []
    
    var style: ExerciseStyle?
    
    var readTopic: TopicModel? {
        didSet {
            if let topic = readTopic {
                self.topic = topic
                self.makeConstraints()
                
                if let chars = topic.words.first?.chars {
                    pinyinArray.removeAll()
                    charcterArray.removeAll()
                    for item in chars {
                        if let key = item.keys.first {
                            charcterArray.append(key)
                        }
                        if let value = item.values.first {
                            pinyinArray.append(value)
                        }
                    }
                    
                    let lineCount = Int((panelView.width - baseSpace) / charactorSize) + 1
                    charactorSize = panelView.width / CGFloat(lineCount)
                    //type == 13 拼音
                    //type == 8 汉字
                    if (topic.type == 13
                        && self.charcterArray.count > 0
                        && self.charcterArray.count < 3) || (topic.type == 8
                            && self.charcterArray.count > 0
                            && self.charcterArray.count < 5) {
                        self.layout.itemSize = CGSize(width: charactorSize, height: charactorSize + 40)
                    } else {
                        self.layout.itemSize = CGSize(width: charactorSize, height: charactorSize)
                    }
                    
                    self.collectionView.collectionViewLayout = self.layout
                    self.collectionView.reloadData()
                    
                    let height = self.collectionView.collectionViewLayout.collectionViewContentSize.height
                    
                    if CGFloat(self.charcterArray.count + 1) * (charactorSize) < panelView.width - 60 {
                        
                        panelShadowView.snp.remakeConstraints { (make) in
                            make.top.equalTo(self.baseRichTextView.snp.bottom)
                            make.centerX.equalTo(self.questionScrollView)
                            make.width.equalTo(self.questionScrollView.width - 20)
                            make.height.equalTo(readMaxHeight)
                        }
                        
                        collectionView.snp.remakeConstraints({ (make) in
                            make.centerX.centerY.equalTo(panelShadowView)
                            make.width.equalTo(CGFloat(self.charcterArray.count) * (charactorSize + 10) - 10)
                            make.height.equalTo(charactorSize + 40)
                        })
                        
                    } else {
                        
                        collectionView.contentSize = CGSize(width: panelView.width, height: height)
                        panelShadowView.snp.remakeConstraints { (make) in
                            make.top.equalTo(baseRichTextView.snp.bottom)
                            make.centerX.equalTo(self.questionScrollView)
                            make.width.equalTo(self.questionScrollView.width - 20)
                            make.height.equalTo(height < readMaxHeight ? readMaxHeight : height)
                        }
                        
                        if height < readMaxHeight {
                            collectionView.snp.remakeConstraints({ (make) in
                                make.top.equalTo(10)
                                make.left.right.bottom.equalTo(0)
                                make.height.equalTo(readMaxHeight)
                            })
                        } else {
                            collectionView.snp.remakeConstraints({ (make) in
                                make.edges.equalTo(0)
                                make.height.equalTo(height)
                            })
                        }
                        
                    }
                    
                    functionView.snp.remakeConstraints { (make) in
                        make.left.right.equalTo(self.panelShadowView)
                        make.top.equalTo(self.panelShadowView.snp.bottom).offset(10)
                        make.height.equalTo(120)
                        make.bottom.equalTo(-10)
                    }
                    
                }
            }
        }
    }
    
    override func fetchAnswers() -> [RichParameterType] {
        var userAnswers: [RichParameterType] = []
        if let words = topic?.words  {
            for word in words {
                var parameters: RichParameterType = [:]
                parameters["scores"] = 0
                parameters["is_right"] = isRight
                parameters["index"] = word.index
                parameters["answer"] = (isRight ? "1" : "0")
                userAnswers.append(parameters)
            }
        }
        return userAnswers
    }
    
    func loadData(readTopic: TopicModel?, style: ExerciseStyle) {
        self.style = style
        self.readTopic = readTopic
        
        if style == .PinyinRead {
            showButton.isHidden = true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        iFlyManager.delegate = self
        
        panelView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: readMaxHeight))
        panelView.backgroundColor = UIColor(hexString: "#F7FDFE")!
        panelShadowView = panelView.richTextCornerRadiusShadow(cornerRadius: 5)
        questionScrollView.addSubview(panelShadowView)
        
        panelView.addSubview(self.collectionView)
        
        functionView = UIView()
        functionView.tag = ReadLastViewTag
        questionScrollView.addSubview(functionView)

        soundButton = UIButton()
        soundButton.contentMode = .scaleAspectFit
        soundButton.setImage(bundleImage(name: "exercise_horn"), for: .normal)
        soundButton.addTarget(self, action: #selector(soundButtonClick(_ :)), for: .touchUpInside)
        functionView.addSubview(soundButton)

        showButton = UIButton()
        showButton.contentMode = .scaleAspectFit
        showButton.setImage(bundleImage(name: "exercise_eye_show"), for: .normal)
        showButton.setImage(bundleImage(name: "exercise_eye_hide"), for: .selected)
        showButton.addTarget(self, action: #selector(showButtonClick(_ :)), for: .touchUpInside)
        functionView.addSubview(showButton)
        
        readImageView = UIImageView()
        readImageView.contentMode = .scaleAspectFit
        readImageView.center = functionView.center
        functionView.addSubview(readImageView)
        
        var images: [UIImage] = []
        for i in 0..<5 {
            if let image = bundleImage(name: "exercise_read\(i).png") {
                images.append(image)
            }
        }
        
        readImageView.animationImages = images
        readImageView.animationDuration = 1
        readImageView.animationRepeatCount = Int.max
        
        readButton = UIButton()
        readButton.setImage(bundleImage(name: "exercise_mic_nor"), for: .normal)
        readButton.contentMode = .scaleAspectFit
        readButton.addTarget(self, action: #selector(readButtonClick(_ :)), for: .touchUpInside)
        functionView.addSubview(readButton)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func makeConstraints() {
        
        panelShadowView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.baseRichTextView.snp.bottom)
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.height.equalTo(readMaxHeight)
        }
        
        collectionView.snp.remakeConstraints { (make) in
            make.edges.equalTo(panelView)
        }
        
        functionView.snp.remakeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(self.panelShadowView.snp.bottom).offset(10)
            make.height.equalTo(120)
            make.bottom.equalTo(-10)
        }

        showButton.snp.remakeConstraints { (make) in
            make.left.equalTo(10)
            make.centerY.equalTo(functionView)
            make.right.equalTo(readButton.snp.left).offset(-30)
        }

        soundButton.snp.remakeConstraints { (make) in
            make.left.equalTo(readButton.snp.right).offset(30)
            make.centerY.equalTo(showButton.snp.centerY)
            make.right.equalTo(-10)
        }

        readButton.snp.remakeConstraints { (make) in
            make.centerX.centerY.equalTo(functionView)
            make.height.width.equalTo(70)
        }
        
        readImageView.snp.remakeConstraints { (make) in
            make.centerX.equalTo(functionView)
            make.centerY.equalTo(functionView).offset(6)
            make.height.equalTo(90)
            make.width.equalTo(150)
        }
        
    }
    
    deinit {
    }
    
}

extension ReadView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.charcterArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let charactor = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterViewCollectionViewCell", for: indexPath) as? CharacterViewCollectionViewCell
        if let style = self.style, style == .PinyinRead {
            charactor?.characterIsShow = false
            charactor?.loadData(pinyin: self.charcterArray[indexPath.row], character: self.pinyinArray[indexPath.row], count: self.charcterArray.count)
        } else {
            charactor?.characterIsShow = characterIsShow
            charactor?.loadData(pinyin: self.pinyinArray[indexPath.row], character: self.charcterArray[indexPath.row], count: self.charcterArray.count)
        }
        
        return charactor!
    }
    
    
}

extension ReadView: IFlyManagerDelegate {
    
    func onError(_ error: IFlySpeechError!) {
        readImageView.stopAnimating()
        iFlyManager.cancel()
    }
    
    func onResult(_ resultArray: [Any]!, isLast: Bool) {
        readImageView.stopAnimating()
        if resultArray == nil {
            return
        }
        var result = ""
        for item in resultArray {
            if let message = item as? RichParameterType, let key = message.keys.first {
                result.append(key)
            }
        }
        result = result.trimmingCharacters(in: .whitespaces)
        let answer = self.charcterArray.joined(separator: "")
        
        isRight = false
        if result != "", answer == result {
            isRight = true
        }
        iFlyManager.cancel()
        self.questionContainerDelegate?.readResult?(isRight: isRight)
    }
    
    func onVolumeChanged(_ volume: Int32) {
        
    }
    
}

extension ReadView {
    
    @objc func soundButtonClick(_ button: UIButton) {
        if !isUserInteracted {
            AnswerSystemHelper.modifyStatusNotificationPost()
            return
        }
        let sentence = self.charcterArray.joined(separator: "")
        iFlyManager.startSpeech(sentence, language: "zh-CN")
    }
    
    @objc func showButtonClick(_ button: UIButton) {
        if !isUserInteracted {
            AnswerSystemHelper.modifyStatusNotificationPost()
            return
        }
        button.isSelected = !button.isSelected
        characterIsShow = !characterIsShow
        self.collectionView.reloadData()
    }
    
    @objc func readButtonClick(_ button: UIButton) {
        if !isUserInteracted {
            AnswerSystemHelper.modifyStatusNotificationPost()
            return
        }
        let delegate = UIApplication.shared.delegate
        iFlyManager.initIFly((delegate?.window??.center)!, language: .chinese)
        if !readImageView.isAnimating {
            readImageView.startAnimating()
        }
        iFlyManager.start()
    }
}
