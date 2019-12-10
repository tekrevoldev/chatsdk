
import Foundation
import UIKit

class AddFriendsCell: UITableViewCell {

	@IBOutlet var imageUser: UIImageView!
	@IBOutlet var labelInitials: UILabel!
	@IBOutlet var labelName: UILabel!
	@IBOutlet var labelStatus: UILabel!
    
    func setData(userData: UserModel, isAlreadyAdded: Bool) {
       self.labelName.text = userData.meta?.name.unWrap ?? ""
       self.labelStatus.text = userData.isCurrentUser() ? "You" : isAlreadyAdded ? "Already Added" : "Available"
    }
}
