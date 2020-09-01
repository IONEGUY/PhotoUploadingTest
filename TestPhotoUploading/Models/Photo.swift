import Foundation

struct Photo: Codable {
    var id: Int
    var name: String?
    var image: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case image
    }
}
