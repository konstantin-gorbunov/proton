//
//  DetailViewController.swift
//  ProtonTest
//
//  Created by Robert Patchett on 07.02.19.
//  Copyright © 2019 Proton Technologies AG. All rights reserved.
//

import UIKit

protocol ImageDownloadDelegate: AnyObject {
    func imageDownloadedForObject(object: [String : Any])
}

class DetailViewController: UIViewController {

    @IBOutlet weak var forecastLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var chanceOfRainLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    weak var delegate: ImageDownloadDelegate?

    var object = [String : Any]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureView()
    }
    
    private func configureView() {
        forecastLabel.text = (object["description"]! as! String)
        sunriseLabel.text = "\(object["sunrise"]! as! Int) seconds"
        sunsetLabel.text = "\(object["sunset"]! as! Int) seconds"
        highLabel.text = "\(object["high"]! as! Int)ºC"
        lowLabel.text = "\(object["low"]! as! Int)ºC"
        chanceOfRainLabel.text = "\(object["chance_rain"]! as! Double)%"
    }
    
    @IBAction func downloadImage(_ sender: Any) {
        if let forecastUrl = URL(string: object["image"]! as! String) {
            let imageDownloadSession = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
            imageDownloadSession.dataTask(with: forecastUrl, completionHandler: { (data, response, error) in
                self.imageView.image = UIImage(data: data!)
                self.object["image_downloaded"] = true
                self.delegate!.imageDownloadedForObject(object: self.object)
            }).resume()
        }
    }
}
