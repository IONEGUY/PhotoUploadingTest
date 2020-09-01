import UIKit
import SDWebImage

class PhotoTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var photo: UIImageView!
    
    func fillData(imageUrl: String, name: String) {
        self.name.text = name
        self.photo.sd_setImage(with: URL(string: imageUrl), completed: nil)
    }
}
