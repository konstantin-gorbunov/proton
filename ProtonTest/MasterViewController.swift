//
//  MasterViewController.swift
//  ProtonTest
//
//  Created by Robert Patchett on 07.02.19.
//  Copyright © 2019 Proton Technologies AG. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    @IBOutlet weak var sortingControl: UISegmentedControl?

    private lazy var dependency = AppDependency()
    private var forecast: Forecast?
    private var rawForecast: Forecast? {
        didSet {
            rawForecast?.sort { object1, object2 -> Bool in
                return (object1.day ?? "") < (object2.day ?? "")
            }
            forecast = rawForecast
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        sortingControl?.addTarget(self, action: #selector(sortingControlAction(_:)), for: .valueChanged)
        dependency.liveDataProvider.fetchForecastList { result in
            DispatchQueue.main.async { [weak self] in
                self?.processResults(result)
            }
        }
    }
    
    private func processResults(_ result: DataProvider.FetchForecastResult) {
        guard case .success(let forecast) = result, forecast.isEmpty == false else {
            // TODO: ask cached data
            return
        }
        rawForecast = forecast
        tableView.reloadData()
        // TODO: update cached data
    }

    @objc private func sortingControlAction(_ segmentedControl: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 1 { // switching to sorted option
            forecast = rawForecast?.filter { $0.chanceRain ?? 0 < 0.5 }.sorted { object1, object2 -> Bool in
                return (object1.high ?? 0) > (object2.high ?? 0)
            }
        } else {
            forecast = rawForecast
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
                if let day = object?.day {
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
        if let day = object?.day, let description = object?.forecastDescription {
            text = "Day \(day): \(description)"
        } else {
            text = nil
        }
        cell.textLabel?.text = text
        // TODO: change color for Day with previously downloaded image
//        if let imageDownloaded = object?["image_downloaded"] as? Bool, imageDownloaded {
//            cell.textLabel?.textColor = .gray
//        }
        return cell
    }
}

extension MasterViewController: ImageDownloadDelegate {
    func imageDownloadedForObject(_ object: ForecastDay?) {
        guard let object = object else { return }
        if let i = forecast?.firstIndex(where: { comparedObject -> Bool in
            return comparedObject.day == object.day
        }) {
            // TODO: save info about Day with previously downloaded image
            forecast?[i] = object
            tableView.reloadData()
        }
    }
}
