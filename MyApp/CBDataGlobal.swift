//
//  CBDataGlobal.swift
//  CombOffice
//
//  Created by kunpan on 2017/1/19.
//  Copyright © 2017年 __MyCompanyName__. All rights reserved.
//

import UIKit

let kNavigationBarHorHeight : CGFloat = 32
let kNavigationBarVerHeight : CGFloat = 44
let kSystemStatusBarHeight : CGFloat = 20

//电池栏高度
let kStatusBarHeight = kSystemStatusBarHeight
//导航栏高度
let kNavigationBarHeight = kNavigationBarVerHeight
//页面上顶栏的高度
let kTopBarHeight = kStatusBarHeight + kNavigationBarHeight
//页面tab栏的高度
let kTabBarHeight : CGFloat = 49
//系统键盘高度
let kSystemKeyboardHeight : CGFloat = 216
let kSystemKeyboardWithCandidatePanelHeight : CGFloat = 252

//导航栏字体大小
let kStatusBarFontSize : CGFloat = 10

// navigation bar titleFontSize
let kBarButtonTitleFontSize : CGFloat = 15
// navigation title View font size 
let kTitleLabelFontSize : CGFloat = 16
// navigation titleView
let kTitleViewMaxWidth :CGFloat  = 220;
let kTitleViewHeight :CGFloat       = 44

// 屏幕的高度，宽度
let kAppScreenHeight = UIScreen.main.bounds.height
let kAppScreenWidth  = UIScreen.main.bounds.width

// 缓存文件路径
public enum FileHandlePathType
{
    case Document
    case Bundle
    case Cache
}

let kBaseDocumentDirecttoryName : String = "CB_Document"

// navigation global define
let kDarkAlpha : CGFloat = 0.6
let kFrameScale : CGFloat = 0.95
let kAnimationDurationNormal  : CGFloat = 0.30

// 机型的判断
//let IS_IPHONE4 (UIScreen.main.bounds.size.height - CGFloat(480)) ? false : true
let IPHONE4  : CGFloat = 480
let IPHONE5  : CGFloat = 568
let IPHONE6  : CGFloat = 375
let IPHONE6P: CGFloat = 414

// cellLeftDefaultMarger 
let kCellLeftMarger : CGFloat = 20
let kSeparatorLineLeftMarger : CGFloat = 10

// 员工管理 kIsPushEmployeeManagerVC表示是leftviewcontroller中push到下一个界面  false 这表示 是slidemenu.mainview addchildenview
let kIsPushEmployeeManagerVC    : Bool = true;

// 默认点击的是那一个leftViewController select
var kIsDefaultSelectIndex       :  Int   = 0;           // 默认选中的是第一个

// 所有请求的通用字段
let kResponseRetCode       =  "error_code"
let kResponseRetMsg        =  "error_msg"
let kResponseData             =  "data"

// 返回成功code定义
let kResponseSuccessRetCode  = "0"
// 服务器出错
let kResponseServerError  = "500"

// 登录中token用户过期
let kResponseTokenUnValid       = "100"

// 默认加载一页数据为20 条
let kDefaultPageCount           = 20
// 同意的网络错误返回的提示语
let kDefaultErrorString = "请求失败,请稍后重试!"

//=====================================通知管理区===========================================
// 登录成功之后发起的通知
let kNotificationLoginStatusChanged           =  "kNotificationLoginStatusChanged"
let kTokenUnvaildNoti                                 =  "tokenUnVaildNotification"
