//
//  MMPhotoPickManager.swift
//  MMBaseComponents
//
//  Created by Mac on 2018/4/29.
//

import UIKit
import DeviceKit
import QBImagePickerController
import MMToolHelper

public enum MMPhotoPickType {
    case all
    case camera
    case photo
}

@objc public protocol MMPhotoPickManagerDelegate {
    @objc func alertAction(alert: UIAlertController)
    @objc func albumAction(album: QBImagePickerController)
    @objc func cameraAction(camera: UIImagePickerController)
    @objc func selectResult(image: UIImage?)
}

public class MMPhotoPickManager: NSObject {
    
    fileprivate var alertController: UIAlertController!
    fileprivate weak var delegate: MMPhotoPickManagerDelegate?
    
    public func photo(type: MMPhotoPickType, view: UIView, delegate: MMPhotoPickManagerDelegate?) {
        
        self.delegate = delegate
        alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photo = UIAlertAction(title: "相册", style: .default, handler: { (action) in
            let author = PHPhotoLibrary.authorizationStatus()
            
            if author == PHAuthorizationStatus.restricted
                || author == PHAuthorizationStatus.denied {
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
            self.openPhotosAlbum()
        })
        if type != .camera {
            alertController.addAction(photo)
        }
        
        let camera = UIAlertAction(title: "相机", style: .default, handler: { (action) in
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            if status == AVAuthorizationStatus.restricted
                || status == AVAuthorizationStatus.denied {
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
            self.openCamera()
        })
        if type != .photo {
            alertController.addAction(camera)
        }
        
        let cancal = UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            
        })
        alertController.addAction(cancal)
        if DeviceInfo.isPad() {
            let popover = alertController.popoverPresentationController
            if let popover = popover {
                popover.sourceView = view
                popover.sourceRect = view.bounds
                popover.permittedArrowDirections = .any
            }
        }
        self.delegate?.alertAction(alert: alertController)
    }
    
    public func openCamera() {
        if Device().isSimulator {
            return
        }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = true
        self.delegate?.cameraAction(camera: picker)
    }
    
    public func openPhotosAlbum() {
        let picker = QBImagePickerController()
        picker.allowsMultipleSelection = true
        picker.maximumNumberOfSelection = 1
        picker.delegate = self
        self.delegate?.albumAction(album: picker)
    }
}

extension MMPhotoPickManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        let selectImage = originalImage?.fixOrientation()
        
        self.delegate?.selectResult(image: selectImage)
        
        alertController.dismiss(animated: true) {
            
        }
        picker.dismiss(animated: true, completion: {
            
        })
    }
    
}

extension MMPhotoPickManager: QBImagePickerControllerDelegate {
    
    public func qb_imagePickerControllerDidCancel(_ imagePickerController: QBImagePickerController!) {
        alertController.dismiss(animated: true) {
            
        }
        imagePickerController.dismiss(animated: true) {
            
        }
    }
    
    public func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [Any]!) {
        for set in assets {
            let asset = set as? PHAsset
            if asset != nil {
                let scale = UIScreen.main.scale
                let size = CGSize(width: CGFloat(asset!.pixelWidth)/scale, height: CGFloat(asset!.pixelHeight)/scale)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                options.resizeMode = .none
                PHImageManager.default().requestImage(for: asset!, targetSize: size, contentMode: PHImageContentMode.default, options: options, resultHandler: { (result, info) in
                    self.delegate?.selectResult(image: result?.fixOrientation())
                })
            }
        }
        alertController.dismiss(animated: true) {
            
        }
        imagePickerController.dismiss(animated: true) {
            
        }
    }
    
}
