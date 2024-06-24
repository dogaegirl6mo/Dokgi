//
//  BookSearchViewModel.swift
//  Dokgi
//
//  Created by 한철희 on 6/18/24.
//

import Foundation

class BookSearchViewModel {
    
    private let bookManager = BookManager.shared
    
    var searchResults: [Item] = []
    var isLoading = false
    var isLoadingLast = false
    var query: String = ""
    var startIndex: Int = 1
    
    func fetchBooks(query: String, startIndex: Int, completion: @escaping (Result<[Item], Error>) -> Void) {
        isLoading = true
        bookManager.fetchBookData(queryValue: query, startIndex: startIndex) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    completion(.success(response.items))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            self.isLoading = false
        }
    }
    
    func clearRecentSearches() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.recentSearches.rawValue)
    }
    
    func saveRecentSearch(_ text: String) {
        var recentSearches = loadRecentSearches()
        
        recentSearches.removeAll(where: { $0 == text })
        recentSearches.insert(text, at: 0)
        
        if recentSearches.count > 10 {
            recentSearches.removeLast()
        }
        UserDefaults.standard.set(recentSearches, forKey: UserDefaultsKeys.recentSearches.rawValue)
    }
    
    func loadRecentSearches() -> [String] {
        return UserDefaults.standard.stringArray(forKey: UserDefaultsKeys.recentSearches.rawValue) ?? []
    }
    
    func removeRecentSearch(at indexPath: IndexPath) {
        var recentSearches = loadRecentSearches()
        recentSearches.remove(at: indexPath.item)
        UserDefaults.standard.set(recentSearches, forKey: UserDefaultsKeys.recentSearches.rawValue)
    }
}
