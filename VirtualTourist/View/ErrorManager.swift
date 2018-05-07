//
//  ErrorManager.swift
//  VirtualTourist
//
//  Created by doc on 07/05/2018.
//  Copyright © 2018 Simone Barbara. All rights reserved.
//

import Foundation
import UIKit

protocol ErrorControllerProtocol {
    func dismissActivityControl()
    func presentError(alertController: UIAlertController)
    func fetchData()
}

struct ErrorManager {
    
    var delegate: ErrorControllerProtocol?
    
    func displayError(errorTitle: String, errorMsg: String?){
        let alert = UIAlertController(title: errorTitle, message: errorMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.UIViews.ErrorView.dismissButton, style: UIAlertActionStyle.cancel, handler: {UIAlertAction in
            self.delegate?.dismissActivityControl()
        } ))
        alert.addAction(UIAlertAction(title: Constants.UIViews.ErrorView.reloadButton, style: UIAlertActionStyle.default, handler: {UIAlertAction in
            self.delegate?.fetchData()
        } ))
        
        DispatchQueue.main.async {
            self.delegate?.presentError(alertController: alert)
        }
    }
}
