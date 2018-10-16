//
//  WriteContentView.swift
//  MMBaseComponents
//
//  Created by Mac on 2018/4/29.
//

import UIKit

enum WriteContentViewType {
    case image
    case text
}

typealias CameraBlock = ((UIButton) ->Void)
typealias WriteBlock = (() ->Void )
typealias FocusBlock = ((CGRect?) ->Void )

class WriteContentView: UIView {
    
    fileprivate var backContentView: UIView!
    fileprivate var promptLabel: UILabel!
    fileprivate var writeTextView: UITextView!
    fileprivate var writeImageView: UIImageView!
    fileprivate var cameraBtn: UIButton!
    fileprivate var editBtn: UIButton!
    
    fileprivate var writeContentViewType: WriteContentViewType = .text
    fileprivate var imageUrl = ""
    
    var cameraBlock: CameraBlock?
    var writeBlock: WriteBlock?
    var focusBlock: FocusBlock?
    
    var answer: UserAnswerItemModel? {
        didSet {
            if let answer = answer {
                if answer.index == "txt" {
                    if answer.answer != "" {
                        promptLabel.alpha = 0
                    } else {
                        promptLabel.alpha = 1
                    }
                    writeTextView.text = answer.answer
                }
                if answer.index == "image" {
                    imageUrl = answer.answer
                    writeImageView.image(withUrlStr: answer.answer, phImage: bundleImage(name: "img_icon"))
                }
            }
        }
    }
    
    var isUserInteracted = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isUserInteractionEnabled = true
        
        backContentView = UIView(frame: frame)
        backContentView.layer.cornerRadius = 5
        backContentView.layer.borderColor = RTSeperateColor.cgColor
        backContentView.layer.borderWidth = 0.5
        backContentView.layer.masksToBounds = true
        addSubview(backContentView)
        
        promptLabel = UILabel(frame: frame)
        promptLabel.text = "点击输入你要写的话..."
        promptLabel.textColor = RTSeperateColor
        promptLabel.font = RTNormalFont
        
        writeTextView = UITextView(frame: frame)
        writeTextView.delegate = self
        writeTextView.textColor = RTTextColor
        writeTextView.font = RTNormalFont
        writeTextView.returnKeyType = .done
        backContentView.addSubview(writeTextView)
        
        writeTextView.addSubview(promptLabel)
        
        writeImageView = UIImageView(frame: frame)
        writeImageView.isUserInteractionEnabled = true
        writeImageView.isHidden = true
        writeImageView.contentMode = .scaleAspectFit
        writeImageView.addRichTextTapGesture { [weak self] (tap) in
            guard let `self` = self else {
                return
            }
            if self.imageUrl != "" {
                NotificationCenter.default.post(name: MMAnswerSystemPhotoBrowserNotification, object: self.imageUrl)
            }
        }
        backContentView.addSubview(writeImageView)
        
        cameraBtn = UIButton()
        cameraBtn.setImage(bundleImage(name: "exercise_icon_camear_nor"), for: .normal)
        cameraBtn.isSelected = false
        cameraBtn.addTarget(self, action: #selector(cameraBtnClick(_ :)), for: .touchUpInside)
        addSubview(cameraBtn)
        
        editBtn = UIButton()
        editBtn.setImage(bundleImage(name: "exercise_icon_edit_nor"), for: .normal)
        editBtn.isSelected = true
        editBtn.addTarget(self, action: #selector(editBtnClick(_ :)), for: .touchUpInside)
        addSubview(editBtn)
        
        makeConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeConstraints() {
        
        backContentView.snp.makeConstraints { (make) in
            make.top.equalTo(2)
            make.left.equalTo(2)
            make.right.equalTo(-2)
            make.height.equalTo(180)
        }
        
        writeImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        writeTextView.snp.makeConstraints { (make) in
            make.top.left.equalTo(0)
            make.bottom.right.equalTo(0)
        }
        
        promptLabel.snp.makeConstraints { (make) in
            make.top.left.equalTo(writeTextView).offset(10)
        }
        
        cameraBtn.snp.makeConstraints { (make) in
            make.top.equalTo(backContentView.snp.bottom).offset(15)
            make.height.width.equalTo(44)
            make.right.equalTo(backContentView.snp.right).offset(-2)
            make.bottom.equalTo(-10)
        }
        
        editBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(cameraBtn)
            make.width.height.equalTo(cameraBtn)
            make.right.equalTo(cameraBtn.snp.left).offset(-15)
        }
    }
    
    
    @objc func cameraBtnClick(_ button: UIButton) {
        if !isUserInteracted {
            AnswerSystemHelper.modifyStatusNotificationPost()
            return
        }
        self.endEditing(true)
        button.isSelected = true
        editBtn.isSelected = false
        writeTextView.isHidden = true
        writeImageView.isHidden = false
        self.cameraBlock?(button)
    }
    
    @objc func editBtnClick(_ button: UIButton) {
        if !isUserInteracted {
            AnswerSystemHelper.modifyStatusNotificationPost()
            return
        }
        button.isSelected = true
        cameraBtn.isSelected = false
        writeTextView.isHidden = false
        writeImageView.isHidden = true
        writeTextView.becomeFirstResponder()
        self.writeBlock?()
    }
    
}

extension WriteContentView: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        if !isUserInteracted {
            AnswerSystemHelper.modifyStatusNotificationPost()
            return false
        }
        
        let convertFrame = writeTextView.superview?.convert(writeTextView.frame, to: UIApplication.shared.keyWindow)
        //转换过后的坐标
        
        self.focusBlock?(convertFrame ?? CGRect.zero)
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if length(text: textView.text) > 0 {
            promptLabel.alpha = 0
        } else {
            promptLabel.alpha = 1
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.endEditing(true)
            return false
        }
        return true
    }
}

extension WriteContentView {
    
    public func length(text: String) -> Int {
        return text.characters.count
    }
    
    public func answerParameters(url: String?) -> RichParameterType {
        self.imageUrl = url ?? ""
        var parameters: RichParameterType = [:]
        parameters["is_right"] = true
        parameters["scores"] = 0
        parameters["index"] = imageUrl != "" ? "image" : "txt"
        parameters["answer"] = imageUrl == "" ? writeTextView.text : imageUrl
        return parameters
    }
}
