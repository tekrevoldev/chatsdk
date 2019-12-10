
import Foundation
class ThreadModel : FirebaseBaseModel, Codable {
	var details : ThreadDetailModel?
	var lastMessage : MessageModel?
	var meta : ThreadMetaModel?
	var updated : Updated?
    var users: [String: [String: String]]?
    
	enum CodingKeys: String, CodingKey {
		case details = "details"
		case lastMessage = "lastMessage"
		case meta = "meta"
		case updated = "updated"
        case users = "users"
	}
    
    override init() {
       super.init()
    }

    required init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		details = try values.decodeIfPresent(ThreadDetailModel.self, forKey: .details)
		lastMessage = try values.decodeIfPresent(MessageModel.self, forKey: .lastMessage)
		meta = try values.decodeIfPresent(ThreadMetaModel.self, forKey: .meta)
		updated = try values.decodeIfPresent(Updated.self, forKey: .updated)
        users = try values.decodeIfPresent([String: [String: String]].self, forKey: .users)
	}
    
    func isGroup() -> Bool {
        return self.details?.type ?? 0 == 1
    }
    
    func isAmIAdmin() -> Bool {
        return self.users?.filter({$0.key == AppStateManager.sharedInstance.userId}).first?.value["status"] == ThreadUserRole.Admin.rawValue
    }

}

struct ThreadUserStatus : Codable {
    var status : String?
    
    enum CodingKeys: String, CodingKey {
        
        case status = "status"
    }
    
    init(status: ThreadUserRole) {
       self.status = status.rawValue
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(String.self, forKey: .status)
    }
    
}
