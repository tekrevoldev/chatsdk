//Refer USAGE.MD for example
import UIKit
protocol PagingHelperDelegate:class {
    func recallDataService()
}
class PagingHelper : NSObject {
    
    var PAGESIZE = 10
    var PAGENUMBER = 0
    var TOTALITEMSCOUNT = 0
    var REFRESHDATA = false
    var delegate:PagingHelperDelegate!
    init(pageSize: Int = 10) {
        self.PAGESIZE = pageSize
    }
    
    func refreshPager(){
        self.REFRESHDATA = true
        self.PAGENUMBER = 0
    }
    
    func isRefreshCall()->Bool{
        if(self.REFRESHDATA){
            self.REFRESHDATA = false
            return true
        }else{
            return false
        }
    }
    
    func appendPageNo(){
        self.PAGENUMBER += 1
    }
    
    func pagingServiceFailed(){
        if(self.PAGENUMBER > 0)
        {
            self.PAGENUMBER -= 1
        }
    }
    
    func didLoadNextPage(pagingHelper scrollView: UIScrollView) {
        
        if(scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)){
            if(self.TOTALITEMSCOUNT > ((self.PAGENUMBER+1) * self.PAGESIZE)){
                self.appendPageNo()
                delegate?.recallDataService()
            }
        }
        
    }
}




