//
//  ViewController.swift
//  CircleRotationView
//
//  Created by Daffolap on 19/11/17.
//  Copyright © 2017 Daffolap. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var circleNum: UITextField!
    @IBOutlet weak var warningLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! CircleView
        destination.N = Int(circleNum.text!)!
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var circles: Int = 0
        guard let numberOfCircle = circleNum.text else {
            warningLabel.text = "Empty Text"
            return false
        }
        if numberOfCircle != "" {
            circles = Int(circleNum.text!)!
        }
        if circles>0 && circles<11 {
            warningLabel.text = ""
            return true
        }
        warningLabel.text = "Invalid number"
        return false
    }

}

