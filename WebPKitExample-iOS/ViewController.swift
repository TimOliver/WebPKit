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
        imageView.image = UIImage.webpNamed("WebPKitLogo")
        imageView.layer.minificationFilter = .trilinear
    }
}

