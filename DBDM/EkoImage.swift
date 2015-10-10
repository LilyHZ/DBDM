import UIKit

class EkoImage: UIImageView {

    /**
    构造方法
    */
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //设置圆角
        self.layer.cornerRadius = self.frame.width/2
        self.clipsToBounds = true
        
        //设置边框
        self.layer.borderWidth = 4
        self.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7).CGColor
        
    }
    
    //旋转
    func onRotation(){
        self.layer.removeAllAnimations()
        //动画实例关键字
        var animation = CABasicAnimation(keyPath: "transform.rotation")
        //初始值
        animation.fromValue = 0.0
        //结束值
        animation.toValue = M_PI*2.0
        //动画执行时间
        animation.duration = 20
        //动画重复次数
        animation.repeatCount = 10000
        self.layer.addAnimation(animation, forKey: nil)
    }
}
