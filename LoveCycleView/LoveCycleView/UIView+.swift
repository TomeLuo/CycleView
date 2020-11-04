//
//  UIView+.swift
//  LoveCycleView
//
//  Created by 童川 on 2019/12/3.
//  Copyright © 2019 Tom. All rights reserved.
//

import Foundation
import UIKit
import DeviceKit

extension UIView {
    
    /// 竖屏
    var safeInsets: UIEdgeInsets {
        if Device().isTenSeries {
            return UIEdgeInsets(top: 44, left: 0, bottom: 34, right: 0)
        }
        return .zero
    }
    
    var x: CGFloat {
        return frame.origin.x
    }
    
    var y: CGFloat {
        return frame.origin.y
    }
    
    var size: CGSize {
        return frame.size
    }
    
    var width: CGFloat {
        return frame.width
    }
    
    var height: CGFloat {
        return frame.height
    }
    class var naviBarHeight: CGFloat {
        return 44
    }
    class var tabBarHeight: CGFloat {
        return 49
    }
}

extension Device {

    /// 是否iPhoneX系列
    var isTenSeries: Bool {
        switch self {
        case .simulator(let d):
            return d.isTenSeries
        default:
            break
        }
        return self == .iPhoneX || self == .iPhoneXr || self == .iPhoneXs || self == .iPhoneXsMax
    }

    var isFourInchScreen: Bool {
        switch self {
        case .simulator(let d):
            return d.isFourInchScreen
        default:
            break
        }
        return self == .iPhone5 || self == .iPhone5c || self == .iPhoneSE || self == .iPhone5s
    }
}
