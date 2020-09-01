import Foundation

extension NSObject {
    static var typeName: String {
        return String(describing: self)
    }
}
