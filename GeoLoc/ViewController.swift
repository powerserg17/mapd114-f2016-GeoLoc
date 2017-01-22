//
//  ViewController.swift
//  GeoLoc
//
//  Created by serhiipianykh on 2016-11-28.
//  Copyright © 2016 WiseIT. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class ViewController: UIViewController {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    //boolean flag to see if login was successfully made
    var loginSuccess = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //login/sign up button press
    @IBAction func loginToFirebase(sender: AnyObject) {
        //trying to create user
        FIRAuth.auth()?.createUserWithEmail(username.text!, password: password.text!, completion: { (user, error) in
            if error != nil {
                //if user exists - login
                self.login()
            } else {
                //user created and now login
                print("User created")
                self.login()
            }
        })
        
    }
    
    //login function
    func login() {
        FIRAuth.auth()?.signInWithEmail(username.text!, password: password.text!, completion: { (user, error) in
            if error != nil {
                //if error occured while signing in
                print("Incorrect")
                //create alert controller
                let alert = UIAlertController(title: "Error",message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                //create message(action) for alert controller
                let message = UIAlertAction(title: "Invalid credentials", style: UIAlertActionStyle.Default) { (action: UIAlertAction) -> Void in
                    //actions to be made when message clicked
                    self.username.text = ""
                    self.password.text = ""
                }
                //adding action to alert
                alert.addAction(message)
                //presenting alert. UIAlerControllerStyle.Alert shows alert modally in the center of the screen
                self.presentViewController(alert, animated: true, completion: nil)
                
                
            } else {
                //if successfully signed in
                print("Success")
                //setting flag to true
                self.loginSuccess = true
                //performing segue with ShowMap identifier
                self.performSegueWithIdentifier("ShowMap", sender: self)
            }
        })
    }
    
    //this function allows me to check if we are good to perform segue
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        //so if we call ShowMap segue and flag is not true (so we haven't logged in) - segue is now performing
        if identifier == "ShowMap" {
            if loginSuccess != true {
                return false
            }
        }
        //otherwise - good to go
        return true
    }

}

