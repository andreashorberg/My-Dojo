//
//  LargeTileCollectionViewCell.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-10-26.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import UIKit

class LargeTileCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var button: UIButton!
    
    open var mapImage: UIImage?
    open var isDojoSelected = false
    open var delegate: MenuItemDelegate?
    open var action: String?
    
    fileprivate var dojoImageView: UIImageView?
    fileprivate var myDojoButtonBlur: UIVisualEffectView?
    fileprivate var getDojoObserver: NSObjectProtocol?
    
    
    override func draw(_ rect: CGRect) {
        
        if getDojoObserver == nil {
            getDojoObserver = NotificationCenter.default.addObserver(forName: .getDojoNotification, object: nil, queue: OperationQueue.main) { [unowned self] notification in
                if let dojo = notification.userInfo?["dojo"] as? Dojo {
                    DispatchQueue.main.async { [unowned self] in
                        self.mapImage = dojo.mapImage as! UIImage?
                    }
                    self.isDojoSelected = true
                } else {
                    self.isDojoSelected = false
                    DispatchQueue.main.async {
                        self.removeButtonEffects()
                    }
                }
            }
        }

        // Drawing code
        DispatchQueue.main.async { [unowned self] in
            if let image = self.mapImage, self.isDojoSelected {
                self.dojoImageView = UIImageView(image: #imageLiteral(resourceName: "Dojo"))
                self.dojoImageView?.tag = 100
                
                if self.button.image(for: UIControlState.normal) != image {
                    self.button.setImage(image, for: .normal)
                    self.button.setImage(image, for: .highlighted)

                    var 🛠_TODO_REPLACE_IMAGE_WITH_LABEL: Any?
                    self.dojoImageView!.center.x = self.bounds.midX
                    self.dojoImageView!.center.y = self.bounds.midY
                    
                    self.button.insertSubview(self.dojoImageView!, at: 0)
                    self.button.bringSubview(toFront: self.dojoImageView!)
                }
                if self.myDojoButtonBlur == nil {
                    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
                    self.myDojoButtonBlur = UIVisualEffectView(effect: blurEffect)
                    self.myDojoButtonBlur!.frame = self.bounds
                    self.myDojoButtonBlur!.isUserInteractionEnabled = false //Forward touches to the UIButton
                    self.button.insertSubview(self.myDojoButtonBlur!, belowSubview: self.dojoImageView!)
                } else if self.myDojoButtonBlur!.isHidden {
                    self.myDojoButtonBlur!.isHidden = false
                }
            } else {
                self.removeButtonEffects()
            }
        }
    }
    
    fileprivate func removeButtonEffects()
    {
        self.button.setImage(nil, for: UIControlState.highlighted)
        self.button.setImage(nil, for: UIControlState.normal)

        self.button.viewWithTag(100)?.removeFromSuperview()
        self.myDojoButtonBlur?.isHidden = true
        self.setNeedsDisplay()

    }
    
    func blur(button: UIButton, show: Bool, duration: Double)
    {
        guard let blur = self.myDojoButtonBlur else { return }

        DispatchQueue.main.async {
            UIView.transition(with: button, duration: duration, options: .transitionCrossDissolve, animations: { blur.isHidden = show }, completion: nil)
        }
    }
    
    @IBAction func myDojoAction(_ sender: UIButton) {
        if delegate != nil, action != nil, !(action?.isEmpty)! {
            self.buttonAction(sender)
        } else {
            DatabaseManager.getDojo(from: sender)
            self.blur(button: self.button, show: false, duration: Constants.buttonTransitionDuration)
        }
    }
    
    @IBAction func myDojoButtonHideBlur(_ sender: UIButton) {
        self.blur(button: self.button, show: true, duration: Constants.buttonTransitionDuration)
    }
    
    @IBAction func myDojoButtonShowBlur(_ sender: UIButton) {
        self.blur(button: self.button, show: false, duration: Constants.buttonTransitionDuration)
    }
}

extension LargeTileCollectionViewCell: MenuItemCell {
    func buttonAction(_ sender: UIButton) {
        delegate?.menuButtonAction(with: action!)
    }
}
 
