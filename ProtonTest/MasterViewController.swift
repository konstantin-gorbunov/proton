//
//  MasterViewController.swift
//  ProtonTest
//
//  Created by Robert Patchett on 07.02.19.
//  Copyright © 2019 Proton Technologies AG. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    private enum Constants {
        static let url: URL? = URL(string: "https://protonmail.github.io/proton-mobile-test/api/forecast")
    }
    
    @IBOutlet weak var sortingControl: UISegmentedControl?
    private lazy var dependency = AppDependency()
    
    private var forecast: [[String: Any]]?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        sortingControl?.addTarget(self, action: #selector(sortingControlAction(_:)), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let forecastUrl = Constants.url else { return }
        URLSession.shared.dataTask(with: forecastUrl, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                guard let data = data,
                        let objects = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: Any]] else {
                    return
                }
                self.forecast = objects
                self.tableView.reloadData()
            }
        }).resume()
    }

    @objc private func sortingControlAction(_ segmentedControl: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 1 { // switching to sorted option
            forecast?.sort { object1, object2 -> Bool in
                return (object1["high"] as? Double ?? 0) > (object2["high"] as? Double ?? 0)
            }
            var tempObjects = forecast
            for i in 0..<(forecast?.count ?? 0) {
                if (forecast?[i]["chance_rain"] as? Double ?? 0) > 0.5 {
                    tempObjects?.removeAll { object -> Bool in
                        return object["chance_rain"] as? Double == forecast?[i]["chance_rain"] as? Double
                    }
                }
            }
            forecast = tempObjects
        } else {
            forecast?.sort { object1, object2 -> Bool in
                return (object1["day"] as? String ?? "") < (object2["day"] as? String ?? "")
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = forecast?[indexPath.row]
                guard let controller = (segue.destination as? UINavigationController)?.topViewController as? DetailViewController else {
                    return
                }
                controller.downloadDelegate = self
                controller.object = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                let title: String?
                if let day = object?["day"] as? String {
                    title = "Day \(day)"
                } else {
                    title = nil
                }
                controller.title = title
            }
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        forecast?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = forecast?[indexPath.row]
        let text: String?
        if let day = object?["day"], let description = object?["description"] {
            text = "Day \(day): \(description)"
        } else {
            text = nil
        }
        cell.textLabel?.text = text
        if let imageDownloaded = object?["image_downloaded"] as? Bool, imageDownloaded {
            cell.textLabel?.textColor = .gray
        }
        return cell
    }
}

extension MasterViewController: ImageDownloadDelegate {
    func imageDownloadedForObject(_ object: [String: Any]) {
        if let i = forecast?.firstIndex(where: { comparedObject -> Bool in
            return (comparedObject["day"] as? String) == (object["day"] as? String)
        }) {
            forecast?[i] = object
            tableView.reloadData()
        }
    }
}
