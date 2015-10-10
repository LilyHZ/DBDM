//
//  ChannelController.swift
//  DBDM
//
//  Created by xly on 15/10/3.
//  Copyright (c) 2015年 Lily. All rights reserved.
//

import UIKit

protocol ChannelProtocol{
    //回调方法，将频道id传回到代理中
    func onChangeChannel(channel_id:String)
}

class ChannelController: UIViewController ,UITableViewDataSource,UITableViewDelegate{//,HttpProtocol{

    //频道列表
    @IBOutlet weak var tv: UITableView!
    //申明代理
    var delegate:ChannelProtocol?
    //网络操作类的实例
//    var eHttp:HTTPController = HTTPController()
    
    //频道列表数据
    var channelData:[JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.alpha = 0.8
//        eHttp.delegate = self
        //获取频道数据
//        eHttp.onSearch("http://www.douban.com/j/app/radio/channels")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelData.count
    }

//    func didRecieveResults(results:AnyObject){
//        var json = JSON(results)
//        
//        if let channels = json["channels"].array{
//            self.channelData = channels
//            self.tv.reloadData()
//        }
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("channel", forIndexPath: indexPath) as! UITableViewCell
        //获取行数据
        var rowData:JSON = self.channelData[indexPath.row] as JSON
        //设置cell的标题
        cell.textLabel?.text = rowData["name"].string

        return cell
    }
    
    //选中了具体的频道
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var rowData:JSON = self.channelData[indexPath.row] as JSON
        delegate?.onChangeChannel(rowData["channel_id"].string!)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //设置cell的显示动画
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //设置cell的显示动画为3d缩放，xy方向的缩放动画，初始值为0.1 结束值为1
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }

}
