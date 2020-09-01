import Foundation

struct PagingResponce<T: Codable>: Codable{
    var page: Int
    var pageSize: Int
    var totalPages: Int
    var totalElements: Int
    var content: [T]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pageSize
        case totalPages
        case totalElements
        case content
    }
}
