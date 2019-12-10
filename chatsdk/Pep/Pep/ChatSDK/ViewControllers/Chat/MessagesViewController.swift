//
//  MessagesViewController.swift
//  BasicStructureUpdate
//
//  Created by Muzzamil on 11/08/2019.
//  Copyright © 2019 Muzammil. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import AVFoundation

class MessagesViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var messageTextView: CustomUITextView!
    
    var thread: ThreadModel?
    var messages: [MessageModel] = []
    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = thread {
            setNavigation()
            registerCells()
            getMessages()
        }
    }
    
    func makeTitleBarClickable(title: String) {
        let button =  UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        button.backgroundColor = .clear
        button.setTitle(title, for: .normal)
        button.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(navigateToGroupDetail), for: .touchUpInside)
        navigationItem.titleView = button
    }
    
    @objc func navigateToGroupDetail() {
        if self.thread?.isGroup() ?? false {
            let groupDetailVC = GroupDetailController.instantiate(fromAppStoryboard: .Home)
            groupDetailVC.threadModel = self.thread
            self.navigationController?.pushViewController(groupDetailVC, animated: true)
        }
        
    }
    
    func startTimer() {
         timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    @objc func timerAction() {
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        AudioManager.sharedInstance.stopAudio()
    }
    
    func registerCells() {
        self.tableView.register(UINib(nibName: Cell.MessageRight.rawValue, bundle: nil), forCellReuseIdentifier: Cell.MessageRight.rawValue)
        self.tableView.register(UINib(nibName: Cell.MessageLeft.rawValue, bundle: nil), forCellReuseIdentifier: Cell.MessageLeft.rawValue)
    }
    
    func getMessages() {
        FirebaseMessage.init(threadId: thread?.key ?? "").getMessages { (isSuccess, result) in
            if let messages = result {
                self.messages += messages
                self.tableView.reloadData()
                self.tableView.scrollToBottom()
            }
        }
        
    }
    
    func clearInputField() {
        messageTextView.text = ""
    }
    
    func isValidMessage() -> Bool {
        return !messageTextView.getText().trimmedString().isEmpty
    }
    
    func setNavigation() {
        FirebaseThread.getThreadName(thread: self.thread!) { (name) in
            self.navigationItem.title = name
            self.makeTitleBarClickable(title: name)
        }
    }
    
    @IBAction func tappedOnSendMessage() {
        if Utility.isInternetConnected() && isValidMessage() {
            sendMessage()
        }
    }
    
    func sendMessage() {
        if self.thread?.isGroup() ?? false {
            
            FirebaseUser.init(myUser: true).getUserThreads(completeHandler: { (threads) in
                if threads?[self.thread?.key ?? ""] == nil {
                    Utility.showErrorWith(message: "You are not longer member of this thread.")
                return
                } else {
                    FirebaseMessage.init(threadId: self.thread?.key ?? "").send(textMessge: self.messageTextView.text) { (isSuccess) in
                
                    }
                    self.clearInputField()
                }
            }, observeForeEver: false)
            
            return
        }
        
        FirebaseMessage.init(threadId: thread?.key ?? "").send(textMessge: messageTextView.text) { (isSuccess) in
            
        }
        clearInputField()
       
    }
    
    func navigateToVoiceRecordVC() {
        let audioView = AudioViewController()
        audioView.delegate = self
        self.navigationController?.pushViewController(audioView, animated: true)
    }
    
    @IBAction func tappedOnAudioButton() {
       self.navigateToVoiceRecordVC()
    }
    
    @objc func playPauseAudio(_ sender: UIButton) {
        let message = messages[sender.tag]
        
        let file = File.name(message.key ?? "","m4a")
        let path = Dir.document("media", and: file)
        if AudioManager.sharedInstance.messageId == message.key {
           AudioManager.sharedInstance.messageId = ""
        } else {
            if !FileManager.default.fileExists(atPath: path) {
                DownloadManager.startAudio(message.key ?? "", md5: "") { (path, error, success) in
                    self.tableView.reloadData()
                }
            } else {
                startTimer()
                AudioManager.sharedInstance.play(messageId: message.key ?? "", url: path, delegate: self)
            }
        }

        self.tableView.reloadData()
    }
}

extension MessagesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MessageCell?
        let message = messages[indexPath.row]
        
        if message.isMyMessage() {
            cell = tableView.dequeueReusableCell(withIdentifier: Cell.MessageRight.rawValue, for: indexPath) as? MessageCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: Cell.MessageLeft.rawValue, for: indexPath) as? MessageCell
        }
        cell?.audioPlayPauseBtn.tag = indexPath.row
        cell?.audioPlayPauseBtn.addTarget(self, action:#selector(playPauseAudio), for: .touchUpInside)
        cell?.setData(message: message)
        
        if indexPath.row > 0 {
            let previousDate = Utility.milliToDate(milliDate: messages[indexPath.row - 1].date ?? 0)
            let currentDate = Utility.milliToDate(milliDate: message.date ?? 0)
            Utility.isSameDay(dateOne: previousDate, dateTwo: currentDate) ? cell?.hideDate() : cell?.showDate()
        } else {
            cell?.showDate()
        }
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    

}

extension MessagesViewController: AudioDelegate {
    func didRecordAudio(path: String) {
        if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            DownloadManager.saveAudio(FirebaseAudioMesage.init(threadId: self.thread?.key ?? "").nextId(), data: data, threadId: self.thread?.key ?? "")
        }
    }
}


extension MessagesViewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        AudioManager.sharedInstance.messageId = ""
        self.stopTimer()
        self.tableView.reloadData()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("audioPlayerDecodeErrorDidOccur : " + (error?.localizedDescription ?? ""))
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        print("audioPlayerBeginInterruption : ")
    }
    
    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        print("audioPlayerEndInterruption : ")
        
    }
}
