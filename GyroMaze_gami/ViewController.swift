//
//  ViewController.swift
//  GyroMaze_gami
//
//  Created by Yuki.F on 2015/11/26.
//  Copyright © 2015年 Yuki Futagami. All rights reserved.
//

import UIKit
import CoreMotion


class ViewController: UIViewController {
    
    var playerView: UIView!
    var playerMotionManager: CMMotionManager!
    var speedX: Double = 0.0
    var speedY: Double = 0.0
    
    let screenSize = UIScreen.mainScreen().bounds.size
    /*
    0:プレイヤーの通れる場所
    1:壁
    2:スタート
    3:ゴール
    4:ワープポイント
    5:ワープ移動ポイント
    */
    let maze = [
        [1, 0, 0, 0, 1, 4],
        [1, 0, 1, 0, 1, 0],
        [1, 0, 1, 0, 1, 0],
        [1, 0, 1, 5, 1, 0],
        [1, 0, 0, 1, 1, 0],
        [1, 1, 0, 1, 1, 0],
        [0, 0, 0, 1, 0, 0],
        [0, 1, 1, 1, 0, 1],
        [0, 0, 0, 1, 0, 0],
        [1, 1, 3, 1, 1, 2],
    ]
    var goalView: UIView!
    var startView: UIView!
    var warpGoView: UIView!
    var warpComeView: UIView!
    
    var isIntoWarpView: Bool = false
    var warpTimer:NSTimer!
    var warpCountNumber: Double = 0.0

    
    var wallRectArray = [CGRect]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let cellWidth = screenSize.width / CGFloat(maze[0].count) // 6
        let cellHeight = screenSize.height / CGFloat(maze.count)//10
        
        let cellOffsetX = screenSize.width / CGFloat(maze[0].count * 2)
        let cellOffsetY = screenSize.height / CGFloat(maze.count * 2)
        
        for y in 0 ..< maze.count {
            for x in 0 ..< maze[y].count {
                switch maze[y][x] {
                case 1:
                    let wallView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    wallView.backgroundColor = UIColor.blackColor()
                    view.addSubview(wallView)
                    wallRectArray.append(wallView.frame)
                case 2:
                    startView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    startView.backgroundColor = UIColor.greenColor()
                    self.view.addSubview(startView)
                case 3:
                    goalView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    goalView.backgroundColor = UIColor.redColor()
                    self.view.addSubview(goalView)
                case 4:
                    warpGoView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    warpGoView.backgroundColor = UIColor.blueColor()
                    self.view.addSubview(warpGoView)
                case 5:
                    warpComeView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    warpComeView.backgroundColor = UIColor.blueColor()
                    self.view.addSubview(warpComeView)
                default:
                    break
                }
            }
        }
        
        playerView = UIView(frame: CGRectMake(0 , 0, screenSize.width / 36, screenSize.height / 60))
        playerView.center = startView.center
        playerView.backgroundColor = UIColor.grayColor()
        self.view.addSubview(playerView)
        
        // MotionManagerを生成.
        playerMotionManager = CMMotionManager()
        playerMotionManager.accelerometerUpdateInterval = 0.02
        
        self.startAccelerometer()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createView(x x: Int, y: Int, width: CGFloat, height: CGFloat, offsetX: CGFloat = 0, offsetY: CGFloat = 0) -> UIView {
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        let view = UIView(frame: rect)
        
        let center = CGPoint(
            x: offsetX + width * CGFloat(x),
            y: offsetY + height * CGFloat(y)
        )
        
        view.center = center
        return view
    }
    
    func startAccelerometer() {
        
        // 加速度を取得する
        let handler:CMAccelerometerHandler = {(accelerometerData:CMAccelerometerData?, error:NSError?) -> Void in
            
            self.speedX += accelerometerData!.acceleration.x
            self.speedY += accelerometerData!.acceleration.y
            
            var posX = self.playerView.center.x + (CGFloat(self.speedX) / 3)
            var posY = self.playerView.center.y - (CGFloat(self.speedY) / 3)
            
            if posX <= (self.playerView.frame.width / 2) {
                self.speedX = 0
                posX = self.playerView.frame.width / 2
            }
            if posY <= (self.playerView.frame.height / 2) {
                self.speedY = 0
                posY = self.playerView.frame.height / 2
            }
            if posX >= (self.screenSize.width - (self.playerView.frame.width / 2)) {
                self.speedX = 0
                posX = self.screenSize.width - (self.playerView.frame.width / 2)
            }
            if posY >= (self.screenSize.height - (self.playerView.frame.height / 2)) {
                self.speedY = 0
                posY = self.screenSize.height - (self.playerView.frame.height / 2)
            }
            
            for wallRect in self.wallRectArray {
                if (CGRectIntersectsRect(wallRect,self.playerView.frame)){
                    self.gameCheck("GameOver", message: "壁に当たりました。")
                    return
                }
            }
            
            if (CGRectIntersectsRect(self.warpGoView.frame,self.playerView.frame)){
                if self.isIntoWarpView == false {
                    print("timer呼ばれた")
                    self.warpTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "up", userInfo: nil, repeats: true)
                    self.warpTimer.fire()
                }
                self.isIntoWarpView = true
            }else{
                self.isIntoWarpView = false
            }
            
            if (CGRectIntersectsRect(self.goalView.frame,self.playerView.frame)){
                self.gameCheck("Clear!",message: "クリアしました！")
                return
            }
            self.playerView.center = CGPointMake(posX, posY)
        }
        // 加速度の開始
        playerMotionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: handler)
        
    }
    func up() {
        warpCountNumber = warpCountNumber + 0.1
        if warpCountNumber >= 2.0 {
                self.warpMove()
        }
    }
    
    func warpMove() {
        warpTimer.invalidate()
        warpCountNumber = 0.0
        playerView.center = warpComeView.center
    }
    
    
    func gameCheck(result:String,message:String){
        
        //加速度を止める
        if playerMotionManager.accelerometerActive {
            playerMotionManager.stopAccelerometerUpdates()
        }
        
        let gameCheckAlert: UIAlertController = UIAlertController(title:result, message:message, preferredStyle: .Alert)
        
        let retryAction = UIAlertAction(title: "もう一度", style: .Default) { action in
            self.retry()
        }
        
        gameCheckAlert.addAction(retryAction)
        
        self.presentViewController(gameCheckAlert, animated: true, completion: nil)
    }
    
    func retry() {
        
        //　位置を初期化
        playerView.center = startView.center
        
        // 加速度を始める
        if !playerMotionManager.accelerometerActive {
            self.startAccelerometer()
        }
        // スピードを初期化
        speedX = 0.0
        speedY = 0.0
    }
    
    
    
}

