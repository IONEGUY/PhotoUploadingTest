import Foundation

struct PhotoUploadModelResponce: Codable {
    var id: String
    
    enum CodingKeys: String, CodingKey {
        case id
    }
}
