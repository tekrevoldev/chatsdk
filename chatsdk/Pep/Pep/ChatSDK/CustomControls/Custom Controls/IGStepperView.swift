import UIKit

@IBDesignable
class IGStepperView: UIView {
    
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var StepDownButton: UIButton!
    
    @IBOutlet weak var StepUpButton: UIButton!
    
    @IBOutlet weak var countTextField: UITextField!
    var maximumVal :String = "50"
    var minimumVal:String = "1"
    
    
    @IBInspectable var maximumValue: String? {
        
        get{
            return maximumVal
        }
        
        set(fieldValue){
            if  isStringAnInt(string: fieldValue!)
            {
                maximumVal = fieldValue!
            }else{
                self.maximumValue = maximumVal
            }
        }
    }
    
    
    
    @IBInspectable var minimumValue: String? {
        
        get{
            return self.minimumVal
        }
        
        set(fieldValue){
            if  isStringAnInt(string: fieldValue!)
            {
                minimumVal = fieldValue!
            }else{
                self.minimumValue = minimumVal
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    
    func xibSetup(){
        backgroundColor = .clear
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        addSubview(view)
        countTextField.text = minimumVal
    }
    
    
    func loadViewFromNib() -> UIView{
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
        
    }
    
    @IBAction func stepUp(_ sender: UIButton) {
        
         if  Int(countTextField.text!)! < Int(maximumVal)! {
        countTextField.text = String(Int(countTextField.text!)!+1)
        }
    }
    
    
    @IBAction func stepDown(_ sender: UIButton) {
        if  Int(countTextField.text!)! > Int(minimumVal)! {
            countTextField.text = String(Int(countTextField.text!)!-1)
        }
    }
    func isStringAnInt(string: String) -> Bool {
        return Int(string) != nil && Int(string)! >= Int(minimumVal)!
    }

    
}
