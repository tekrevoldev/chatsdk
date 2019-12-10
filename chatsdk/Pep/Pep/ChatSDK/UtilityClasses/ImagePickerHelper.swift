//
//  ImagePickerHelper.swift
//  Caristocrat
//
//  Created by Muhammad Muzammil on 10/18/18.
//  Copyright © 2018 Ingic. All rights reserved.
//

import Foundation
import Photos

protocol ImagePickerDelegate {
    func didImageSelected(image: UIImage)
    func didCancel()

}

class ImagePickerHelper: NSObject {
    
    static let sharedInstance = ImagePickerHelper()
    let imagePicker = UIImagePickerController()
    var delegate: ImagePickerDelegate?

    func showPicker(delegate: ImagePickerDelegate) {
        self.delegate = delegate
        imagePicker.delegate = self
        
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            self.showDialog()
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    self.showDialog()
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            print("User do not have access to photo album.")
        case .denied:
            Utility().openSettings()
        }
    }
    
    func showDialog() {
        Utility.showAlert(title: "Choose Image", message: "",
                          positiveText: "Camera", positiveClosure: { (alert) in
            self.presentImagePicker(fromCamera: true)
        }, negativeClosure: { (alert) in
            self.presentImagePicker(fromCamera: false)
        }, navgativeText: "Gallery", preferredStyle: .actionSheet)
        
    }
    
    func presentImagePicker(fromCamera: Bool) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = fromCamera ? .camera : .photoLibrary
        Utility().topViewController()?.present(imagePicker, animated: true, completion: nil)
    }

}

extension ImagePickerHelper: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @objc func imagePickerController(_ picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        self.delegate?.didImageSelected(image: image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.delegate?.didCancel()
        picker.dismiss(animated: true, completion: nil)
        }
}
