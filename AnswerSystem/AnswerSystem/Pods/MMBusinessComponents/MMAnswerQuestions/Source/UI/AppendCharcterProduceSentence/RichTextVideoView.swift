//
//  RichTextVideoView.swift
//  MMAnswerSystem_Example
//
//  Created by Mac on 2018/4/27.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation

class SentenceShowResultView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//富文本音频相关
class RichTextAudioView: UIView {
    
    fileprivate var backGroundImageView: UIImageView!
    fileprivate var startButton: UIButton!
    fileprivate var gifButton: UIButton!
    
    fileprivate var playUrl: String = ""
    fileprivate var isPlaying = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NotificationCenter.default.addObserver(self, selector: #selector(autoPlayStop(_ :)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        backGroundImageView = UIImageView()
        addSubview(backGroundImageView)
        
        startButton = UIButton()
        startButton.setImage(bundleImage(name: "loudspeakerfore"), for: .normal)
        startButton.addRichTextTapGesture { [weak self] (tap) in
            guard let `self` = self else {
                return
            }
            if self.isPlaying {
                return
            }
            self.gifButton.isHidden = false
            self.startButton.isHidden = true
            if self.playUrl != "" {
                self.isPlaying = true
                NotificationCenter.default.post(name: MMAnswerSystemAudioPlayNotification, object: self.playUrl)
            }
        }
        addSubview(startButton)
        
        gifButton = UIButton()
        gifButton.addRichTextTapGesture { [weak self] (tap) in
            guard let `self` = self else {
                return
            }
            if self.isPlaying {
                return
            }
            self.gifButton.isHidden = true
            self.startButton.isHidden = false
        }
        addSubview(gifButton)
        
        
        if let data = NSData(contentsOfFile: AnswerSystemHelper.shared.bundlePath(name: "loudspeaker.gif")) {
            gifButton.isHidden = true
            gifButton.setImage(UIImage.sd_animatedGIF(with: data as Data), for: .normal)
        }
        
        makeConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeConstraints() {
        
        backGroundImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        startButton.snp.makeConstraints { (make) in
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.top.equalTo(5)
            make.bottom.equalTo(-5)
        }
        
        gifButton.snp.makeConstraints { (make) in
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.top.equalTo(5)
            make.bottom.equalTo(-5)
        }
    }
    
    @objc func autoPlayStop(_ notification: NSNotification) {
        self.isPlaying = false
        self.gifButton.isHidden = true
        self.startButton.isHidden = false
    }
    
    func loadData(content: RichTextContent) {
        
        self.playUrl = content.fileUrl
        
        if let url = URL(string: content.bgImg) {
            
            backGroundImageView.sd_setImage(with: url, placeholderImage: nil, options: .refreshCached) { (image, error, type, url) in
            }
        }
        
        if content.feImg != "", let url = URL(string: content.feImg) {

            startButton.sd_setImage(with: url, for: .normal, completed: nil)
        }

        if content.feImgPlaying != "", let url = URL(string: content.feImgPlaying), let data = NSData(contentsOf: url) {
            gifButton.isHidden = true
            gifButton.setImage(UIImage.sd_animatedGIF(with: data as Data), for: .normal)
        }
        
    }
    
    deinit {
        NotificationCenter.default.post(name: MMAnswerSystemAudioStopPlayNotification, object: self.playUrl)
    }
    
}
