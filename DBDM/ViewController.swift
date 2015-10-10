//
//  ViewController.swift
//  DBDM
//
//  Created by xly on 15/10/2.
//  Copyright (c) 2015年 Lily. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,HttpProtocol,ChannelProtocol{

    //EkoImage组件，歌曲封面
    @IBOutlet weak var iv: EkoImage!
    //歌曲列表
    @IBOutlet weak var tv: UITableView!
    //背景
    @IBOutlet weak var bg: UIImageView!
    
    //网络操作类的实例
    var eHttp:HTTPController = HTTPController()
    
    //定义一个变量，接收频道的歌曲数据
    var songData:[JSON] = []
    //频道列表数据
    var channelData:[JSON] = []
    //定义一个图片缓存的字典
    var imageCache = Dictionary<String,UIImage>()
    
    //申明一个媒体播放器的实例
    var audioPlayer:MPMoviePlayerController =  MPMoviePlayerController()
    
    //计时器
    var timer:NSTimer?
    @IBOutlet weak var playTime: UILabel!
    
    @IBOutlet weak var progress: UIImageView!
    //上一首按钮
    @IBOutlet weak var btnPre: UIButton!
    //播放按钮
    @IBOutlet weak var btnPlay: EkoButton!
    //下一首按钮
    @IBOutlet weak var btnNext: UIButton!
    //自定义按钮
    @IBOutlet weak var btnOrder: OrderButton!
    //当前是第几首歌
    var currentSongIndex:Int = 0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //旋转效果
        iv.onRotation()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        //旋转效果
//        iv.onRotation()
//        设置背景模糊
        var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        var blurView = UIVisualEffectView(effect: blurEffect)//效果视图
        blurView.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        bg.addSubview(blurView)
        
        //设置tbaleView的数据源和代理
        tv.dataSource = self
        tv.delegate = self
        //让tableView背景透明
        tv.backgroundColor = UIColor.clearColor()
        
        //为网络操作类设置代理
        eHttp.delegate = self
        //获取频道为0歌曲数据
        eHttp.onSearch("http://douban.fm/j/mine/playlist?type=n&channel=2&from=mainsite")
        //获取频道数据
        eHttp.onSearch("http://www.douban.com/j/app/radio/channels")
        
        //监听按钮点击
        btnPre.addTarget(self, action: "onClick:", forControlEvents: UIControlEvents.TouchUpInside)
        btnPlay.addTarget(self, action: "onPlay:", forControlEvents: UIControlEvents.TouchUpInside)
        btnNext.addTarget(self, action: "onClick:", forControlEvents: UIControlEvents.TouchUpInside)
        btnOrder.addTarget(self, action: "onOrder:", forControlEvents: UIControlEvents.TouchUpInside)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playFinish", name: MPMoviePlayerPlaybackDidFinishNotification, object: audioPlayer)//name:监听事件 object：监听实例
    }
    
    var isAutoFinish:Bool = true
    //人为结束的三种情况 1 点击上一首，下一首按钮  2 选择了频道列表的时候  3 点击了歌曲列表中的某一行的时候
    func playFinish(){
        
        if isAutoFinish{
            switch(btnOrder.order){
            case 1:
                //顺序播放
                currentSongIndex++
                if currentSongIndex > songData.count - 1 {
                    self.currentSongIndex = 0
                }
                onSelectRow(currentSongIndex)
            case 2:
                //随机播放
                currentSongIndex = random() % songData.count
                onSelectRow(currentSongIndex)
            case 3:
                //单曲循环
                onSelectRow(currentSongIndex)
            default:
                "default"
            }
        }else{
            isAutoFinish = true
        }
        
    }
    func onOrder(btn:OrderButton){
        
        var message:String = ""
        switch(btn.order){
        case 1:
            message = "顺序播放"
        case 2:
            message = "随机播放"
        case 3:
            message = "单曲循环"
        default:
            message = "你逗我的吧"
        }
        self.view.makeToast(message: message, duration: 0.5, position: "center")
    }
    
    func onClick(btn:UIButton){
        isAutoFinish = false
        if btn == btnPre{
            currentSongIndex--
            if currentSongIndex < 0{
                currentSongIndex = self.songData.count - 1
            }
        }else if btn == btnNext{
            currentSongIndex++
            if currentSongIndex > self.songData.count - 1{
                currentSongIndex = 0
            }
        }
        onSelectRow(currentSongIndex)
    }
    
    func onPlay(btn:EkoButton){
        if btn.isPlay{
            audioPlayer.play()
        }else{
            audioPlayer.pause()
        }
    }
    
    func didRecieveResults(results:AnyObject){
//        println("\(results)")
        var json = JSON(results)
        
        if let channels = json["channels"].array{
            self.channelData = channels
            self.tv.reloadData()
        }else if let songs = json["song"].array{
            self.songData = songs
            self.tv.reloadData()
            //设置第一首歌的图片以及背景
            onSelectRow(0)
            isAutoFinish = false
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCellWithIdentifier("douban") as! UITableViewCell
        //让cell背景透明
        cell.backgroundColor = UIColor.clearColor()
        
        //获取cell的数据
        var rowData:JSON = songData[indexPath.row]
        //设置cell的标题
        cell.textLabel?.text = rowData["title"].string
        cell.detailTextLabel?.text = rowData["artist"].string
        //设置缩略图
        cell.imageView?.image = UIImage(named: "thumb")
        //封面的网址
        let url = rowData["picture"].string

        onGetCacheImage(url!, imagView: cell.imageView!)
        
        return cell
    }
    
    //图片缓存策略方法
    func onGetCacheImage(url:String,imagView:UIImageView){
        //通过图片地址去缓存中取图片
        if let image = self.imageCache[url]{
            imagView.image = image
        }else{
            Alamofire.manager.request(Method.GET, url).response { (_, _, data, error) -> Void in
                var img = UIImage(data: data as! NSData)
                imagView.image = img
                self.imageCache[url] = img
            }
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        onSelectRow(indexPath.row)
        isAutoFinish = false
    }
    
    //选中了哪一行
    func onSelectRow(row:Int){
        
        currentSongIndex = row
        
        //构建一个indexPath
        var indexPath = NSIndexPath(forRow: row, inSection: 0)
        //选中的效果
        tv.selectRowAtIndexPath(indexPath!, animated: false, scrollPosition: UITableViewScrollPosition.Top)
        //获取行数据
        var rowData:JSON = self.songData[row] as JSON
        //获取该行图片的地址
        var imgUrl = rowData["picture"].string
        //设置封面以及背景
        onSetImage(imgUrl!)
        
        //获取音乐的文件地址
        var url:String = rowData["url"].string!
        //播放音乐
        onSetAudio(url)
    }
    
    //播放音乐的方法
    func onSetAudio(url:String){
        self.audioPlayer.stop()
        self.audioPlayer.contentURL = NSURL(string: url)
        self.audioPlayer.play()
        
        btnPlay.onPlay()
        
        //先停掉计时器
        timer?.invalidate()
        //将计时器归零
        playTime.text = "00:00"
        
        //启动计时器
        timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "onUpdate", userInfo: nil, repeats: true)
        isAutoFinish = true
    }
    
    //计时器更新方法
    func onUpdate(){
        // 00:00 获取播放器当前的播放时间 返回所有的秒数
        var c = audioPlayer.currentPlaybackTime
        
        if c > 0.0{
            
            //歌曲的总时间
            let t = audioPlayer.duration
    
            //计算百分比
            var percent:CGFloat = CGFloat(c/t)
            //按百分比显示进度条的宽度
            progress.frame.size.width = view.frame.size.width * percent
            
            var all = Int(c)
            //计算多少分
            var f = Int(all/60)
            //计算多少秒
            var m = all%60
            
            var time:String = ""
            if f < 10{
                time = "0\(f):"
            }else{
                time = "\(f):"
            }
            
            if m < 10{
                time += "0\(m)"
            }else{
                time += "\(m)"
            }
            playTime.text = time
            
        }
    }
    
    //设置歌曲的封面以及背景
    func onSetImage(url:String){
        onGetCacheImage(url, imagView: self.iv)
        onGetCacheImage(url, imagView: self.bg)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //获取跳转目标
        var channelC:ChannelController = segue.destinationViewController as! ChannelController
        //设置代理
        channelC.delegate = self
        channelC.channelData = channelData
    }
    
    //频道列表协议的回调方法
    func onChangeChannel(channel_id:String){
        //拼凑频道列表的歌曲数据网络地址
        //http://douban.fm/j/mine/playlist?type=n&channel= 频道id &from=mainsite
        let url:String = "http://douban.fm/j/mine/playlist?type=n&channel=\(channel_id)&from=mainsite"
        eHttp.onSearch(url)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songData.count
    }
    
    //设置cell的显示动画
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //设置cell的显示动画为3d缩放，xy方向的缩放动画，初始值为0.1 结束值为1
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

