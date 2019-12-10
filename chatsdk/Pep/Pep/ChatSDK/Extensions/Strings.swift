extension Int {

    var string : String!
    {
        set
        {
            
        }
        get{
            return self.description
        }
    }
}

extension Bool {
    var string : String!
    {
        set
        {
            
        }
        get{
            return self.description
        }
    }
    
    
}


extension String {
//    func capitalizingFirstLetter() -> String {
//        let first = String(characters.prefix(1)).capitalized
//        let other = String(characters.dropFirst())
//        return first + other
//    }
//
    mutating func capitalizeFirstLetter() {
//        self = self.capitalizingFirstLetter()
    }
    
    
}


extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
    func addTwoZeros() -> String
    {
        var quan = 0.00
        quan += self
        return  String(format: "%.2f", quan)
    }
    
}


