//
//  CBUtil.swift
//  CombOffice
//
//  Created by kunpan on 2017/1/19.
//  Copyright © 2017年 __MyCompanyName__. All rights reserved.
//

import UIKit

class CBUtil: NSObject
{
    // 设置font size
    static func boldFontofSize(fontSize : CGFloat) -> UIFont
    {
        let font : UIFont = UIFont.systemFont(ofSize: fontSize);
        return font;
    }
    
    // 设置 color
    public static func colorWithRGB(_ code: Int) -> UIColor {
        let red = CGFloat(((code & 0xFF0000) >> 16)) / 255
        let green = CGFloat(((code & 0xFF00) >> 8)) / 255
        let blue = CGFloat((code & 0xFF)) / 255
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    public static func colorWithRGBAlpha(_ code: Int,alpha : Float) -> UIColor {
        let red = CGFloat(((code & 0xFF0000) >> 16)) / 255
        let green = CGFloat(((code & 0xFF00) >> 8)) / 255
        let blue = CGFloat((code & 0xFF)) / 255
        return UIColor(red: red, green: green, blue: blue, alpha: CGFloat(alpha));
    }
    
    // 通过color转换uiimage
    public static func createImageWithColor(color : UIColor) -> UIImage
    {
        let rect = CGRect(x:0.0, y:0.0, width:1.0, height:1.0);
        UIGraphicsBeginImageContext(rect.size);
        let  context = UIGraphicsGetCurrentContext();
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let theImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return theImage!;
    }
    
    // 邮箱
    public static func checkValidEmail(email : String) -> Bool
    {
        return CBUtil.checkVaildWithString(vaildString: email, regexString: "^([a-zA-Z0-9_\\-\\.]+)@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\\]?)$");
    }
    
    // 手机判断
   public static func checkValidMoblie(mobile : String) -> Bool
    {
        return CBUtil.checkVaildWithString(vaildString: mobile, regexString: "^[1]{1}[0-9]{10}$");
    }
    
    public static func checkVaildWithString(vaildString : String, regexString : String) -> Bool
    {
        var result = false;
        if(vaildString.count > 0)
        {
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@" ,regexString);
            result = emailPredicate.evaluate(with: vaildString);
        }
        return result;
    }
    
    // 日起转换
    public static func getTimerWithTimerSpace(timeSpace : Int) -> String
    {
        let dformatter = DateFormatter();
        dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        let timeSpaceDoub : Double = Double(timeSpace/1000);
        let timeInterval : TimeInterval = TimeInterval(timeSpaceDoub);
        let date = NSDate(timeIntervalSince1970: timeInterval);

        return dformatter.string(from: date as Date);
    }
    
    public static func getMothDayWithTimerSpace(timeSpace : Int) -> String
    {
        let dformatter = DateFormatter();
        dformatter.dateFormat = "yyyy-MM";
        let timeSpaceDoub : Double = Double(timeSpace/1000);
        let timeInterval : TimeInterval = TimeInterval(timeSpaceDoub);
        let date = NSDate(timeIntervalSince1970: timeInterval);
        
        return dformatter.string(from: date as Date);
    }
    
    // yyyy-mm-dd
    public static func getMothDayWithStringSpace(timeString : String, timeSpace : Int) -> String
    {
        let dformatter = DateFormatter();
        dformatter.dateFormat = timeString;
        let timeSpaceDoub : Double = Double(timeSpace/1000);
        let timeInterval : TimeInterval = TimeInterval(timeSpaceDoub);
        let date = NSDate(timeIntervalSince1970: timeInterval);
        
        return dformatter.string(from: date as Date);
    }
    
    // 拨打电话
    public static func houseMakePhoneCall(phoneString : String)
    {
        if(phoneString.count > 0)
        {
            let phoneNumberString = String.init(format: "tel://%@", phoneString);
            UIApplication.shared.openURL(NSURL.init(string: phoneNumberString) as! URL);
        }
    }
}



// 文件的读取
extension NSObject
{
//    public func readFromFile(filePath : String) -> Any
//    {
//        let data = NSKeyedUnarchiver.unarchiveObject(withFile: filePath);
//        return data;
//    }
    
    public func writeToFile(filePath : String)
    {
        var queue : DispatchQueue?;
        DispatchQueue.once(token: "com.combplus") {
            queue = DispatchQueue(label : "com.combplus.writerFileQueueString" );
        }
        queue?.async {
            NSKeyedArchiver.archiveRootObject(self, toFile: filePath);
        }
    }
}

// dispatchqueue 实现dispatch_once 
public extension DispatchQueue
{
    private static var onceToken = [String]();
    public class func once(token : String, block : @escaping() -> Void)
    {
        objc_sync_enter(self);
        defer
        {
            objc_sync_exit(self);
        }
        if(onceToken.contains(token))
        {
            return;
        }
        onceToken.append(token);
        block();
    }
}

////=================================================
//class CBEnlargeHitTestButton : UIButton
//{
//    public var enlargeHitTestInsetSize : CGSize!;
//    
//    override init(frame: CGRect)
//    {
//        super.init(frame: frame);
//        self.enlargeHitTestInsetSize = CGSize.zero;
//        self.isExclusiveTouch = true;
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
