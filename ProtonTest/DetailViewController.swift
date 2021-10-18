//
//  DetailViewController.swift
//  ProtonTest
//
//  Created by Robert Patchett on 07.02.19.
//  Copyright © 2019 Proton Technologies AG. All rights reserved.
//

import UIKit

protocol ImageDownloadDelegate: AnyObject {
    func imageDownloadedForObject(_ object: ForecastDay?, _ data: Data?)
}

class DetailViewController: UIViewController {

    @IBOutlet weak var forecastLabel: UILabel?
    @IBOutlet weak var sunriseLabel: UILabel?
    @IBOutlet weak var sunsetLabel: UILabel?
    @IBOutlet weak var highLabel: UILabel?
    @IBOutlet weak var lowLabel: UILabel?
    @IBOutlet weak var chanceOfRainLabel: UILabel?
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var downloadButton: UIButton?
    
    weak var downloadDelegate: ImageDownloadDelegate?

    var forecastDay: ForecastDay? = nil {
        didSet {
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadButton?.addTarget(self, action: #selector(downloadImageClicked), for: .touchUpInside)
    }
    
    @objc private func downloadImageClicked() {
        if let stringUrl = forecastDay?.image, let forecastUrl = URL(string: stringUrl) {
            let imageDownloadSession = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
            imageDownloadSession.dataTask(with: forecastUrl, completionHandler: { [weak self] data, response, error in
                self?.processResults(data)
            }).resume()
        }
    }
    
    private func processResults(_ data: Data?) {
        if let data = data {
            imageView?.image = UIImage(data: data)
            downloadButton?.isHidden = true
        } else {
            imageView?.image = nil
        }
        downloadDelegate?.imageDownloadedForObject(forecastDay, data)
    }
    
    private func configureView() {
        forecastLabel?.text = forecastDay?.forecastDescription
        sunriseLabel?.text = "\(String(describing: forecastDay?.sunrise)) seconds"
        sunsetLabel?.text = "\(String(describing: forecastDay?.sunset)) seconds"
        highLabel?.text = "\(String(describing: forecastDay?.high))ºC"
        lowLabel?.text = "\(String(describing: forecastDay?.low))ºC"
        chanceOfRainLabel?.text = "\(String(describing: forecastDay?.chanceRain))%"
    }
}
