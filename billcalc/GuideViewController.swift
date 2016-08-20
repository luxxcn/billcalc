//
//  GuideViewController.swift
//

import UIKit

// 向导页的数量
let numOfPage = 4

class GuideViewController: UIViewController, UIScrollViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let frame = self.view.bounds
        // scrollview 初始化
        let scrollView = UIScrollView()
        scrollView.frame = self.view.bounds
        scrollView.delegate = self
        // 让内容横向移动，设置内容为4个页面宽度
        scrollView.contentSize = CGSizeMake(frame.size.width * CGFloat(numOfPage), frame.size.height)
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        for i in 0..<numOfPage {
            let imgfile = "guide\(Int(i+1)).png"
            let image = UIImage(named: "\(imgfile)")
            let imgView = UIImageView(image: image)
            imgView.frame = CGRectMake(frame.size.width*CGFloat(i), CGFloat(0), frame.size.width, frame.size.height)
            scrollView.addSubview(imgView)
        }
        scrollView.contentOffset = CGPointZero
        self.view.addSubview(scrollView)
        
    }
    
    // scrollView 滑动时调用
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let twidth = CGFloat(numOfPage - 1) * self.view.bounds.size.width
        // 如果在最后一个界面，继续滑动会进入主界面
        if(scrollView.contentOffset.x > twidth) {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateInitialViewController()
            viewController?.modalTransitionStyle = .FlipHorizontal
            
            // 自定义过渡动画
            //let animation = CATransition()
            //animation.duration = 1.0
            
            self.presentViewController(viewController!, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
