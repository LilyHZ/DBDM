import UIKit

class OrderButton: UIButton {

    var order = 1
    
    var order1:UIImage = UIImage(named: "order1")!
    var order2:UIImage = UIImage(named: "order2")!
    var order3:UIImage = UIImage(named: "order3")!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: "onClick:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    func onClick(sender:UIButton){
        order++
        if order == 1{
            self.setImage(order1, forState: UIControlState.Normal)
        }else if order == 2 {
            self.setImage(order2, forState: UIControlState.Normal)
        }else if order == 3 {
            self.setImage(order3, forState: UIControlState.Normal)
        }else if order > 3 {
            order = 1
            self.setImage(order1, forState: UIControlState.Normal)
        }
    }


}
