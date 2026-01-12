struct Quote: Codable, Identifiable, Equatable {
    var id: String { content + author } // ZenQuotes doesn't provide a unique ID in the free tier
    let content: String
    let author: String
    
    enum CodingKeys: String, CodingKey {
        case content = "q"
        case author = "a"
    }
}
