//
//  ViewController.swift
//  WebPKitExample-iOS
//
//  Created by Tim Oliver on 12/10/20.
//

import UIKit
import WebPKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Locate the file on disk
        guard let url = Bundle.main.url(forResource: "WebPKitLogo",
                                        withExtension: "webp")  else { return }

        // Work out the smallest dimension of this window so we can scale to it
        let scale = UIScreen.main.scale
        let width = min(view.frame.width * scale, view.frame.height * scale)

        // Decode a copy of the image scaled to the size of the screen
        imageView.image = UIImage(contentsOfWebPFile: url, width: width)
    }
}
