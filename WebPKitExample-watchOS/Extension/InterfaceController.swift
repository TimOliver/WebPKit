//
//  InterfaceController.swift
//  WebPKitExample-watchOS WatchKit Extension
//
//  Created by Tim Oliver on 15/10/20.
//

import WatchKit
import Foundation
import UIKit
import WebPKit

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var interfaceImage: WKInterfaceImage!

    override func awake(withContext context: Any?) {
        // Locate the file on disk
        guard let url = Bundle.main.url(forResource: "WebPKitLogo",
                                        withExtension: "webp")  else { return }

        // Decode a copy of the image scaled to the size of the screen
        let webpImage = UIImage(contentsOfWebPFile: url,
                                width: contentFrame.width)
        interfaceImage.setImage(webpImage)
    }
}
