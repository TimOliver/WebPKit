//
//  ViewController.swift
//  WebPKitExample-tvOS
//
//  Created by Tim Oliver on 15/10/20.
//

import UIKit
import WebPKit

class ViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Set the rounding of the background view to
        backgroundView.layer.cornerRadius = view.bounds.height * 0.2

        // Set the rounding to be squircular
        if #available(tvOS 13.0, *) {
            backgroundView.layer.cornerCurve = .continuous
        }

    }
}

