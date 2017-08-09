//
//  ViewController.swift
//  DynamicWriting
//
//  Created by ddd on 17/8/9.
//  Copyright © 2017年 HuangDong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var showView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //开始绘制
    @IBAction func startDraw(_ sender: Any) {

        self.showView.layer.sublayers?.forEach({ (sublayer) in
            sublayer.removeFromSuperlayer()
        })
        
        if (self.contentTextField.text?.characters.count)! > 0 {
            let bezierPath = self.changeBezierPathFrom(self.contentTextField.text!)
            let layer = CAShapeLayer.init()
            layer.bounds = bezierPath.cgPath.boundingBox
            layer.position = CGPoint(x: self.view.bounds.size.width/2, y: 50)
            layer.isGeometryFlipped = true
            layer.path = bezierPath.cgPath
            layer.fillColor = UIColor.clear.cgColor
            layer.lineWidth = 1
            layer.strokeColor = UIColor.black.cgColor
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = Double(layer.bounds.size.width)/20
            layer.add(animation, forKey: nil)
            self.showView.layer.addSublayer(layer)
            
            let penImage = UIImage(named: "pencil.png")
            let penLayer = CALayer()
            penLayer.contents = penImage?.cgImage
            penLayer.anchorPoint = CGPoint.zero
            penLayer.frame = CGRect(x: 0, y: 0, width: (penImage?.size.width)!, height: (penImage?.size.height)!)
            layer.addSublayer(penLayer)
            
            let penAnimation = CAKeyframeAnimation.init(keyPath: "position")
            penAnimation.duration = animation.duration
            penAnimation.path = layer.path
            penAnimation.calculationMode = kCAAnimationPaced
            penAnimation.isRemovedOnCompletion = false
            penAnimation.fillMode = kCAFillModeForwards
            penLayer.add(penAnimation, forKey: "position")
            penLayer.perform(#selector(CALayer.removeFromSuperlayer), with: nil, afterDelay: penAnimation.duration + 0.2)
            
        }
        
    }
    func changeBezierPathFrom(_ string:String) -> UIBezierPath{
        
        let paths = CGMutablePath()
        let fontName = __CFStringMakeConstantString("SnellRoundhand")
        let fontRef:AnyObject = CTFontCreateWithName(fontName, 18, nil)
        
        let attrString = NSAttributedString(string: string, attributes: [kCTFontAttributeName as String : fontRef])
        let line = CTLineCreateWithAttributedString(attrString as CFAttributedString)
        let runA = CTLineGetGlyphRuns(line)
        
        
        for runIndex in 0 ..< CFArrayGetCount(runA){
            let run = CFArrayGetValueAtIndex(runA, runIndex);
            let runb = unsafeBitCast(run, to: CTRun.self)
            
            let  CTFontName = unsafeBitCast(kCTFontAttributeName, to: UnsafeRawPointer.self)
            
            let runFontC = CFDictionaryGetValue(CTRunGetAttributes(runb),CTFontName)
            let runFontS = unsafeBitCast(runFontC, to: CTFont.self)
            
            let width = UIScreen.main.bounds.width
            
            var temp = 0
            var offset:CGFloat = 0.0
            
            for i in 0 ..< CTRunGetGlyphCount(runb){
                let range = CFRangeMake(i, 1)
                let glyph:UnsafeMutablePointer<CGGlyph> = UnsafeMutablePointer<CGGlyph>.allocate(capacity: 1)
                glyph.initialize(to: 0)
                let position:UnsafeMutablePointer<CGPoint> = UnsafeMutablePointer<CGPoint>.allocate(capacity: 1)
                position.initialize(to: CGPoint.zero)
                CTRunGetGlyphs(runb, range, glyph)
                CTRunGetPositions(runb, range, position);
                
                let temp3 = CGFloat(position.pointee.x)
                let temp2 = (Int) (temp3 / width)
                let temp1 = 0
                if(temp2 > temp1){
                    
                    temp = temp2
                    offset = position.pointee.x - (CGFloat(temp) * width)
                }
                let path = CTFontCreatePathForGlyph(runFontS,glyph.pointee,nil)
                let x = position.pointee.x - (CGFloat(temp) * width) - offset
                let y = position.pointee.y - (CGFloat(temp) * 80)
                var transform = CGAffineTransform(translationX: x, y: y)
                
                if path != nil{
                    paths.addPath(path!, transform: transform)
                }
                
                glyph.deinitialize()
                glyph.deallocate(capacity: 1)
                position.deinitialize()
                position.deallocate(capacity: 1)
            }
            
        }
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint.zero)
        bezierPath.append(UIBezierPath(cgPath: paths))
        
        return bezierPath
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.contentTextField.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

