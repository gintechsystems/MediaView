//
//  UIScreen+Extensions.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/24/17.
//

public extension UIScreen {
    
    /// Derived by whether the width of the screen is less than the height of the screen
    static var isPortrait: Bool {
        return UIScreen.superviewWidth < UIScreen.superviewHeight
    }
    
    /// Derived by whether the height of the screen is less than the width of the screen
    static var isLandscape: Bool {
        return UIScreen.superviewHeight < UIScreen.superviewWidth
    }
    
    /// Bounds of the main screen
    static var rect: CGRect {
        return UIScreen.main.bounds
    }
    
    /// Width of the main screen
    static var width: CGFloat {
        return UIScreen.rect.width
    }
    
    /// Height of the main screen
    static var height: CGFloat {
        return UIScreen.rect.height
    }
    
    /// Width of the mainWindow, adjusted for orientation
    static var superviewWidth: CGFloat {
        if UIDevice.current.orientation.isLandscape {
            return width > height ? width : height
        } else {
            return width > height ? height : width
        }
    }
    
    /// Height of the mainWindow, adjusted for orientation
    static var superviewHeight: CGFloat {
        if UIDevice.current.orientation.isLandscape {
            return width > height ? height : width
        } else {
            return width > height ? width : height
        }
    }
    
    /// Determines if device is iPhone X
    static var isX: Bool {
        return Int(UIApplication.shared.statusBarFrame.height) == 44
    }
}
