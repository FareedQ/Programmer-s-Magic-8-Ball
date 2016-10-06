//
//  ViewController.swift
//  PlayingWithShake
//
//  Created by FareedQ on 2016-01-22.
//  Copyright © 2016 FareedQ. All rights reserved.
//

import AudioToolbox
import UIKit

class ViewController: UIViewController {
    
    var options = Options()
    var previousResponses = [Int]()
    var viewState:viewStates = .responses
    
    enum viewStates{
        case responses
        case reset
    }

    @IBOutlet weak var shakeButton: UIButton!
    @IBOutlet weak var responseLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabelsAndButtonText()
        
        guard let myURL = NSURL(string: "http://0.0.0.0:8181/JSON") else { return }
        guard let JSONData = NSData(contentsOf: myURL as URL) else { return }
        do {
            guard let json = try JSONSerialization.jsonObject(with: JSONData as Data, options: JSONSerialization.ReadingOptions()) as? [String:[String]] else { return }
            guard let jsonResponses = json["key"] else { return }
            options.responses = jsonResponses
        } catch {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSLog("Did recieve a memory warning", "")
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }

    @IBAction func shakeButton(_ sender: AnyObject) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        switch viewState {
        case .responses:
            responseLabel.alpha = 0
            responseAction()
            break
        case .reset:
            setupLabelsAndButtonText()
            viewState = .responses
            previousResponses = [Int]()
            break
            
        }
    }
    
    func setupLabelsAndButtonText(){
        responseLabel.text = "Tell me your programming problem and shake the phone"
        shakeButton.setTitle("Shake me", for: UIControlState())
        shakeButton.setTitleColor(UIColor.green, for: UIControlState())
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake && viewState == .responses {
            responseLabel.alpha = 0
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake && viewState == .responses {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            responseAction()
        }
    }
    
    func responseAction(){
        let responeInt = getRandomResponseInt()
        if responeInt == 99 {
            responseLabel.text = "I have no more ideas."
            shakeButton.setTitle("Reset", for: UIControlState())
            shakeButton.setTitleColor(UIColor.red, for: UIControlState())
            viewState = .reset
        } else {
            responseLabel.text = options.responses[responeInt]
        }
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.responseLabel.alpha = 1
        })
    }
    
    func getRandomResponseInt() -> Int{
        if previousResponses.count == options.responses.count {
            return 99
        }
        
        var randomInt = Int(arc4random_uniform(UInt32(options.responses.count)))
        while previousResponses.contains(randomInt) {
            randomInt = Int(arc4random_uniform(UInt32(options.responses.count)))
        }
        previousResponses.append(randomInt)
        return randomInt
    }
}

