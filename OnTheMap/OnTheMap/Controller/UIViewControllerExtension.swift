//
//  ViewController.swift
//  OnTheMap
//
//  Created by Neri Quiroz on 11/18/20.
//

import UIKit

extension UIViewController {
    
    //add locations
    @IBAction func addLocation(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addLocation", sender: sender)
    }
    
    func buttonEnabled(_ enabled: Bool, button: UIButton) {
        if enabled {
            button.isEnabled = true
            button.alpha = 1.0
        } else {
            button.isEnabled = false
            button.alpha = 0.5
        }
    }
    
    
    
    //alert messages
    func showAlert(message: String, title: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true)
    }
    
    
    //open website links 
    func openLink(_ url: String) {
        guard let url = URL(string: url), UIApplication.shared.canOpenURL(url) else {
            showAlert(message: "Cannot open link.", title: "Invalid Link")
            return
        }
        UIApplication.shared.open(url, options: [:])
    }

}

