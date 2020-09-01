import UIKit
import Alamofire
import AVFoundation

class PhotosViewController: UIViewController {
    @IBOutlet weak var photosTableView: UITableView!

    private let footerHeight: CGFloat = 70

    private var refreshControl = UIRefreshControl()
    private var loadingCell: LoadingCell!

    private var selectedPhoto: Photo?
    private var photos = [Photo]()
    private var currentPageIndex = 0
    private var totalPages = 1
    private var loadMoreEnabled = true

    private var errorHandler = AlertErrorMessageHandler()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPhotosTableView()

        PhotosService.shared.fetchPhotos(page: self.currentPageIndex,
                                         completion: fetchPhotosCompleted)
    }

    private func setupPhotosTableView() {
        self.photosTableView.dataSource = self
        self.photosTableView.delegate = self
        self.photosTableView.register(cellType: PhotoTableViewCell.self)

        setupPhotosTableViewFooter()
    }

    private func setupPhotosTableViewFooter() {
        loadingCell = Bundle.main.loadNibNamed(LoadingCell.typeName,
                                               owner: self.photosTableView,
                                               options: nil)!.first as? LoadingCell
        loadingCell.setMessage(Strings.loadingMessage)
        self.photosTableView.tableFooterView = loadingCell
        self.photosTableView.sectionFooterHeight = footerHeight
        setStatusToActivityIndicator(isRunning: false)
    }

    private func setStatusToActivityIndicator(isRunning: Bool) {
        loadingCell.changeSpinnerStatus(isRunning: isRunning)
        photosTableView.tableFooterView!.isHidden = !isRunning;
    }

    private func setBackdroundMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.photosTableView.bounds.width, height: self.photosTableView.bounds.height))
        messageLabel.text = message
        messageLabel.textColor = .label
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()
        self.photosTableView.backgroundView = messageLabel
    }

    private func loadMore() {
        if currentPageIndex == totalPages {
            setStatusToActivityIndicator(isRunning: false)
            return
        }

        setStatusToActivityIndicator(isRunning: true)
        PhotosService.shared.fetchPhotos(page: self.currentPageIndex, completion: fetchPhotosCompleted)
    }

    private func fetchPhotosCompleted(result: Result<PagingResponce<Photo>, AFError>) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let pagingResponse):
                strongSelf.totalPages = pagingResponse.totalPages
                strongSelf.loadMoreEnabled = true
                strongSelf.currentPageIndex += 1
                strongSelf.updateView(pagingResponse.content)
            case .failure(let error):
                strongSelf.errorHandler.handle(error.localizedDescription)
            }
        }
    }

    private func updateView(_ photos: [Photo]) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.photos.append(contentsOf: photos)
            strongSelf.photosTableView.backgroundView?.isHidden = !strongSelf.photos.isEmpty
            if strongSelf.photos.isEmpty {
                strongSelf.setBackdroundMessage(Strings.noResultsMessage)
            }

            strongSelf.photosTableView.reloadData()
            strongSelf.view.layoutIfNeeded()
        }
    }

    private func uploadPhotoCompleted(result: Result<PhotoUploadModelResponce, AFError>) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            switch result {
            case .success(_):
                AlertDialogHelper.displayAlert(title: Strings.alert,
                                               message: Strings.photoSuccessfullyUploadedMessage)
            case .failure(let error):
                strongSelf.errorHandler.handle(error.localizedDescription)
            }
        }
    }

    private func openImagePickerController() {
        DispatchQueue.main.async {
            let vc = UIImagePickerController()
            vc.sourceType = .camera
            vc.allowsEditing = true
            vc.delegate = self
            self.present(vc, animated: true)
        }
    }
}

extension PhotosViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPhoto = self.photos[indexPath.row]

        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            openImagePickerController()
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    self.openImagePickerController()
                }
            })
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffse = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffse
        if deltaOffset <= 0 && loadMoreEnabled {
            loadMoreEnabled = false
            loadMore()
        }
    }
}

extension PhotosViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: PhotoTableViewCell.self, for: indexPath)
        let photo = self.photos[indexPath.item]
        cell.fillData(imageUrl: photo.image ?? ApiConstants.emptyImageUrl,
                      name: photo.name ?? String.empty)
        return cell
    }
}

extension PhotosViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            AlertDialogHelper.displayAlert(title: Strings.error, message: Strings.takePhotoFailure)
            return
        }

        PhotosService.shared.uploadPhoto(
            photo: PhotoUploadModel(name: Strings.devName,
                                    photo: image,
                                    typeId: String(selectedPhoto!.id)),
            completion: uploadPhotoCompleted)
    }
}
