//
//  HudView.swift
//  PocketHTTP
//
//  Created by 朱子秋 on 2017/1/29.
//  Copyright © 2017年 朱子秋. All rights reserved.
//

import UIKit

class HUDView: UIView {
    
    private var text: String!
    private var image: UIImage!
    private var activityIndicator: UIActivityIndicatorView?
    
    // make an HUD view with text and image
    class func hud(inView view: UIView, animated: Bool, withText text: String, andImage image: UIImage) -> HUDView {
        let hudView = HUDView(frame: view.bounds)
        hudView.text = text
        hudView.image = image
        hudView.isOpaque = false
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        hudView.show(animated: animated)
        return hudView
    }
    
    // make an HUD view with activity indicator
    class func indicatorHUD(inView view: UIView, animated: Bool) -> HUDView {
        let hudView = HUDView(frame: view.bounds)
        hudView.activityIndicator = UIActivityIndicatorView()
        hudView.activityIndicator!.activityIndicatorViewStyle = .whiteLarge
        hudView.isOpaque = false
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        hudView.show(animated: animated)
        return hudView
    }
    
    override func draw(_ rect: CGRect) {
        // draw background
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        let boxRect = CGRect(x: round((bounds.size.width - boxWidth) / 2), y: round((bounds.size.height - boxHeight) / 2), width: boxWidth, height: boxHeight)
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        if activityIndicator == nil {
            // draw text
            let attribs = [NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.white]
            let textSize = text.size(attributes: attribs)
            let textPoint = CGPoint(x: center.x - round(textSize.width / 2), y: center.y - round(textSize.height / 2) + boxHeight / 4)
            text.draw(at: textPoint, withAttributes: attribs)
            
            // draw image
            let imagePoint = CGPoint(x: center.x - round(image.size.width / 2), y: center.y - round(image.size.height / 2) - boxHeight / 8)
            image.draw(at: imagePoint)
        }
    }
    
    func show(animated: Bool) {
        // show activity indicator if needed
        if let activityIndicator = activityIndicator {
            activityIndicator.center = CGPoint(x: center.x, y: center.y)
            addSubview(activityIndicator)
            activityIndicator.startAnimating()
        }
        
        // make animation
        if animated {
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
    
    func hide() {
        superview!.isUserInteractionEnabled = true
        removeFromSuperview()
    }
    
}
