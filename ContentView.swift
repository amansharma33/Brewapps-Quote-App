import SwiftUI
import SwiftUI
import Combine


struct ContentView: View {
    @StateObject var vm = QuoteViewModel()
    
    var body: some View {
        TabView {
            // EXPLORE TAB
            NavigationView {
                VStack(spacing: 20) {
                    if vm.isLoading {
                        ProgressView("Fetching Wisdom...")
                    } else if let quote = vm.currentQuote {
                        QuoteView(quote: quote,
                                  isFav: vm.favorites.contains(quote),
                                  onToggle: { vm.toggleFavorite() })
                    }
                    
                    Button(action: { Task { await vm.fetchQuote() } }) {
                        Text("New Quote")
                            .bold()
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .navigationTitle("Daily Quotes")
            }
            .tabItem { Label("Explore", systemImage: "sparkles") }
            .task { await vm.fetchQuote() }

            // FAVORITES TAB
            NavigationView {
                List(vm.favorites) { quote in
                    VStack(alignment: .leading) {
                        Text(quote.content).font(.headline)
                        Text("- \(quote.author)").font(.subheadline).foregroundColor(.secondary)
                    }
                }
                .navigationTitle("Your Favorites")
            }
            .tabItem { Label("Favorites", systemImage: "heart.fill") }
        }
    }
}

struct QuoteView: View {
    let quote: Quote
    let isFav: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            Text(quote.content)
                .font(.title3)
                .italic()
                .multilineTextAlignment(.center)
            
            HStack {
                Text("— \(quote.author)")
                    .fontWeight(.light)
                Spacer()
                Button(action: onToggle) {
                    Image(systemName: isFav ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                        .font(.title2)
                }
            }
        }
        .padding(30)
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .padding()
    }
}
