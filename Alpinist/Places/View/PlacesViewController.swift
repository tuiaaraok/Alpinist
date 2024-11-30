//
//  PlacesViewController.swift
//  Alpinist
//
//  Created by Karen Khachatryan on 29.11.24.
//

import UIKit
import Combine

class PlacesViewController: UIViewController {

    @IBOutlet var sectionButtons: [BaseButton]!
    @IBOutlet weak var placesTableView: UITableView!
    private let addPlaceButton = UIButton(type: .custom)
    private let viewModel = PlacesViewModel.shared
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
        viewModel.fetchData()
    }

    func setupUI() {
        setNaviagtionBackButton()
        setNavigationTitle(title: "My places")
        addPlaceButton.addTarget(self, action: #selector(addPlace), for: .touchUpInside)
        addPlaceButton.setTitle("+Add", for: .normal)
        addPlaceButton.setTitleColor(.black, for: .normal)
        addPlaceButton.titleLabel?.font = .bold(size: 20)
        setNaviagtionRightButton(button: addPlaceButton)
        placesTableView.register(UINib(nibName: "PlaceTableViewCell", bundle: nil), forCellReuseIdentifier: "PlaceTableViewCell")
        placesTableView.delegate = self
        placesTableView.dataSource = self
    }
    
    func subscribe() {
        viewModel.$places
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.sectionButtons.forEach({ $0.isSelected = false })
                self.sectionButtons[self.viewModel.selectedType].isSelected = true
                self.placesTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    func openPlaceForm() {
        let placeFormVC = PlaceFormViewController(nibName: "PlaceFormViewController", bundle: nil)
        placeFormVC.completion = { [weak self] in
            if let self = self {
                self.viewModel.fetchData()
            }
        }
        self.navigationController?.pushViewController(placeFormVC, animated: true)
    }
    
    @objc func addPlace() {
        openPlaceForm()
    }

    @IBAction func chooseVisited(_ sender: BaseButton) {
        viewModel.filter(type: 0)
    }
    
    @IBAction func choosePlanned(_ sender: BaseButton) {
        viewModel.filter(type: 1)
    }
}

extension PlacesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.places.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceTableViewCell", for: indexPath) as! PlaceTableViewCell
        cell.configure(place: viewModel.places[indexPath.section])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        PlaceFormViewModel.shared.place = viewModel.places[indexPath.section]
        openPlaceForm()
    }
}
