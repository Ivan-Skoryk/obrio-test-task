//
//  PokemonDetailsViewController.swift
//  OBRIO Test Task
//
//  Created by Ivan Skoryk on 24.09.2025.
//

import UIKit
import Combine

final class PokemonDetailsViewController: UIViewController {
    private let pokemonImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    private let heightLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    private let weightLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    private var favouriteButton: UIBarButtonItem!
    
    private var cancellable: AnyCancellable?
    
    var onFavourite: (() -> Void)?
    private var isFavourite: Bool = false {
        didSet {
            setupFavouriteButton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupSubviews()
    }
    
    private func setupUI() {
        title = "Pokémon Details"
        view.backgroundColor = .systemGroupedBackground
    }
    
    private func setupSubviews() {
        let stackView = UIStackView()
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(heightLabel)
        stackView.addArrangedSubview(weightLabel)
        stackView.addArrangedSubview(UIView())
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(pokemonImageView)
        view.addSubview(stackView)
        
        pokemonImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pokemonImageView.heightAnchor.constraint(equalToConstant: 150),
            pokemonImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            pokemonImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            pokemonImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 8),
            
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            stackView.topAnchor.constraint(equalTo: pokemonImageView.bottomAnchor, constant: 0),
            stackView.bottomAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 8)
        ])
        
        setupFavouriteButton()
    }
    
    func configure(with pokemon: Pokemon, isFavourite: Bool) {
        nameLabel.text = "Name: " + pokemon.name.capitalized
        heightLabel.text = "Height: \(pokemon.height) cm"
        weightLabel.text = "Weight: \(pokemon.weight) kg"
        
        self.isFavourite = isFavourite
        setupFavouriteButton()
        
        cancellable = loadImage(for: pokemon.imageURLString).sink { [weak self] image in self?.pokemonImageView.image = image }
    }
    
    private func loadImage(for stringURL: String) -> AnyPublisher<UIImage?, Never> {
        return Just(stringURL)
            .flatMap({ poster -> AnyPublisher<UIImage?, Never> in
                let url = URL(string: stringURL)!
                return ImageLoader.shared.loadImage(from: url)
            })
            .eraseToAnyPublisher()
    }
    
    private func setupFavouriteButton() {
        favouriteButton = UIBarButtonItem(image: UIImage(systemName: isFavourite ? "star.fill": "star"), style: .plain, target: self, action: #selector(onFavouriteTapped))
        favouriteButton.tintColor = .systemYellow
        navigationItem.rightBarButtonItem = favouriteButton
    }
    
    @objc private func onFavouriteTapped() {
        onFavourite?()
        isFavourite.toggle()
        setupFavouriteButton()
    }
}
