//
//  PokemonsListViewModel.swift
//  OBRIO Test Task
//
//  Created by Ivan Skoryk on 24.09.2025.
//

import UIKit
import Combine

class PokemonsListViewModel {
    private var currentPage = 0
    private let downloadLimit: Int = 20
    private let service: PokemonsService!
    
    private var isLoading: Bool = false
    @Published private(set) var data = [Pokemon]()
    @Published private(set) var favourites = [Int]()
    
    weak var navigationController: UINavigationController?
    
    init() {
        self.service = PokemonsServiceImpl()
    }
    
    func loadPokemons() async {
        guard !isLoading else { return }
        self.isLoading = true
        
        guard let data = try? await service.fetchPokemons(offset: currentPage * downloadLimit, limit: downloadLimit) else {
            self.isLoading = false
            return
        }
        
        self.currentPage += 1
        self.isLoading = false
        self.data += data
    }
    
    func removePokemon(with id: Int) {
        data.removeAll(where: { $0.id == id })
        favourites.removeAll(where: {$0 == id})
    }
    
    func toggleFavourite(for id: Int) {
        if favourites.contains(id) {
            favourites.removeAll(where: { $0 == id })
        } else {
            favourites.append(id)
        }
        print(favourites)
    }
    
    func selectPokemon(at index: Int) {
        let vc = PokemonDetailsViewController()
        let data = data[index]
        
        vc.configure(with: data, isFavourite: favourites.contains(where: {$0 == data.id}))
        
        vc.onFavourite = { [weak self] in
            self?.toggleFavourite(for: data.id)
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
