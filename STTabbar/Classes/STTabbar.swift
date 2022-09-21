//
//  STTabbar.swift
//  Pods-STTabbar_Example
//
//  Created by Shraddha Sojitra on 19/06/20.
//

import Foundation
import UIKit

@IBDesignable
public final class STTabbar: UITabBar, UITabBarDelegate {
    
    // MARK:- Variables -
    @objc public var centerButtonActionHandler: ()-> () = {}

    @IBInspectable public var centerButtonColor: UIColor?
    @IBInspectable public var centerButtonHeight: CGFloat = 70.0
    @IBInspectable public var padding: CGFloat = 5.0
    @IBInspectable public var barHeight : CGFloat = 65
    @IBInspectable public var barTopRadius : CGFloat = 10
    @IBInspectable public var barBottomRadius : CGFloat = 20
    @IBInspectable public var tabbarColor: UIColor = UIColor.lightGray
    @IBInspectable public var unselectedItemColor: UIColor = UIColor.white
    @IBInspectable public var circleRadius : CGFloat = 40
    @IBInspectable var marginBottom : CGFloat = 5
    @IBInspectable var marginTop : CGFloat = 0
    let marginLeft : CGFloat = 15
    let marginRight : CGFloat = 15
    public var centerButton = UIButton()
    private var shapeLayer: CALayer?
    
    private func addShape() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeButtonImageAction(notification:)), name: Notification.Name("changeButtonImageActionIdentifier"), object: nil)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath()
        shapeLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.fillColor = tabbarColor.cgColor
        shapeLayer.lineWidth = 0
        
        //The below 4 lines are for shadow above the bar. you can skip them if you do not want a shadow
        shapeLayer.shadowOffset = CGSize(width:0, height:0)
        shapeLayer.shadowRadius = 10
        shapeLayer.shadowColor = UIColor.gray.cgColor
        shapeLayer.shadowOpacity = 0.3
        
        if let oldShapeLayer = self.shapeLayer {
            self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.layer.insertSublayer(shapeLayer, at: 0)
        }
        self.shapeLayer = shapeLayer
        self.tintColor = centerButtonColor
        self.unselectedItemTintColor = unselectedItemColor
        self.setupMiddleButton()
    }
    
    override public func draw(_ rect: CGRect) {
        self.addShape()
    }
        
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }
        for member in subviews.reversed() {
            let subPoint = member.convert(point, from: self)
            guard let result = member.hitTest(subPoint, with: event) else { continue }
            return result
        }
        return nil
    }

    private var barRect : CGRect{
        get{
            let h = self.barHeight
            let w = bounds.width - (marginLeft + marginRight)
            let x = bounds.minX + marginLeft
            let y = marginTop + circleRadius

            let rect = CGRect(x: x, y: y, width: w, height: h)
            return rect
        }
    }

    private lazy var background: CAShapeLayer = {
        let result = CAShapeLayer();
        result.fillColor = UIColor.white.cgColor
        result.mask = self.backgroundMask

        return result
    }()

    private lazy var backgroundMask : CAShapeLayer = {
        let result = CAShapeLayer()
        result.fillRule = CAShapeLayerFillRule.evenOdd
        return result
    }()

    private func setup(){
        self.isTranslucent = true
        self.backgroundColor = UIColor.clear
        self.backgroundImage = UIImage()
        self.shadowImage = UIImage()


        self.layer.insertSublayer(background, at: 0)
        //self.layer.insertSublayer(circle, at: 0)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = self.barHeight + marginTop + marginBottom + self.circleRadius + 15
        return sizeThatFits
    }
    
    private func createPath() -> CGPath {
        let h = frame.height
        let w = frame.width

        let rect = barRect
        let centerWidth = self.frame.width / 2
        let height: CGFloat = 37.0

        let path = UIBezierPath(roundedRect: CGRect(x: rect.minX + 20, y: rect.minY, width: w - 70, height: h - 70), cornerRadius: 50)

        path.move(to: CGPoint(x: rect.maxX, y: rect.minY)) // start top left
        path.addLine(to: CGPoint(x: (centerWidth - height * 2), y: rect.minY)) // the beginning of the trough

        path.addCurve(to: CGPoint(x: centerWidth, y: h/2),
                      controlPoint1: CGPoint(x: (centerWidth - 30), y: height), controlPoint2: CGPoint(x: centerWidth - 35, y: h/2))

        path.addCurve(to: CGPoint(x: (centerWidth + height * 2), y: rect.minY),
                      controlPoint1: CGPoint(x: centerWidth + 35, y: h/2), controlPoint2: CGPoint(x: (centerWidth + 30), y: height))

        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

        path.close()

        return path.cgPath
    }
    
	private func setupMiddleButton() {
		centerButton.removeFromSuperview()
		centerButton = UIButton(frame: CGRect(x: (self.bounds.width / 2)-(centerButtonHeight/2), y: -4, width: centerButtonHeight, height: centerButtonHeight))
		
		centerButton.layer.cornerRadius = centerButton.frame.size.width / 2.0
		if UserDefaults.standard.value(forKey: "IsTabBar") as! String == "FromChat"{
			centerButton.setImage(UIImage(named: "TabBar/UnselectedCenterButton"), for: .normal)
		}else{
			centerButton.setImage(UIImage(named: "TabBar/SelectedCenterbutton"), for: .normal)
		}
		
		centerButton.tintColor = UIColor.white
		
		//add to the tabbar and add click event
		self.addSubview(centerButton)
		
		centerButton.addTarget(self, action: #selector(self.centerButtonAction), for: .touchUpInside)
	}
    
    // Menu Button Touch Action
    @objc
    func centerButtonAction(sender: UIButton) {
        centerButton.setImage(UIImage(named: "TabBar/SelectedCenterbutton"), for: .normal)
        self.centerButtonActionHandler()
    }

    @objc
    func changeButtonImageAction(notification: Notification) {
        if UserDefaults.standard.string(forKey: "IsTabBar") ?? "" == "FromHome" {
            centerButton.setImage(UIImage(named: "TabBar/SelectedCenterbutton"), for: .normal)
        } else {
            centerButton.setImage(UIImage(named: "TabBar/UnselectedCenterButton"), for: .normal)
        }
    }

}

