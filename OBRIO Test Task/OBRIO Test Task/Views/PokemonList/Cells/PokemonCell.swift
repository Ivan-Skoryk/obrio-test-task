//
//  PokemonCell.swift
//  OBRIO Test Task
//
//  Created by Ivan Skoryk on 24.09.2025.
//

import UIKit
import Combine

class PokemonCell: UITableViewCell {
    private let pokemonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nameTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    private let idTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let favouriteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "star"), for: .normal)
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    var onFavouriteTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)?
    
    private var cancellable: AnyCancellable?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        pokemonImageView.image = nil
        nameTextLabel.text = nil
        idTextLabel.text = nil
    }
    
    func configure(with pokemon: Pokemon, isFavourite: Bool) {
        nameTextLabel.text = pokemon.name.capitalized
        idTextLabel.text = "#\(pokemon.id)"
        
        favouriteButton.setImage(UIImage(systemName: isFavourite ? "star.fill": "star"), for: .normal)
        favouriteButton.tintColor = .systemYellow
        favouriteButton.addTarget(self, action: #selector(onFavourite), for: .touchUpInside)
        
        deleteButton.tintColor = .systemRed
        deleteButton.addTarget(self, action: #selector(onDelete), for: .touchUpInside)
        
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
    
    @objc
    private func onFavourite() {
        onFavouriteTapped?()
    }
    
    @objc
    private func onDelete() {
        onDeleteTapped?()
    }
     
    private func setupUI() {
        contentView.addSubview(pokemonImageView)
        contentView.addSubview(nameTextLabel)
        contentView.addSubview(idTextLabel)
        contentView.addSubview(favouriteButton)
        contentView.addSubview(deleteButton)
        
        pokemonImageView.translatesAutoresizingMaskIntoConstraints = false
        nameTextLabel.translatesAutoresizingMaskIntoConstraints = false
        idTextLabel.translatesAutoresizingMaskIntoConstraints = false
        favouriteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pokemonImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            pokemonImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pokemonImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            pokemonImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            pokemonImageView.heightAnchor.constraint(equalToConstant: 80,),
            pokemonImageView.widthAnchor.constraint(equalToConstant: 60),
            
            nameTextLabel.leadingAnchor.constraint(equalTo: pokemonImageView.trailingAnchor, constant: 8),
            nameTextLabel.bottomAnchor.constraint(equalTo: pokemonImageView.centerYAnchor, constant: 4),
            nameTextLabel.topAnchor.constraint(greaterThanOrEqualTo: pokemonImageView.topAnchor, constant: 0),
            
            idTextLabel.leadingAnchor.constraint(equalTo: pokemonImageView.trailingAnchor, constant: 8),
            idTextLabel.topAnchor.constraint(equalTo: pokemonImageView.centerYAnchor, constant: -4),
            idTextLabel.bottomAnchor.constraint(greaterThanOrEqualTo: pokemonImageView.bottomAnchor, constant: 0),
            
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            favouriteButton.leadingAnchor.constraint(greaterThanOrEqualTo: nameTextLabel.trailingAnchor, constant: 8),
            favouriteButton.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),
            favouriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favouriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            favouriteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }
}
