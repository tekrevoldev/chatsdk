//
//  AudioManager.swift
//  BasicStructureUpdate
//
//  Created by Muzzamil on 20/08/2019.
//  Copyright © 2019 Muzammil. All rights reserved.
//

import Foundation
import AVFoundation

class AudioManager : NSObject {
    static let sharedInstance = AudioManager()
    var audioPlayer: AVAudioPlayer?
    var messageId: String?
    
    override init() {
        super.init()
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .default, options: .defaultToSpeaker)
    }
    
    func play(messageId: String, url: String, delegate: AVAudioPlayerDelegate) {
        self.messageId = messageId
        audioPlayer = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: url))
        audioPlayer?.delegate = delegate
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    }
    
    func stopAudio() {
        self.messageId = ""
        self.audioPlayer?.stop()
    }
}

