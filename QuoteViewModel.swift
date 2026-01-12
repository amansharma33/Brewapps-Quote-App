import Foundation
import SwiftUI
import Combine
class QuoteViewModel: ObservableObject {
    @Published var currentQuote: Quote?
    @Published var favorites: [Quote] = []
    @Published var isLoading = false
    
    private let saveKey = "SavedFavorites"
    
    init() { loadFavorites() }
    
    func fetchQuote() async {
        await MainActor.run { isLoading = true }
        
        // Using ZenQuotes API
        guard let url = URL(string: "https://zenquotes.io/api/random") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            // ZenQuotes returns an array of quotes
            let decodedArray = try JSONDecoder().decode([Quote].self, from: data)
            
            await MainActor.run {
                self.currentQuote = decodedArray.first
                self.isLoading = false
            }
        } catch {
            print("Fetch error: \(error.localizedDescription)")
            await MainActor.run { self.isLoading = false }
        }
    }
    
    func toggleFavorite() {
        guard let quote = currentQuote else { return }
        if let index = favorites.firstIndex(where: { $0.id == quote.id }) {
            favorites.remove(at: index)
        } else {
            favorites.append(quote)
        }
        saveFavorites()
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Quote].self, from: data) {
            favorites = decoded
        }
    }
}
