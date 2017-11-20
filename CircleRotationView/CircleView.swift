//
//  CircleView.swift
//  CircleRotationView
//
//  Created by Daffolap on 19/11/17.
//  Copyright © 2017 Daffolap. All rights reserved.
//

import UIKit

class CircleView: UIViewController, CAAnimationDelegate {
    
    //Total number of buttons
    var N: Int = 0
    
    
    var buttonArray = [UIButton]()
    var buttonAngles = [Double]()
    
    // this array maps the position of all buttons at their original positions to the positions when they are tapped.
    var transformIndex = [Int]()
    
    var isCollapsed = false
    var currentThemeColor = "ffffff"
    var currentColorIndex = 0
    var colorToggler: UIColor!
    var colorTogglerTag = -1
    var currentTappedButton: UIButton!
    var tappedColor: UIColor? = nil
    
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var applyButton: UIButton!
    
    var circleCenter = CGPoint(x: 0, y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        parentView.backgroundColor = UIColor.clear
        circleCenter = (UIApplication.shared.keyWindow?.center)!
        initButtons()
        
        self.view.bringSubview(toFront: cancelButton)
        self.view.bringSubview(toFront: applyButton)
    }
    
    func initButtons() {
        for i in 0..<N {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
            button.layer.cornerRadius = (button.frame.size.width) / 2
            button.tag = i
            button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
            button.backgroundColor = getRandomColor()
            button.setImage(UIImage(named: "foox_theme_button")?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.tintColor = UIColor.white
            buttonArray.append(button)
            //            buttonTag += 1
        }
        
        //initially every ith buttons are at their place.
        for i in 0..<buttonArray.count {
            transformIndex.append(i)
        }
        
        //MARK: saved tag and color.
        
        let userDefaults = UserDefaults.standard
        let buttonTag = userDefaults.integer(forKey: colorKeyIndex)
        let savedColor = userDefaults.string(forKey: colorKeyForTheme) == nil ? blueBackground : userDefaults.string(forKey: colorKeyForTheme)
        tappedRotation(buttonTag: buttonTag, bgColor: UIColor(hexString: savedColor!))
        alignCircular(withArray: buttonArray, withCenter: circleCenter, withRadius: self.view.bounds.width / 2 - buttonArray[0].frame.width)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismissViewController()
    }
    
    @IBAction func applyButtonTapped(_ sender: Any) {
        dismissViewController()
    }
    
    func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func buttonTapped(sender: UIButton) {
        
        tappedColor = sender.backgroundColor!
        if tappedColor != UIColor.white {
            currentTappedButton = sender
            for i in buttonArray {
                if i.tag == colorTogglerTag {
                    currentTappedButton = i
                    break
                }
            }
            if colorTogglerTag >= 0 {
                toggleLastButtonColor(sender: currentTappedButton)
            }
            
            tappedRotation(buttonTag: sender.tag, bgColor: tappedColor!)
        }
    }
    
    func toggleLastButtonColor(sender: UIButton) {
        sender.tintColor = UIColor.white
        sender.backgroundColor = colorToggler
    }
    
    func tappedRotation(buttonTag: Int, bgColor: UIColor) {
        for i in buttonArray {
            if i.tag == buttonTag {
                currentTappedButton = i
                break
            }
        }
        
        let tag = transformIndex[buttonTag]
        
        for i in 0..<buttonArray.count {
            ((i - buttonTag) < 0) ? (transformIndex[i] = (i - buttonTag + buttonArray.count)) : (transformIndex[i] = (i - buttonTag))
            
        }
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        let curAngle = parentView.layer.value(forKeyPath: "transform.rotation.z") as? Double
        
        //map tag with the related position from 'transformedIndex' array. array updated after every click.
        var angleToAdd = (tag > buttonArray.count ? Double(buttonArray.count - tag) : Double(tag)) * Double(.pi / Double(buttonArray.count)) * 2.0
        
        //if clicked in 1st and 4th quadrant of the cartesian plane, it is supposed to have anti-clockwise rotation.
        if buttonTag < buttonArray.count {
            angleToAdd = -angleToAdd
        }
        
        parentView.layer.setValue((curAngle == nil ? 0.0 : curAngle!) + angleToAdd, forKeyPath: "transform.rotation.z")
        
        rotationAnimation.toValue = curAngle! + angleToAdd
        rotationAnimation.byValue = angleToAdd
        rotationAnimation.speed = 0.3
        rotationAnimation.delegate = self
        
        parentView.layer.add(rotationAnimation, forKey: "rotationAnimation")
        
        self.view.backgroundColor = bgColor
        currentColorIndex = buttonTag
        
        colorTogglerTag = buttonTag
        colorToggler = bgColor
        
        currentTappedButton.tintColor = bgColor
        currentTappedButton.backgroundColor = UIColor.white
        
    }
    
    //MARK: View alignment.
    func alignCircular(withArray: [UIButton], withCenter: CGPoint, withRadius: CGFloat) {
        var curAngle = .pi / -2.0
        let incAngle = (360.0 / Double(withArray.count))*(.pi/180.0)
        let circleCenter = withCenter
        let circleRadius = withRadius
        for button in withArray {
            /*
             calculate button centre using parametric equation.
             x = cx + r * cos(a)
             y = cy + r * sin(a)
             */
            buttonAngles.append(curAngle)
            var buttonCenter = CGPoint(x: 0, y: 0)
            buttonCenter.x = circleCenter.x + CGFloat(cos(curAngle)*Double(circleRadius))
            buttonCenter.y = circleCenter.y + CGFloat(sin(curAngle)*Double(circleRadius))
            button.center = buttonCenter
            
            parentView.addSubview(button)
            curAngle += incAngle
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        _ = event?.allTouches?.first?.location(in: self.view)
        let collapsingRadius: CGFloat!
        if isCollapsed {
            collapsingRadius = (self.view.bounds.width / 2) - (self.buttonArray[0].frame.width)
            isCollapsed = false
        }else {
            collapsingRadius = self.buttonArray[0].frame.width / 2.0
            isCollapsed = true
        }
        UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveLinear, animations: { Void in
            self.alignCircular(withArray: self.buttonArray, withCenter: self.circleCenter, withRadius: collapsingRadius)
        }, completion: {(success) in
            if success {
                print("center animation done.")
            }else {
                print("center animation failed.")
            }
        })
    }
    
    
    func getRandomColor() -> UIColor {
        let red = Double(arc4random_uniform(UInt32(255.0))) / 255.0
        let green = Double(arc4random_uniform(UInt32(255.0))) / 255.0
        let blue = Double(arc4random_uniform(UInt32(255.0))) / 255.0
        return UIColor.init(colorLiteralRed: Float(red), green: Float(green), blue: Float(blue), alpha: 1.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
