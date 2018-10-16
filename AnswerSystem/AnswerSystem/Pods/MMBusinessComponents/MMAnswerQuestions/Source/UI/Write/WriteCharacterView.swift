//
//  WriteCharacterView.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/9.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import JavaScriptCore

class WriteCharacterView: QuestionBaseView {
    
    fileprivate var playButton: UIButton!
    fileprivate var writeButton: UIButton!
    
    fileprivate var webView: UIWebView!
    fileprivate var context: JSContext?
    
    fileprivate var topicData: TopicModel? {
        didSet {
            self.topic = topicData
        }
    }
    
    override func fetchAnswers() -> [RichParameterType] {
        var userAnswers: [RichParameterType] = []
        var parameters: RichParameterType = [:]
        parameters["is_right"] = true
        parameters["index"] = "1"
        parameters["scores"] = 0
        parameters["answer"] = "1"
        userAnswers.append(parameters)
        return userAnswers
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        webView = UIWebView()
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = richTextRGB(233, 243, 253)
        webView.delegate = self
        questionScrollView.addSubview(webView)
        
        playButton = UIButton()
        playButton.setImage(bundleImage(name: "exercise_icon_rewrite"), for: .normal)
        playButton.addTarget(self, action: #selector(playButtonClick(clickButton:)), for: .touchUpInside)
        questionScrollView.addSubview(playButton)
        
        writeButton = UIButton()
        writeButton.setImage(bundleImage(name: "exercise_icon_write"), for: .normal)
        writeButton.addTarget(self, action: #selector(writeButtonClick(clickButton:)), for: .touchUpInside)
        questionScrollView.addSubview(writeButton)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData(topic: TopicModel?, url: String?) {
        self.topicData = topic
        guard let url = url else {
            return
        }
        webView.loadRequest(URLRequest(url: URL(string: url)!))
        self.makeConstraints()
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        webView.snp.makeConstraints { (make) in
            make.top.equalTo(self.baseRichTextView.snp.bottom).offset(20)
            make.width.height.equalTo(300)
            make.centerX.equalTo(self.questionScrollView)
        }
        
        writeButton.snp.makeConstraints { (make) in
            make.top.equalTo(webView.snp.bottom).offset(5)
            make.right.equalTo(webView.snp.right).offset(-8)
            make.height.equalTo(60)
            make.bottom.equalTo(-25)
        }
        
        playButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(writeButton)
            make.right.equalTo(writeButton.snp.left).offset(-10)
        }
    }
    
}

extension WriteCharacterView: UIWebViewDelegate {
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        let parameters = [1, self.topicData?.words.first?.datas.first ?? ""] as [Any]
        
        context = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext
        let _ = context?.objectForKeyedSubscript("startAnimation").call(withArguments: parameters)
        
    }
    
}

extension WriteCharacterView {
    
    @objc func playButtonClick(clickButton: UIButton) {
        if !self.isUserInteracted {
            AnswerSystemHelper.modifyStatusNotificationPost()
            return
        }
        let _ = context?.objectForKeyedSubscript("switchModel").call(withArguments: [0])
    }
    
    @objc func writeButtonClick(clickButton: UIButton) {
        if !self.isUserInteracted {
            AnswerSystemHelper.modifyStatusNotificationPost()
            return
        }
        let _ = context?.objectForKeyedSubscript("switchModel").call(withArguments: [1])
    }
}
