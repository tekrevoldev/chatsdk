enum Route: String {
    
    case categories = "maincategory"
    case categoryDetail = "maincategorydetail"
    case contactUs = "Contact.php"
    
    func url() -> String {
      return Constants.BaseURL + self.rawValue
    }
}
