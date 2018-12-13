//
//  CBNavigationController.swift
//  CombOffice
//
//  Created by kunpan on 2017/1/23.
//  Copyright © 2017年 __MyCompanyName__. All rights reserved.
//

import UIKit
//Swift的枚举必须用@objc修饰，否则oc无法识别
@objc public enum CBNavigationBarType: Int{
    case Normal         //半透明
    case Translucent    //半透明
    case Black          //半透明
    case White          //半透明
    case WhiteOpaque    //不透明透明
    case Clear          //透明
}

class CBNavigationController: UINavigationController{
    // MARK ------ 属性
    public var canPush : Bool!  = true;
    public var canDragBack : Bool! = true;
    public var statusBarStyle : UIStatusBarStyle!;
    fileprivate var snapShotViewList : [UIView]!;           // 图片缓存对象
    fileprivate var startPoint : CGPoint!;
    fileprivate var isMoving : Bool! = false;
    fileprivate var isNavigating : Bool! = false;
    fileprivate var backgroundView : UIView!;               // push、pop中蒙层view对象
    fileprivate var blackMaskView : UIView!;
    fileprivate var lastScreenShotView : UIView!;           // translation 3d 操作的对象
    fileprivate var currenScreenShotView: UIView!           // pop的时候 操作的对象
    var rootViewController : UIViewController?;             // 容器
    fileprivate var panGesture : UIPanGestureRecognizer!;
    fileprivate var lastTouchPointX: CGFloat = 0.0
    fileprivate var panBeganFrame: CGRect!                  //侧滑手势开始时lastScreenShotView的frame
    
    // MARK ------ 系统接口
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated);
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.buildView();
        self.setNormalNavigationBar();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(rootViewController: UIViewController){
        super.init(rootViewController: rootViewController);
        self.canPush = true;
        // swift中 ? : 表达式必须是 三则的类型都是一样 。。。 而且 swift中目前没发现像object_c中 判断对象是否为空 操作!!!!
        //self.viewControllers = [rootViewController].count <= 0 ? [rootViewController] : [UIViewController]();
        self.canDragBack = true;// default 能拖拽
        self.isNavigating = false;
        
        self.snapShotViewList = [UIView]();
        self.rootViewController = nil;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        self.backgroundView.removeFromSuperview();
    }
    
    // MARK -- overrider
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return self.statusBarStyle;
    }
    
    // override pushViewControlller
    override func pushViewController(_ viewController: UIViewController, animated: Bool)
    {
        // 是否在动画过程中
        if(self.isNavigating == true){
            return;
        }
        // 是否是rootviewcontroller 根界面 针对呀 init rootViewController
        if(self.viewControllers.count <= 0){
            super.pushViewController(viewController, animated: animated);
            return;
        }
        // 是否需要push功能 ---  目前还没想到那个场景不需要push（note： 除了present）
        if(self.canPush == false){
            return;
        }
        // push、pop页面的animation 都是在rootviewcontroller中添加的操作
        self.getRootViewController();
        
        // push之后得到上一个界面的snapshot图片作为过渡动画
        let snapShot = self.rootViewController?.view.resizableSnapshotView(from: self.view.bounds,
                                                                           afterScreenUpdates: false,
                                                                           withCapInsets: UIEdgeInsets.zero);
        if(snapShot != nil){
            // 添加到 截图队列中
            self.snapShotViewList.append(snapShot!);
        }else{
            NSLog("snap screen fail !!!");
        }
        
        // 从有tabbar push 到一个没有tabbar的界面  隐藏tabbar
        if(self.rootViewController! is TabBarController && self.viewControllers.count == 1){
            // 在这里 需要重写一下tabbarcontrolller 实现隐藏tabbarcontrolller anniamtion
            let tabbarController = self.rootViewController as! TabBarController!;
//            tabbarController?.tabBarOutWithAnimation(animation: false);
            viewController.hidesBottomBarWhenPushed = true;
        }
        
        super.pushViewController(viewController, animated: false);
        
        // 下面代码针对动画设置
        if(animated == false){
            return;
        }
        
        self.lockUI();
        // 得到上一个界面 作为background添加到rootViewController.view上
        self.prepareTranstionViews(forRootViewController: false);
        // push的新界面从右侧进入(先将页面位置移到右侧)
        self.rootViewController?.view.frame = self.moveFrame(frame: (self.rootViewController?.view.frame)!, isIn: false);
        
        // annniamtion 
        self.blackMaskView.alpha = 0;
//        var sFrame: CGRect!
//        let screenShootFrame = self.lastScreenShotView.frame
//        sFrame = screenShootFrame
//        sFrame.origin.x -= screenShootFrame.size.width/3
    
        UIView.animate(withDuration: TimeInterval(kAnimationDurationNormal), animations: {
            self.rootViewController?.view.frame = self.moveFrame(frame: (self.rootViewController?.view.frame)!, isIn: true);
//            self.lastScreenShotView.frame = sFrame
            // 设置lastscreenView translation
            self.lastScreenShotView.transform = CGAffineTransform.init(scaleX: kFrameScale, y: kFrameScale);
            self.blackMaskView.alpha = kDarkAlpha;
            }) { _ in
                /// 在window上移除subview
                self.lastScreenShotView.removeFromSuperview();
                self.lastScreenShotView = nil;
                self.backgroundView.removeFromSuperview();
                self.unLockUI();
                self.endOnPush();
        }
        
    }
    
    // override popViewController
    override func popViewController(animated: Bool) -> UIViewController?{
        if(self.isNavigating == true){
            return nil;
        }
        // 得到rootViewController
        self.getRootViewController();
        // 开始截图当前的viewcontroller 以及调用外面的rootviewcontrolller中的方法通知
        self.beginToPop();
        // pop 动画操作
        if(animated == true){
            self.lockUI();
            self.prepareTranstionViews(forRootViewController: false);
            // 设置pop到的那个页面的transform
            self.lastScreenShotView.transform = CGAffineTransform.init(scaleX: kFrameScale, y: kFrameScale);
            self.blackMaskView.alpha = kDarkAlpha;
            
            var popedController : UIViewController? = nil;
//            var sFrame: CGRect!
//            sFrame = self.lastScreenShotView.frame
//            sFrame.origin.x += self.lastScreenShotView.width/3
            
            UIView.animate(withDuration: TimeInterval(kAnimationDurationNormal), animations: {
                self.moveViewWithX(x: kAppScreenWidth);
//                self.lastScreenShotView.frame = sFrame
                }, completion: { (finish : Bool) in
                    popedController = self.__popViewController();
                    var frame = self.rootViewController?.view.frame;
                    frame?.origin = CGPoint.zero;
                    self.rootViewController?.view.frame = frame!;
 
                    self.lastScreenShotView.removeFromSuperview();
                    self.lastScreenShotView = nil;
                    self.backgroundView.removeFromSuperview();
                    self.unLockUI();
            })
            return popedController;
        }else{
            return self.__popViewController();
        }
    }
    
    // override popToRootViewController
    override func popToRootViewController(animated: Bool) -> [UIViewController]?{
        if(self.isNavigating == true){
            return nil;
        }
        
        if(self.viewControllers.count <= 1){
            return super.popToRootViewController(animated: animated);
        }
        
        self.getRootViewController();
        self.beginToPop();
        // pop 动画操作
        if(animated == true){
            self.lockUI();
            self.prepareTranstionViews(forRootViewController: false);
            // 设置pop到的那个页面的transform
            self.lastScreenShotView.transform = CGAffineTransform.init(scaleX: kFrameScale, y: kFrameScale);
            self.blackMaskView.alpha = kDarkAlpha;
            
            var popedControllers : [UIViewController]? = nil;
            
            UIView.animate(withDuration: TimeInterval(kAnimationDurationNormal), animations: { [weak self] in
                self?.moveViewWithX(x: kAppScreenWidth);
                }, completion: { (finish : Bool) in
                    popedControllers = self.__popToRootViewController();
                    var frame = self.rootViewController?.view.frame;
                    frame?.origin = CGPoint.zero;
                    self.rootViewController?.view.frame = frame!;
                    
                    self.lastScreenShotView.removeFromSuperview();
                    self.lastScreenShotView = nil;
                    self.backgroundView.removeFromSuperview();
                    self.unLockUI();
            })
            return popedControllers;
        }else{
            return self.__popToRootViewController();
        }
    }
    
    
}

// MARK --- 创建试图
private extension CBNavigationController{
    func buildView(){
        self.backgroundView = UIView();
        
        self.blackMaskView = UIView();
        self.blackMaskView.backgroundColor = UIColor.black;
        self.blackMaskView.autoresizingMask = UIViewAutoresizing.flexibleWidth;
        self.backgroundView.addSubview(self.blackMaskView);
        
        self.lastScreenShotView = UIView();
        self.currenScreenShotView = UIView();
        
        // pangesutre
        self.panGesture = UIPanGestureRecognizer(target : self , action : #selector(onPan));
        self.panGesture.delegate = self;
        self.panGesture?.delaysTouchesBegan;
        self.view.addGestureRecognizer(self.panGesture);
    }
}

// MARK --- 外部接口
extension CBNavigationController{
    
    //Swift的方法必须用@objc 修饰，否则oc无法识别
    // 设置navigation是否可以滑动
    @objc public func setCanDragBack(isCanDrag : Bool){
        self.canDragBack = isCanDrag;
        self.panGesture?.isEnabled = self.canDragBack;
    }
    //Swift的方法必须用@objc 修饰，否则oc无法识别
    @objc public func setNavigationBar(type : CBNavigationBarType){
        switch type {
        case .Normal:
            self.setNormalNavigationBar();
            break;
        case .White:
            self.setWhiteNavigationBar();
            break;
        case .WhiteOpaque:
            self.setWhiteOpaqueNavigationBar();
            break;
        case .Black:
            self.setGrayNavigationBar();
            break;
        case .Clear:
            self.setClearNavigationBar();
            break;
        default:
            self.setNormalNavigationBar();
             break
        }
    }
    //Swift的方法必须用@objc 修饰，否则oc无法识别
    // 设置statusBarStyle
    @objc func setStatusBar(style : UIStatusBarStyle){
        self.statusBarStyle = style;
        UIApplication.shared.statusBarStyle = style;
    }
}

// MARK --- 内部接口
private extension CBNavigationController
{
    // 设置navigationBar style
    func setNormalNavigationBar(){
        var topBarImage : UIImage!;
//        topBarImage = UIImage.init(named: "topbar64_New");
//        topBarImage = topBarImage.resizableImage(withCapInsets: UIEdgeInsets.init(top: 20, left: 50, bottom: 20, right: 50));
        topBarImage = CBUtil.createImageWithColor(color: CBUtil.colorWithRGB(0xffffff));
        self.navigationBar.barTintColor = CBUtil.colorWithRGB(0xffffff);
        self.navigationBar.setBackgroundImage(topBarImage, for: UIBarMetrics.default);
        self.navigationBar.isTranslucent = true;
        self.navigationBar.barStyle = UIBarStyle.default;
        self.setStatusBar(style: UIStatusBarStyle.default);
        
        //去掉navigationBar下面的阴影线...
        self.navigationBar.setBackgroundImage(UIImage.init(), for: UIBarMetrics.default);
        self.navigationBar.shadowImage = UIImage.init();// named: "searchBar_bg"
        // 添加一个蒙层
        let shaowImage : UIImage = UIImage.init(named: "navigationShadowBg")!;//searchBar_bg
        let imageView : UIImageView = UIImageView.init();
        imageView.frame = CGRect.init(x: 0, y: kNavigationBarHeight  - 2, width: kAppScreenWidth, height: 5);
        imageView.image = shaowImage;
        imageView.backgroundColor = UIColor.clear;
//        imageView.layer.shadowPath
        self.navigationBar.addSubview(imageView);
 
    }
    
    func setGrayNavigationBar(){
        self.navigationBar.barTintColor = CBUtil.colorWithRGB(0x0);
        self.navigationBar.isTranslucent = true;
        self.navigationBar.barStyle = UIBarStyle.default;
        self.setStatusBar(style: UIStatusBarStyle.lightContent);
    }
    
    func setWhiteNavigationBar(){
        self.navigationBar.barTintColor = CBUtil.colorWithRGB(0xffffff);
        self.navigationBar.isTranslucent = true;
        self.navigationBar.barStyle = UIBarStyle.default;
        self.setStatusBar(style: UIStatusBarStyle.lightContent);
    }
    
    func setWhiteOpaqueNavigationBar(){
        self.navigationBar.barTintColor = CBUtil.colorWithRGB(0xffffff);
        self.navigationBar.isTranslucent = false;
        self.navigationBar.barStyle = UIBarStyle.default;
        self.setStatusBar(style: UIStatusBarStyle.lightContent);
    }
    
    func setClearNavigationBar(){
        UIGraphicsBeginImageContext(CGSize(width : 1,height : 1));
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        self.navigationBar.setBackgroundImage(image, for: UIBarMetrics.default);
        self.navigationBar.isTranslucent = true;
        self.navigationBar.barStyle = UIBarStyle.default;
        self.setStatusBar(style: UIStatusBarStyle.lightContent);
    }
    
    // 在push、pop 动画过程中设置window的userinterface 是否可以点击
    func lockUI(){
        self.isNavigating = true;
        let window : UIWindow = (((UIApplication.shared.delegate?.window)!)!);
        window.isUserInteractionEnabled = false;
        // 在swfit中performselector中没有afterdelay操作 主要是在swift中对gcd重新调整了
    }
    
    func unLockUI(){
        self.isNavigating = false;
        let window : UIWindow = ((UIApplication.shared.delegate?.window)!)!;
        window.isUserInteractionEnabled = true
    }
    
    // 是否让界面push、pop anniamtion完成之后 是否要通知viewcontroller做一些事情。。。
    func endOnPush(){
//        if(self.topViewController is RootViewController)
//        {
//            // TO DO:
//        }
    }

    func endOnPop(){
//        if(self.topViewController is RootViewController)
//        {
//            // TO DO:
//        }
    }
    
    // 得到rootViewController
    func getRootViewController(){
        if(self.parent != nil){
            self.rootViewController = self.parent!;
        }else{
            self.rootViewController = self;
        }
    }
    
    // 得到lastscreenview 再把backgroundview添加到rootview
    func prepareTranstionViews(forRootViewController : Bool){
        var  lastSnapView : UIView!;
        if(forRootViewController == true){
            lastSnapView = self.snapShotViewList.first;
        }else{
            lastSnapView = self.snapShotViewList.last;
        }
        
        self.lastScreenShotView = lastSnapView;
        self.backgroundView.addSubview(self.lastScreenShotView)
        
        self.backgroundView.insertSubview(self.lastScreenShotView, belowSubview: self.blackMaskView);
        
        // 根据屏幕orientation来获取当前的transform
        if(self.supportedInterfaceOrientations == UIInterfaceOrientationMask.landscapeRight){
            self.backgroundView.transform = CGAffineTransform.init(rotationAngle: -(CGFloat)(Double.pi/2));
        }else if(self.supportedInterfaceOrientations == UIInterfaceOrientationMask.landscapeLeft){
            self.backgroundView.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi/2));
        }else{
            self.backgroundView.transform = CGAffineTransform.identity;
        }
        
        self.backgroundView.frame = (self.rootViewController?.view.frame)!;
        self.blackMaskView.frame = (self.rootViewController?.view.frame)!;
        /// self.rootViewController isKindOfClass UINavigationController 的时候。view UILayoutContainerView 。superview uiwindow
        self.rootViewController?.view.superview?.insertSubview(self.backgroundView, belowSubview: (self.rootViewController?.view)!);
    }
    
    // push、pop的时候修改的rootViewController中的frame
    func moveFrame(frame : CGRect , isIn : Bool) -> CGRect{
        var newFrame = frame;
        var sign : CGFloat!;
        if(isIn == true){
            sign = CGFloat(-1);
        }else{
            sign = CGFloat(1);
        }
        newFrame.origin.x += sign * frame.size.width;
        return newFrame;
    }
    
    // ==================MARK -- Pop ==========================
    // 开始pop 截图当前的currentviewcontroller
    func beginToPop(){
        self.currenScreenShotView = self.rootViewController?.view.resizableSnapshotView(from: (self.rootViewController?.view.frame)!,
                                                                                        afterScreenUpdates: false,
                                                                                        withCapInsets: UIEdgeInsets.zero);
        self.rootViewController?.view.addSubview(self.currenScreenShotView);
        //加阴影，仿照原生效果
        self.currenScreenShotView.layer.shadowColor = UIColor.black.cgColor
        self.currenScreenShotView.layer.shadowOpacity = 0.5

        // TO DO : pop的时候是否需要rootviewcontroller do something
    }
    
    func __popViewController() -> UIViewController{
        if(self.currenScreenShotView != nil){
            self.currenScreenShotView.removeFromSuperview();
            self.currenScreenShotView = nil;
        }
        return self.systemPopViewController(animation: false);
    }
    
    // 返回rootViewConrtoller 
    func __popToRootViewController() -> [UIViewController]{
        if(self.currenScreenShotView != nil){
            self.currenScreenShotView.removeFromSuperview();
            self.currenScreenShotView = nil;
        }
        
        // 从不带tabbar页面pop到 带tabbar的页面
        if(self.rootViewController! is TabBarController && self.viewControllers.count > 1){
            // 在这里 需要重写一下tabbarcontrolller 实现隐藏tabbarcontrolller anniamtion
            let tabbarController = self.rootViewController as! TabBarController!;
//            tabbarController?.tabbarInWithAnimation(animation: false);
//            viewController.hidesBottomBarWhenPushed = true;
        }
        return super.popToRootViewController(animated: false)!;
    }
    
    func systemPopViewController(animation : Bool) ->UIViewController{
        // snapshotlist移除最后一个view
        self.snapShotViewList.removeLast();
        
        // 判断当前是否从不带tabbar pop到存在tabbar的
        if(self.rootViewController! is TabBarController && self.viewControllers.count == 2){
            // 在这里 需要重写一下tabbarcontrolller 实现隐藏tabbarcontrolller anniamtion
           let tabbarController = self.rootViewController as! TabBarController!;
//            tabbarController?.tabbarInWithAnimation(animation: false);
//            viewController.hidesBottomBarWhenPushed = true;
        }
        return super.popViewController(animated: animation)!;
    }
    
    // pop的时候设置lastscreenshotview的transform的缩放比例和背景的alpha
    func moveViewWithX(x:CGFloat){
        var tmpX = x;
        var frame = (self.rootViewController?.view.frame)!;
        if(x > kAppScreenWidth){
            tmpX = x;
        }else{
            tmpX = kAppScreenWidth;
        }
        
        if(x < 0){
            tmpX = 0;
        }else{
            tmpX = x;
        }
        
        frame.origin.x = tmpX;
//        print("====self.rootViewController.view.frame = %@,newFrame = %@===",self.rootViewController?.view.frame,frame);
        self.rootViewController?.view.frame = frame;
        let scale = (fabs(tmpX)/(fabs(kAppScreenWidth)*20)) + kFrameScale
        let alpha = kDarkAlpha - (fabs(tmpX)/(fabs(kAppScreenWidth)/kDarkAlpha));
        
        // 设置lastscreenshotview
        self.lastScreenShotView.transform = CGAffineTransform.init(scaleX: scale, y: scale);
        self.blackMaskView.alpha = alpha;
    }
}


// MARK --- 按钮监听
private extension CBNavigationController{
    @objc func onPan(panGesture : UIPanGestureRecognizer){
        if(self.viewControllers.count <= 1 || self.canDragBack == false){
            return;
        }
        
        let touchPoint  = panGesture.location(in: (UIApplication.shared.delegate?.window)!);
        if(panGesture.state == UIGestureRecognizerState.began){
            // 开始滑动
            self.isMoving = true;
            self.startPoint = touchPoint;
            
            self.getRootViewController();
            self.prepareTranstionViews(forRootViewController: false);
            
            self.panBeganFrame = self.lastScreenShotView.frame
    
            // 是否添加shadowView
        }else if(panGesture.state == UIGestureRecognizerState.ended){
            // 结束滑动
            // 判断当前x滑动的距离> 50 大于则pop页面
            if( (touchPoint.x - self.startPoint.x) > 0 && fabs(touchPoint.x - self.startPoint.x) > 50)
            {
//                self.beginToPop();
                // moveViewWithX
//                let deltaX = CGFloat(touchPoint.x - self.startPoint.x);
//                var tmpX: CGFloat!
//                if deltaX > 0  {
//                    if deltaX > kAppScreenWidth {
//                        tmpX = deltaX
//                    }else{
//                        tmpX = kAppScreenWidth
//                    }
//                }else{
//                    tmpX = 0
//                }
//                
//                var rFrame = (self.rootViewController?.view.frame)!
//                rFrame.origin.x = tmpX
//                
//                var sFrame = self.lastScreenShotView.frame
//                sFrame.origin.x = 0
//                let deleteX = CGFloat(touchPoint.x - (self.startPoint.x));

                UIView.animate(withDuration: TimeInterval(0.3), animations: {
//                    self.moveViewWithX(x: deleteX);
                    var CGframe = self.rootViewController?.view.frame;
                    CGframe?.origin.x = kAppScreenWidth;
                    self.rootViewController?.view.frame = CGframe!;
                    let scale = (fabs(kAppScreenWidth)/(fabs(kAppScreenWidth)*20)) + kFrameScale
                    let alpha = kDarkAlpha - (fabs(kAppScreenWidth)/(fabs(kAppScreenWidth)/kDarkAlpha));
                    
                    // 设置lastscreenshotview
                    self.lastScreenShotView.transform = CGAffineTransform.init(scaleX: scale, y: scale);
                    self.blackMaskView.alpha = alpha;
//                    self.moveViewWithX(x: kAppScreenWidth);
//                    self.rootViewController?.view.frame = rFrame;
//                    self.lastScreenShotView.frame = sFrame
                    self.isMoving = false;
                    }, completion: { (finsih : Bool) in
                        if finsih{
                            self.__popViewController();
                            var frame = self.rootViewController?.view.frame;
                            frame?.origin = CGPoint.zero;
                            self.rootViewController?.view.frame = frame!;
                            self.isMoving = false;
                            self.lastScreenShotView.removeFromSuperview();
                            self.backgroundView.removeFromSuperview();
                        }
                })
            }else{
                // 滑动的x<50 
                UIView.animate(withDuration: TimeInterval(kAnimationDurationNormal), animations: { 
                    self.moveViewWithX(x: 0);
                    self.isMoving = false;
                    self.lastScreenShotView.frame = self.panBeganFrame
                    }, completion: { (finsih : Bool) in
                        self.isMoving = false;
                        self.lastScreenShotView.removeFromSuperview();
                        self.backgroundView.removeFromSuperview();
                        if self.currenScreenShotView != nil{
                            self.currenScreenShotView.removeFromSuperview()
                            self.currenScreenShotView = nil
                        }
                })
            }
            
            self.lastTouchPointX = 0
            
        }else if(panGesture.state == UIGestureRecognizerState.cancelled){
            UIView.animate(withDuration: TimeInterval(kAnimationDurationNormal), animations: {
                self.moveViewWithX(x: 0);
                self.isMoving = false;
//                self.lastScreenShotView.frame = self.panBeganFrame
                }, completion: { (finsih : Bool) in
                    self.isMoving = false;
                    self.lastScreenShotView.removeFromSuperview();
                    self.backgroundView.removeFromSuperview();
            })
            
            self.lastTouchPointX = 0

            return;
        }else if (panGesture.state == UIGestureRecognizerState.changed){
//            let deltaX = touchPoint.x - self.lastTouchPointX
//            
//            var sFrame: CGRect!
//            sFrame = self.lastScreenShotView.frame
//            sFrame.origin.x = sFrame.origin.x + deltaX/3 > 0 ? 0 : sFrame.origin.x + deltaX/3
//            self.lastScreenShotView.frame = sFrame
//            self.lastTouchPointX = touchPoint.x
        }
        
        
        // 滑动的距离实时修改rootviewcontroller.frame
        if(self.isMoving == true){
            let deltaX = CGFloat(touchPoint.x - self.startPoint.x);
            self.moveViewWithX(x: deltaX);
        }
    }
}

// MARK -- 代理回调区
extension CBNavigationController : UIGestureRecognizerDelegate{
    
}
