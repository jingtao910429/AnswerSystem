//
//  WriteView.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/9.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import YYText
import QBImagePickerController
import MMBaseComponents

class WriteView: QuestionBaseView {
    
    fileprivate var writeContentView: WriteContentView!
    fileprivate var writeBackMaskView: UIView!
    fileprivate var pickerManager: MMPhotoPickManager!
    
    fileprivate var kNotificationName = NSNotification.Name(rawValue: AnswerSystemHelper.kRichTextNotificationUploadSuccessComplete)
    
    fileprivate var writeTopic: TopicModel? {
        didSet {
            if let writeTopic = writeTopic {
                self.topic = writeTopic
                self.makeConstraints()
                self.writeContentView.isUserInteracted = self.isUserInteracted
                //self.baseRichTextView.paragraphStyle(20, lineSpace: 1)
            }
        }
    }
    
    override var answers: [UserAnswerItemModel]? {
        didSet {
            if let answers = answers {
                for answer in answers {
                    writeContentView.answer = answer
                }
            }
        }
    }
    
    override func fetchAnswers() -> [RichParameterType] {
        var userAnswers: [RichParameterType] = []
        userAnswers.append(writeContentView.answerParameters(url: self.questionContainerDelegate?.uploadResultCallBack?()))
        
        judeEditStatus(userAnswers: userAnswers)
        
        return userAnswers
    }
    
    override func updateAnswerParseConstraints() {
        super.updateAnswerParseConstraints()
        
        writeContentView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.baseRichTextView.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.centerX.equalTo(questionScrollView)
            if let isHidden = self.answerParseContainerView?.isHidden, isHidden {
                make.bottom.equalTo(questionScrollView).offset(answerParseStatus ? -20 : -50)
            }
        }
        
        writeBackMaskView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.baseRichTextView.snp.bottom).offset(5)
            make.left.right.equalTo(questionScrollView)
            if let isHidden = self.answerParseContainerView?.isHidden, isHidden {
                make.bottom.equalTo(self)
            } else {
                make.bottom.equalTo(answerParseContainerView!.snp.top)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NotificationCenter.default.addObserver(self, selector: #selector(richTextUploadSuccess(_ :)), name: kNotificationName, object: nil)
        
        pickerManager = MMPhotoPickManager()
        
        writeContentView = WriteContentView(frame: CGRect(x: 0, y: 0, width: questionScrollView.frame.width, height: 0))
        writeContentView.cameraBlock = { [weak self] (button) in
            guard let `self` = self else {
                return
            }
            self.pickerManager.photo(type: .all, view: button, delegate: self)
        }
        writeContentView.focusBlock = { [weak self] (frame) in
            guard let `self` = self else {
                return
            }
            self.inputConvertFrame = frame
        }
        questionScrollView.delegate = self
        questionScrollView.addSubview(writeContentView)
        
        writeBackMaskView = UIView()
        writeBackMaskView.backgroundColor = RTBackGroundColor
        questionScrollView.addSubview(writeBackMaskView)
        questionScrollView.sendSubview(toBack: writeBackMaskView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func makeConstraints() {
        
        writeContentView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.baseRichTextView.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.centerX.equalTo(questionScrollView)
            make.bottom.equalTo(questionScrollView.snp.bottom).offset(-50)
        }
        
        writeBackMaskView.snp.makeConstraints { (make) in
            make.top.equalTo(self.baseRichTextView.snp.bottom).offset(5)
            make.left.right.equalTo(questionScrollView)
            make.bottom.equalTo(self)
        }
        
        answerParseContainerView?.snp.makeConstraints({ (make) in
            make.top.equalTo(writeContentView.snp.bottom).offset(5).priority(999)
            make.centerX.equalTo(questionScrollView)
            make.left.right.equalTo(self)
            make.bottom.equalTo(questionScrollView).offset(AnswerParseBottomHeight)
        })
    }
    
    func loadData(writeTopic: TopicModel?) {
        self.writeTopic = writeTopic
    }
    
    @objc func richTextUploadSuccess(_ notification: NSNotification) {
        if let url = notification.object as? String, url != "" {
            var answer = writeContentView.answer
            if answer == nil {
                answer = UserAnswerItemModel()
            }
            answer?.index = "image"
            answer?.answer = url
            writeContentView.answer = answer
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: kNotificationName, object: nil)
    }
    
}

extension WriteView: UIScrollViewDelegate {
    
}

extension WriteView: MMPhotoPickManagerDelegate {
    
    func alertAction(alert: UIAlertController) {
        NotificationCenter.default.post(name: MMAnswerSystemPhotoPickNotification, object: alert)
    }
    
    func cameraAction(camera: UIImagePickerController) {
        NotificationCenter.default.post(name: MMAnswerSystemPhotoPickCameraNotification, object: camera)
    }
    
    func albumAction(album: QBImagePickerController) {
        NotificationCenter.default.post(name: MMAnswerSystemPhotoPickAlbumNotification, object: album)
    }
    
    func selectResult(image: UIImage?) {
        if let image = image {
            self.questionContainerDelegate?.uploadImage?(image: image)
        }
    }
    
}
