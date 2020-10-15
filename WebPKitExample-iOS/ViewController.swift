//
//  ViewController.swift
//  WebPKitExample-iOS
//
//  Created by Tim Oliver on 12/10/20.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Decode and set a WebP image to
        // the image view in this view controller
        imageView.image = UIImage.webpNamed("WebPKitLogo")

        // As this is a large image, enable trilinear filtering
        // to allow better re-sampling at smaller screen sizes
        imageView.layer.minificationFilter = .trilinear
    }
}

