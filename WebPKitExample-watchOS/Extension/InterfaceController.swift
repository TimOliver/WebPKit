//
//  InterfaceController.swift
//  WebPKitExample-watchOS WatchKit Extension
//
//  Created by Tim Oliver on 15/10/20.
//

import WatchKit
import Foundation
import UIKit

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var interfaceImage: WKInterfaceImage!

    override func awake(withContext context: Any?) {
        let webpImage = UIImage.webpNamed("WebPKitLogo")
        print(webpImage)
    }
    

}
