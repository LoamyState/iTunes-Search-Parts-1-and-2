import UIKit

extension Data {
    func prettyPrintedJSONString() {
        guard
            let jsonObject = try?
               JSONSerialization.jsonObject(with: self,
               options: []),
            let jsonData = try?
               JSONSerialization.data(withJSONObject:
               jsonObject, options: [.prettyPrinted]),
            let prettyJSONString = String(data: jsonData,
               encoding: .utf8) else {
                print("Failed to read JSON Object.")
                return
        }
        print(prettyJSONString)
    }
}

struct StoreItem: Codable {
    let artworkMediumUrl: URL
    let collectionPrice: Double?
    let wrapperType: String
    let description: String
    let country: String
    let isStreamable: Bool
    let releaseDate: String
    let artistId: Int
    let collectionViewUrl: URL
    let kind: String
    let trackExplicitness: String
    let currency: String
    let artistName: String
    let artistViewUrl: URL
    let artworkSmallUrl: URL
    let trackViewUrl: URL
    let discCount: Int
    let collectionCensoredName: String
    let collectionId: Int
    let trackCensoredName: String
    let previewUrl: URL
    let trackTimeMillis: Int
    let trackName: String
    let trackPrice: Double?
    let collectionName: String
    let artworkLargeUrl: URL
    let trackCount: Int
    let trackId: Int
    let discNumber: Int
    let collectionExplicitness: String
    let trackNumber: Int
    let primaryGenreName: String
    
    enum CodingKeys: String, CodingKey {
        case artworkMediumUrl = "artworkUrl60"
        case collectionPrice
        case wrapperType
        case description
        case country
        case isStreamable
        case releaseDate
        case artistId
        case collectionViewUrl
        case kind
        case trackExplicitness
        case currency
        case artistName
        case artistViewUrl
        case artworkSmallUrl = "artworkUrl30"
        case trackViewUrl
        case discCount
        case collectionCensoredName
        case collectionId
        case trackCensoredName
        case previewUrl
        case trackTimeMillis
        case trackName
        case trackPrice
        case collectionName
        case artworkLargeUrl = "artworkUrl100"
        case trackCount
        case trackId
        case discNumber
        case collectionExplicitness
        case trackNumber
        case primaryGenreName
    }
    
    enum AdditionalKeys: String, CodingKey {
        case longDescription
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        artworkMediumUrl = try values.decode(URL.self, forKey: CodingKeys.artworkMediumUrl)
        collectionPrice = try? values.decode(Double?.self, forKey: CodingKeys.collectionPrice)
        wrapperType = try values.decode(String.self, forKey: CodingKeys.wrapperType)
        country = try values.decode(String.self, forKey: CodingKeys.country)
        isStreamable = try values.decode(Bool.self, forKey: CodingKeys.isStreamable)
        releaseDate = try values.decode(String.self, forKey: CodingKeys.releaseDate)
        artistId = try values.decode(Int.self, forKey: CodingKeys.artistId)
        collectionViewUrl = try values.decode(URL.self, forKey: CodingKeys.collectionViewUrl)
        kind = try values.decode(String.self, forKey: CodingKeys.kind)
        trackExplicitness = try values.decode(String.self, forKey: CodingKeys.trackExplicitness)
        currency = try values.decode(String.self, forKey: CodingKeys.currency)
        artistName = try values.decode(String.self, forKey: CodingKeys.artistName)
        artistViewUrl = try values.decode(URL.self, forKey: CodingKeys.artistViewUrl)
        artworkSmallUrl = try values.decode(URL.self, forKey: CodingKeys.artworkSmallUrl)
        trackViewUrl = try values.decode(URL.self, forKey: CodingKeys.trackViewUrl)
        discCount = try values.decode(Int.self, forKey: CodingKeys.discCount)
        collectionCensoredName = try values.decode(String.self, forKey: CodingKeys.collectionCensoredName)
        collectionId = try values.decode(Int.self, forKey: CodingKeys.collectionId)
        trackCensoredName = try values.decode(String.self, forKey: CodingKeys.trackCensoredName)
        previewUrl = try values.decode(URL.self, forKey: CodingKeys.previewUrl)
        trackTimeMillis = try values.decode(Int.self, forKey: CodingKeys.trackTimeMillis)
        trackName = try values.decode(String.self, forKey: CodingKeys.trackName)
        trackPrice = try? values.decode(Double.self, forKey: CodingKeys.trackPrice)
        collectionName = try values.decode(String.self, forKey: CodingKeys.collectionName)
        artworkLargeUrl = try values.decode(URL.self, forKey: CodingKeys.artworkLargeUrl)
        trackCount = try values.decode(Int.self, forKey: CodingKeys.trackCount)
        trackId = try values.decode(Int.self, forKey: CodingKeys.trackId)
        discNumber = try values.decode(Int.self, forKey: CodingKeys.discNumber)
        collectionExplicitness = try values.decode(String.self, forKey: CodingKeys.collectionExplicitness)
        trackNumber = try values.decode(Int.self, forKey: CodingKeys.trackNumber)
        primaryGenreName = try values.decode(String.self, forKey: CodingKeys.primaryGenreName)
        
        if let description = try? values.decode(String.self, forKey: CodingKeys.description) {
            self.description = description
        } else {
            let additionalValues = try decoder.container(keyedBy: AdditionalKeys.self)
            description = (try? additionalValues.decode(String.self, forKey: AdditionalKeys.longDescription)) ?? ""
        }
    }
}

struct SearchResponse: Codable {
    let results: [StoreItem]
}

enum SearchError: Error, LocalizedError {
        case searchFailed
}
    
func fetchItems(matching query: [String: String]) async throws -> [StoreItem] {
    var components = URLComponents(string: "https://itunes.apple.com/search")!
    components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
    
    let (data, response) = try await URLSession.shared.data(from: components.url!)
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw SearchError.searchFailed
    }
    
    let jsonDecoder = JSONDecoder()
    let searchResponse = try jsonDecoder.decode(SearchResponse.self, from: data)
    
    return searchResponse.results
}


Task {
    let queryDictionary: [String: String] = ["term": "the beatles", "media": "music"]
    do {
        let storeItems = try await fetchItems(matching: queryDictionary)
        storeItems.forEach { item in
            print("""
            ***
            Name: \(item.trackName)
            Artist: \(item.artistName)
            Kind: \(item.kind)
            Description: \(item.description)
            Artwork URL: \(item.artworkSmallUrl)
            ***
            """)
        }
    } catch {
        print(error)
    }
}
