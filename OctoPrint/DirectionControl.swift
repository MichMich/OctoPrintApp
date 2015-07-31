//
//  DirectionControl.swift
//  DirectionControl
//
//  Created by Michael Teeuw on 30/07/15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import UIKit

enum Direction {
	case Horizontal
	case Vertical
	case Both
}

@objc enum ArrowDirection:Int {
	case Up = 0
	case Down = 1
	case Left = 2
	case Right = 3
}

class DirectionControl: UIControl {
	
	var delegate:DirectionControlDelegate?

	override var enabled:Bool  {
		didSet{
			updateArrowVisibility()
			pointerView.enabled = enabled
		}
	}
	var lineWidth:CGFloat = 1.0 {
		didSet {
			pointerView.lineWidth = lineWidth
			setNeedsDisplay()
		}
	}
	var lineColor = UIColor(white: 0.5, alpha: 1) {
		didSet {
			pointerView.lineColor = lineColor
			setNeedsDisplay()
		}
	}
	var pointerColor = UIColor.blueColor() {
		didSet {
			pointerView.fillColor = pointerColor
		}
	}
	
	var arrowInset: CGFloat = 20 {didSet {setNeedsDisplay()}}
	var arrowSize: CGFloat = 10 {didSet {setNeedsDisplay()}}
	
	var allowedDirection: Direction = .Both {
		didSet {
			if allowedDirection != oldValue {
				updateArrowVisibility()
			}
		}
	}
	var direction: Direction? {
		didSet {
			if direction != oldValue {
				updateArrowVisibility()
			}
		}
	}
	var valueX: Float = 0 {
		didSet {
			if valueX > 1 {
				valueX = 1
			}
			if valueX < -1 {
				valueX = -1
			}
		}
	}
	var valueY: Float = 0 {
		didSet {
			if valueY > 1 {
				valueY = 1
			}
			if valueY < -1 {
				valueY = -1
			}
		}
	}
	
	var pointerSize: CGFloat = 30
	
	private var pointerView: PointerView!
	private var horizontalArrowLayer = CAShapeLayer()
	private var verticalArrowLayer = CAShapeLayer()
	
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var tapGestureRecognizer: UITapGestureRecognizer?
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
		setup()
	}
	
	func setup() {
		createPointer()
		
		layer.insertSublayer(horizontalArrowLayer, atIndex: 0)
		layer.insertSublayer(verticalArrowLayer, atIndex: 0)
		
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTapGesture:"))
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePanGesture:"))
        self.addGestureRecognizer(panGestureRecognizer!)
        self.addGestureRecognizer(tapGestureRecognizer!)
	}
    
    func handleTapGesture(gesture:UITapGestureRecognizer) {
        
        let upArrowPath = UIBezierPath()
        upArrowPath.moveToPoint(CGPoint(x: 0, y: 0))
        upArrowPath.addLineToPoint(CGPoint(x: frame.size.width/2, y: frame.size.height/2 - pointerSize/2))
        upArrowPath.addLineToPoint(CGPoint(x: frame.size.width, y: 0))
        upArrowPath.addLineToPoint(CGPoint(x: 0, y: 0))
        
        let downArrowPath = UIBezierPath()
        downArrowPath.moveToPoint(CGPoint(x: 0, y: frame.size.height))
        downArrowPath.addLineToPoint(CGPoint(x: frame.size.width/2, y: frame.size.height/2 + pointerSize/2))
        downArrowPath.addLineToPoint(CGPoint(x: frame.size.width, y: frame.size.height))
        downArrowPath.addLineToPoint(CGPoint(x: 0, y: frame.size.height))
        
        let leftArrowPath = UIBezierPath()
        leftArrowPath.moveToPoint(CGPoint(x: 0, y: 0))
        leftArrowPath.addLineToPoint(CGPoint(x: frame.size.width/2 - pointerSize/2, y: frame.size.height/2))
        leftArrowPath.addLineToPoint(CGPoint(x: 0, y: frame.size.height))
        leftArrowPath.addLineToPoint(CGPoint(x: 0, y: 0))
        
        let rightArrowPath = UIBezierPath()
        rightArrowPath.moveToPoint(CGPoint(x: frame.size.width, y: 0))
        rightArrowPath.addLineToPoint(CGPoint(x: frame.size.width/2 + pointerSize/2, y: frame.size.height/2))
        rightArrowPath.addLineToPoint(CGPoint(x: frame.size.width, y: frame.size.height))
        rightArrowPath.addLineToPoint(CGPoint(x: frame.size.width, y: 0))
        
        
        if upArrowPath.containsPoint(gesture.locationInView(self)) && (allowedDirection == .Vertical || allowedDirection == .Both) {
            delegate?.directionControlDidTapArrow?(self, arrow: .Up)
        } else if downArrowPath.containsPoint(gesture.locationInView(self)) && (allowedDirection == .Vertical || allowedDirection == .Both) {
            delegate?.directionControlDidTapArrow?(self, arrow: .Down)
        } else if leftArrowPath.containsPoint(gesture.locationInView(self)) && (allowedDirection == .Horizontal || allowedDirection == .Both) {
            delegate?.directionControlDidTapArrow?(self, arrow: .Left)
        } else if rightArrowPath.containsPoint(gesture.locationInView(self)) && (allowedDirection == .Horizontal || allowedDirection == .Both) {
            delegate?.directionControlDidTapArrow?(self, arrow: .Right)
        }
        
    }
	
	func handlePanGesture(gesture:UIPanGestureRecognizer) {
		let newValueX = Float((gesture.locationInView(self).x / frame.size.width) * 2 - 1)
		let newValueY = Float((gesture.locationInView(self).y / frame.size.height) * 2 - 1)
		
		if !enabled {
			direction = nil
			return
		}

		if allowedDirection == .Both {
			direction = (abs(newValueX) > abs(newValueY)) ? .Horizontal : .Vertical
		} else {
			direction = allowedDirection
		}
			
		valueX = (direction == .Horizontal) ? newValueX : 0
		valueY = (direction == .Vertical) ? newValueY : 0
		
		switch gesture.state {
			case .Began:
				
				if !CGRectContainsPoint(CGRectInset(pointerView.frame, -20, -20), gesture.locationInView(self)) {
					gesture.enabled = false
					gesture.enabled = true
				}
			
				break
			
			case .Changed:
				updatePointerLocation(false)
				delegate?.directionControlDidDrag?(self)
			
			case .Ended:
				sendActionsForControlEvents(UIControlEvents.ValueChanged)
				delegate?.directionControlDidRelease?(self)
				
			case .Failed, .Cancelled:
				reset()
                delegate?.directionControlDidCancel?(self)

				break
			default:
				updatePointerLocation(false)
				break

		}
		
		

	}
	
	func reset() {
		valueX = 0
		valueY = 0
		direction = nil
		updatePointerLocation(true)
	}
	
	func createPointer() {
		pointerView = PointerView(frame: CGRect(x: 0, y: 0, width: pointerSize, height: pointerSize))
		addSubview(pointerView!)
		pointerView!.backgroundColor = UIColor.clearColor()
	}
	
	
	func targetPointerFrame() -> CGRect {
		let offsetX:CGFloat = CGFloat(valueX) * self.frame.size.width / 2
		let offsetY:CGFloat = CGFloat(valueY) * self.frame.size.height / 2
		
		
		var frame = pointerView.frame
		frame.origin.x = self.frame.size.width / 2 - pointerSize / 2 + offsetX
		frame.origin.y = self.frame.size.height / 2 - pointerSize / 2 + offsetY
		
		return frame
	}

	func updateArrowVisibility() {
		verticalArrowLayer.opacity = enabled && (direction == .Vertical || direction == nil) && (allowedDirection == .Vertical || allowedDirection == .Both) ? 1 : 0
		horizontalArrowLayer.opacity = enabled && (direction == .Horizontal || direction == nil) && (allowedDirection == .Horizontal || allowedDirection == .Both) ? 1 : 0
	}

	
	func updatePointerLocation(animated:Bool) {

			if !animated {
				pointerView?.frame = targetPointerFrame()
				return
			}
	
			UIView.animateWithDuration(0.3,
				delay: 0,
				usingSpringWithDamping: 0.5,
				initialSpringVelocity: 1,
				options: UIViewAnimationOptions.AllowUserInteraction,
				animations: { () -> Void in
					pointerView?.frame = targetPointerFrame()
				}, completion: nil)
	}
	
	override func layoutSubviews() {
		updatePointerLocation(false)
	}
	
	func drawArrows() {
		
		horizontalArrowLayer.strokeColor = lineColor.CGColor
		horizontalArrowLayer.lineWidth = lineWidth
		
		verticalArrowLayer.strokeColor = lineColor.CGColor
		verticalArrowLayer.lineWidth = lineWidth
		
		
		// Draw Arrows
		let verticalArrows = UIBezierPath()
		
		// Up arrow
		verticalArrows.moveToPoint(CGPoint(x: frame.size.width / 2, y: arrowInset))
		verticalArrows.addLineToPoint(CGPoint(x: frame.size.width / 2 - arrowSize , y: arrowInset + arrowSize))
		verticalArrows.moveToPoint(CGPoint(x: frame.size.width / 2, y: arrowInset))
		verticalArrows.addLineToPoint(CGPoint(x: frame.size.width / 2 + arrowSize , y: arrowInset + arrowSize))
		
		// Down arrow
		verticalArrows.moveToPoint(CGPoint(x: frame.size.width / 2, y: frame.size.height - arrowInset))
		verticalArrows.addLineToPoint(CGPoint(x: frame.size.width / 2 - arrowSize , y: frame.size.height - arrowInset - arrowSize))
		verticalArrows.moveToPoint(CGPoint(x: frame.size.width / 2, y: frame.size.height - arrowInset))
		verticalArrows.addLineToPoint(CGPoint(x: frame.size.width / 2 + arrowSize , y: frame.size.height - arrowInset - arrowSize))
		
		verticalArrowLayer.path = verticalArrows.CGPath
		
		let horizontalArrows = UIBezierPath()
		
		// Left arrow
		horizontalArrows.moveToPoint(CGPoint(x: arrowInset, y: frame.size.height / 2))
		horizontalArrows.addLineToPoint(CGPoint(x: arrowInset + arrowSize, y: frame.size.height / 2 - arrowSize))
		horizontalArrows.moveToPoint(CGPoint(x: arrowInset, y: frame.size.height / 2))
		horizontalArrows.addLineToPoint(CGPoint(x: arrowInset + arrowSize, y: frame.size.height / 2 + arrowSize))
		
		// Right arrow
		horizontalArrows.moveToPoint(CGPoint(x: frame.size.width - arrowInset, y: frame.size.height / 2))
		horizontalArrows.addLineToPoint(CGPoint(x: frame.size.width - arrowInset - arrowSize, y: frame.size.height / 2 - arrowSize))
		horizontalArrows.moveToPoint(CGPoint(x: frame.size.width - arrowInset, y: frame.size.height / 2))
		horizontalArrows.addLineToPoint(CGPoint(x: frame.size.width - arrowInset - arrowSize, y: frame.size.height / 2 + arrowSize))
		
		horizontalArrowLayer.path = horizontalArrows.CGPath
		
	}
	
	override func drawRect(rect: CGRect) {
		lineColor.setStroke()
		
		let newRect = CGRectInset(rect, lineWidth, lineWidth)

		// Draw Outline
		let outline = UIBezierPath(roundedRect: newRect, cornerRadius: max(rect.size.width, rect.size.height))
		outline.lineWidth = lineWidth
		outline.stroke()
		
		drawArrows()
        
        
        
        


    }


}


@objc protocol DirectionControlDelegate {
    optional func directionControlDidCancel(directionControl:DirectionControl)
    optional func directionControlDidDrag(directionControl:DirectionControl)
	optional func directionControlDidRelease(directionControl:DirectionControl)
	optional func directionControlDidTapArrow(directionControl:DirectionControl, arrow:ArrowDirection)
}


class PointerView:UIView {
	var lineWidth:CGFloat = 1 {
		didSet {
			setNeedsDisplay()
		}
	}
	var fillColor = UIColor.blueColor() {
		didSet {
			setNeedsDisplay()
		}
	}
	var lineColor = UIColor.grayColor() {
		didSet {
			setNeedsDisplay()
		}
	}
	var enabled:Bool = true {
		didSet {
			setNeedsDisplay()
		}
	}
	override func drawRect(rect: CGRect) {
		fillColor.setFill()
		lineColor.setStroke()
		
		let path = UIBezierPath(ovalInRect: CGRect(x: lineWidth, y: lineWidth, width: self.frame.size.width - lineWidth * 2, height: self.frame.size.height - lineWidth * 2))
		
		if enabled {
			path.fill()
		} else {
			path.stroke()
		}
	}
}