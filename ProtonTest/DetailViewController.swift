//
//  DetailViewController.swift
//  ProtonTest
//
//  Created by Robert Patchett on 07.02.19.
//  Copyright © 2019 Proton Technologies AG. All rights reserved.
//

import UIKit

protocol ImageDownloadDelegate: AnyObject {
    func imageDownloadedForObject(_ object: [String : Any])
}

class DetailViewController: UIViewController {

    @IBOutlet weak var forecastLabel: UILabel?
    @IBOutlet weak var sunriseLabel: UILabel?
    @IBOutlet weak var sunsetLabel: UILabel?
    @IBOutlet weak var highLabel: UILabel?
    @IBOutlet weak var lowLabel: UILabel?
    @IBOutlet weak var chanceOfRainLabel: UILabel?
    @IBOutlet weak var imageView: UIImageView?
    
    weak var downloadDelegate: ImageDownloadDelegate?

    var object: [String : Any]? = nil {
        didSet {
            configureView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }
    
    private func configureView() {
        guard let object = object else {
            resetView()
            return
        }
        forecastLabel?.text = (object["description"] as? String)
        sunriseLabel?.text = "\(String(describing: object["sunrise"] as? Int)) seconds"
        sunsetLabel?.text = "\(String(describing: object["sunset"] as? Int)) seconds"
        highLabel?.text = "\(String(describing: object["high"] as? Int))ºC"
        lowLabel?.text = "\(String(describing: object["low"] as? Int))ºC"
        chanceOfRainLabel?.text = "\(String(describing: object["chance_rain"] as? Double))%"
    }
    
    private func resetView() {
        forecastLabel?.text = nil
        sunriseLabel?.text = nil
        sunsetLabel?.text = nil
        highLabel?.text = nil
        lowLabel?.text = nil
        chanceOfRainLabel?.text = nil
    }
    
    @IBAction func downloadImage(_ sender: Any) {
        if let stringUrl = object?["image"] as? String,
           let forecastUrl = URL(string: stringUrl) {
            let imageDownloadSession = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
            imageDownloadSession.dataTask(with: forecastUrl, completionHandler: { [weak self] data, response, error in
                if let data = data {
                    self?.imageView?.image = UIImage(data: data)
                } else {
                    self?.imageView?.image = nil
                }
                self?.object?["image_downloaded"] = true
                if let object = self?.object {
                    self?.downloadDelegate?.imageDownloadedForObject(object)
                }
            }).resume()
        }
    }
}
