//
//  CGFloat+Extensions.swift
//  Pods
//
//  Created by Andrew Boryk on 6/28/17.
//
//

public extension CGFloat {
    
    enum Buffer: CGFloat {
        case statusBar = 20
        case navigationBar = 44
        case tabBar = 49
    }
    
    /// Ratio for portrait view (16.0 / 9.0)
    static let portraitRatio: CGFloat = 16.0 / 9.0
    
    /// Ratio for portrait view (9.0 / 16.0)
    static let landscapeRatio: CGFloat = 9.0 / 16.0
    
    /// Ratio for a square view (1.0)
    static let squareRatio: CGFloat = 1.0
    
    /// Height of the status bar
    static let statusBarBuffer: CGFloat = {
        return UIScreen.isX ? Buffer.navigationBar.rawValue : Buffer.statusBar.rawValue
    }()
    
    /// Height of the navigation bar
    static let navigationBarBuffer = Buffer.navigationBar.rawValue
    
    /// Height of the status bar and the navigation bar combined
    static let statusAndNavigationBufferX: CGFloat = {
        return Buffer.navigationBar.rawValue + .statusBarBuffer
    }()
    
    /// Height of the tab bar
    static let tabBarBuffer = Buffer.tabBar.rawValue
    
    /// CGFloat as a TimeInterval
    var time: TimeInterval {
        return TimeInterval(self)
    }
    
    mutating func clamp(lower: CGFloat? = nil, upper: CGFloat? = nil) {
        if let lower = lower, self < lower {
            self = lower
        } else if let upper = upper, self > upper {
            self = upper
        }
    }
}
