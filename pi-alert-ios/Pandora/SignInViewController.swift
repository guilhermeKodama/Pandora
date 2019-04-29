//
//  SignInViewController.swift
//  Pandora
//
//  Created by Kayron Cabral on 02/12/15.
//  Copyright © 2015 Pandora Technology. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    let subscriptionsIdentifier = "BedsSegue"
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var kbHeight: CGFloat = 150
    var isUp = false
    
    @IBOutlet weak var cpfTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignInViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignInViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func singinOnClick(sender: AnyObject) {
        let cpf = cpfTextField.text!
        let token = defaults.objectForKey("Token") as! String
        
        print("CPF: \(cpf)")
        print("Token: \(token)")
        
        let parameters = [
                            "cpf": cpf,
                            "token": token
                         ]
        
        if isValid(cpf){
            Alamofire.request(.POST, URL.SIGNIN, parameters: parameters, encoding: .JSON).responseJSON(completionHandler: { (response) in
                debugPrint(response)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if response.result.isSuccess{
                        print("Login validado com sucesso.")
                        self.defaults.setObject(cpf, forKey: "CPF")
                        self.cpfTextField.text = ""
                        
                        Intensivist.currentIntensivist = Intensivist(cpf: cpf, deviceToken: token)
                        
                        self.performSegueWithIdentifier(self.subscriptionsIdentifier, sender: self)
                    } else {
                        print("Error in SIGN IN: \(response.result.error)")
                    }
                })
            })
        }
    }
    
    func isValid(cpf: String) -> Bool {
        if cpf == "" {
            return false
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.characters.count > 10 {
            return false
        }
        
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let nextTag: NSInteger = textField.tag + 1;
        // Try to find next responder
        if let nextResponder: UIResponder! = textField.superview!.viewWithTag(nextTag){
            nextResponder.becomeFirstResponder()
        }
        else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        return false // We do not want UITextField to insert line-breaks.
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if !isUp {
            self.animateTextField(true)
            isUp = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.animateTextField(false)
        isUp = false
    }
    
    func animateTextField(up: Bool) {
        let movement = (up ? -kbHeight : kbHeight)
        
        UIView.animateWithDuration(0, animations: {
            self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        })
    }
    
}
