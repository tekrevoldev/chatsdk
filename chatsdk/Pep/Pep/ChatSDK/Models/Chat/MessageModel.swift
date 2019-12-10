/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
class MessageModel: FirebaseBaseModel, Codable  {
	let date : Int64?
	let json_v2 : MessageBodyModel?
	let type : Int?
	let userFirebaseId : String?

	enum CodingKeys: String, CodingKey {
		case date = "date"
		case json_v2 = "json_v2"
		case type = "type"
		case userFirebaseId = "user-firebase-id"
	}
    
    init(date: Int64, text: String, senderId: String) {
        self.date = date
        self.json_v2 = MessageBodyModel.init(text: text)
        self.userFirebaseId = senderId
        self.type = MessageTypes.Text.rawValue
        super.init()
    }
    
    init(date: Int64, audioURL: String, senderId: String) {
        self.date = date
        self.json_v2 = MessageBodyModel.init(audioURL: audioURL)
        self.userFirebaseId = senderId
        self.type = MessageTypes.Audio.rawValue
        super.init()
    }

    required init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		date = try values.decodeIfPresent(Int64.self, forKey: .date)
		json_v2 = try values.decodeIfPresent(MessageBodyModel.self, forKey: .json_v2)
		type = try values.decodeIfPresent(Int.self, forKey: .type)
		userFirebaseId = try values.decodeIfPresent(String.self, forKey: .userFirebaseId)
        super.init()
	}
    
    func getSenderId() -> String {
        return self.userFirebaseId.unWrap
    }
    
    func getMessageBody() -> MessageBodyModel? {
        return self.json_v2
    }
    
    func isMyMessage() -> Bool {
        return self.userFirebaseId == AppStateManager.sharedInstance.userId
    }
}
