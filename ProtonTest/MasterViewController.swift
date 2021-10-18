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
        static let cellIdentifier: String = "Cell"
    }
    
    @IBOutlet weak var sortingControl: UISegmentedControl?

    private lazy var dependency = AppDependency()

    private var forecastModel: [ForecastCellViewModel] = []
    private var rawForecast: Forecast? {
        didSet {
            rawForecast?.sort { object1, object2 -> Bool in
                return (object1.day ?? "") < (object2.day ?? "")
            }
            forecast = rawForecast
        }
    }
    private var forecast: Forecast? {
        didSet {
            forecastModel = rawForecast?.map { ForecastCellViewModel(forecast: $0, imageData: nil) } ?? []
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
                guard let controller = (segue.destination as? UINavigationController)?.topViewController as? DetailViewController else {
                    return
                }
                controller.downloadDelegate = self
                controller.forecastDay = forecastModel[safeIndex: indexPath.row]?.forecast
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        forecastModel.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath)
        let object = forecastModel[safeIndex: indexPath.row]
        cell.textLabel?.text = object?.cellDescription
        cell.textLabel?.textColor = object?.imageData != nil ? .gray : .black
        if let data = object?.imageData {
            cell.imageView?.image = UIImage(data: data)
        } else {
            cell.imageView?.image = nil
        }
        return cell
    }
}

extension MasterViewController: ImageDownloadDelegate {
    func imageDownloadedForObject(_ object: ForecastDay?, _ data: Data?) {
        guard let forecastDay = object else { return }
        if let indexOfModel = forecastModel.firstIndex(where: { $0.forecast == forecastDay }) {
            if indexOfModel < forecastModel.count {
                forecastModel[indexOfModel].imageData = data
                tableView.reloadData()
            }
        }
    }
}
