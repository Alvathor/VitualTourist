//
//  Util.swift
//  Virtual Tourist
//
//  Created by Juliano Alvarenga on 04/07/18.
//  Copyright © 2018 Zion. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func alert(externalController: UIViewController, title: String, msg: String, numberOfButtons: Int, titleButtonOne: String, titleButtonTwo: String?, hasCompletion: Bool,
               completionOne: @escaping () -> ()?, completionTwo: @escaping () -> ()?) {
        
        let controller = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        if numberOfButtons == 1 {
            if hasCompletion {
                
                controller.addAction(UIAlertAction(title: titleButtonOne, style: .default, handler: { (completed) in
                    
                    completionOne()
                    
                }))
                
            } else {
                
                controller.addAction(UIAlertAction(title: titleButtonOne, style: .default, handler: nil))
            }
            
        } else {
            
            if hasCompletion {
                
                controller.addAction(UIAlertAction(title: titleButtonOne, style: .default, handler: { (completed) in
                    
                    completionOne()
                    
                }))
                
                controller.addAction(UIAlertAction(title: titleButtonTwo, style: .destructive, handler: { (completed) in
                    
                    completionTwo()
                    
                }))
                
            } else {
                
                controller.addAction(UIAlertAction(title: titleButtonOne, style: .default, handler: nil))
                controller.addAction(UIAlertAction(title: titleButtonTwo, style: .destructive, handler: nil))
            }
            
        }
        
        externalController.present(controller, animated: true, completion: nil)
        
    }
    
}
