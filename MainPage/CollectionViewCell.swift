import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Styling labels
        TitleLbl.font = UIFont.boldSystemFont(ofSize: 16)
        TitleLbl.textColor = .white
        TitleLbl.textAlignment = .center
        
        locationLbl.font = UIFont.systemFont(ofSize: 12)
        locationLbl.textColor = .darkGray
        locationLbl.textAlignment = .center
        
        dateLbl.font = UIFont.systemFont(ofSize: 12)
        dateLbl.textColor = .lightGray
        dateLbl.textAlignment = .center
    }
}
