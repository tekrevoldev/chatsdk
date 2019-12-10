//
//  MessageLeftCell.swift
//  BasicStructureUpdate
//
//  Created by Muzzamil on 11/08/2019.
//  Copyright © 2019 Muzammil. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import UIKit

class MessageCell: UITableViewCell {
    
    @IBOutlet var labelText: UILabel!
    @IBOutlet var labelTime: UILabel!
    @IBOutlet var labelHeaderDate: UILabel!
    @IBOutlet var labelHeaderConstraint: NSLayoutConstraint!
    
    @IBOutlet var audioViewHeight: NSLayoutConstraint!
    @IBOutlet var audioView: UIView!
    @IBOutlet var audioPlayPauseBtn: UIButton!
    @IBOutlet var labelDuration: UILabel!
    @IBOutlet var loader: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setData(message: MessageModel) {
        
        if DownloadManager.isDownloading(messageId: message.key ?? "") {
            loader.isHidden = false
            loader.startAnimating()
            audioPlayPauseBtn.isHidden = true
            labelDuration.isHidden = true
        } else {
            loader.isHidden = true
            loader.startAnimating()
            audioPlayPauseBtn.isHidden = false
            labelDuration.isHidden = false
        }
        
        if message.type ?? 0 == MessageTypes.Text.rawValue {
            labelText.text = message.getMessageBody()?.text ?? ""
            audioViewHeight.constant = 0
            audioViewHeight.isActive = false
            audioView.isHidden = true
        } else {
            audioViewHeight.isActive = true
            labelText.isHidden = true
            audioView.isHidden = false
            audioViewHeight.constant = 30
        }
        
        labelTime.text = Utility.milliToDate(milliDate: message.date ?? 0, format: .Time)
        labelHeaderDate.text = "  " + Utility.milliToDate(milliDate: message.date ?? 0, format: .Date) + "  "
        setPlayButton(isPlaying: AudioManager.sharedInstance.messageId == message.key ?? "")
        
        if message.key ?? "" == AudioManager.sharedInstance.messageId ?? "" {
            labelDuration.text = AudioManager.sharedInstance.audioPlayer?.currentTime.stringFromTimeInterval()

        } else {
            labelDuration.text = duration(messageId: message.key ?? "").stringFromTimeInterval()
        }
        
    }
    
    func duration(messageId: String) -> Double {
        let file = File.name(messageId,"m4a")
        let path = Dir.document("media", and: file)

        let asset = AVURLAsset(url: URL(fileURLWithPath: path))
        return Double(CMTimeGetSeconds(asset.duration))
    }
    
    func setPlayButton(isPlaying: Bool) {
        if isPlaying {
            audioPlayPauseBtn.setImage(#imageLiteral(resourceName: "btn_pause"), for: .normal)
        } else {
            audioPlayPauseBtn.setImage(#imageLiteral(resourceName: "btn_play"), for: .normal)

        }
    }
    
    func showDate() {
        labelHeaderDate.isHidden = false
        labelHeaderConstraint.constant = 40
    }
    
    func hideDate() {
        labelHeaderDate.isHidden = true
        labelHeaderConstraint.constant = 0
    }
}
