import Foundation
import Alamofire

class PhotosService {
    static var shared = PhotosService()

    func fetchPhotos(page: Int, completion: @escaping (Result<PagingResponce<Photo>, AFError>) -> ()) {
        AF.request("\(ApiConstants.baseApiUrl)photo/type?page=\(page)")
            .validate()
            .responseDecodable(of: PagingResponce<Photo>.self) { completion($0.result) }
    }

    func uploadPhoto(photo: PhotoUploadModel,
                     completion: @escaping (Result<PhotoUploadModelResponce, AFError>) -> ()) {
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(photo.photo.jpegData(compressionQuality: 1),
                                     withName: "photo",
                                     fileName: "image.jpeg",
                                     mimeType: "image/jpeg")
            for (key, value) in ["name": photo.name, "typeId": photo.typeId] {
                multipartFormData.append(value.data(using: String.Encoding.utf8), withName: key)
            }
        }, to: "\(ApiConstants.baseApiUrl)photo")
            .validate()
            .responseDecodable(of: PhotoUploadModelResponce.self,
                               completionHandler: { completion($0.result) })
    }
}
