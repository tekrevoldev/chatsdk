extension Int{
    var responseIs: Response{
        get{
            switch self {
            case 200:
                return .success
            case 500:
                return .serverError
            default:
                return .undefined
            }
        }
    }
}
