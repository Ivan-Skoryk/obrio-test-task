//
//  ViewController.swift
//  OBRIO Test Task
//
//  Created by Ivan Skoryk on 24.09.2025.
//

import UIKit
import Combine

final class PokemonsListViewController: UIViewController {
    lazy private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
        ])
        
        tableView.register(PokemonCell.self, forCellReuseIdentifier: "PokemonCell")
        tableView.register(LoadingCell.self, forCellReuseIdentifier: "LoadingCell")
        
        return tableView
    }()
    
    private var viewModel = PokemonsListViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
        Task {
            await viewModel.loadPokemons()
        }
    }
    
    private func bindViewModel() {
        viewModel.navigationController = navigationController
        
        viewModel.$data
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$favourites
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.setupBarButtonItem()
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        title = "Pokemons List"
        view.backgroundColor = .systemBackground
        setupBarButtonItem()
    }
    
    private func setupBarButtonItem() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "star.fill"), for: .normal)
        button.tintColor = .systemYellow
        let barButtonItem1 = UIBarButtonItem(customView: button)
        
        let label = UILabel()
        label.text = "\(viewModel.favourites.count)"
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .label
        let barButtonItem2 = UIBarButtonItem(customView: label)
        navigationItem.rightBarButtonItems = [barButtonItem2, barButtonItem1]
    }
}

// MARK: - UITableViewDataSource
extension PokemonsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.data.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < viewModel.data.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath) as! PokemonCell
            let data = viewModel.data[indexPath.row]
            
            cell.configure(with: viewModel.data[indexPath.row], isFavourite: viewModel.favourites.contains(data.id))
            
            cell.onDeleteTapped = { [weak self] in
                self?.viewModel.removePokemon(with: data.id)
            }
            
            cell.onFavouriteTapped = { [weak self] in
                self?.viewModel.toggleFavourite(for: data.id)
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
            cell.spinner.startAnimating()
            return cell
        }
    }
}


// MARK: - UITableViewDelegate
extension PokemonsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectPokemon(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let threshold = viewModel.data.count - 5
        if indexPath.row == threshold {
            Task {
                await viewModel.loadPokemons()
            }
        }
    }
}
