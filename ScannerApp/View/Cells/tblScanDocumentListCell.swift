//
//  tblScanDocumentListCell.swift
//  ScannerApp
//
//  Created by Ashfaq Shaikh on 02/03/22.
//

import UIKit

class tblScanDocumentListCell: UITableViewCell {

    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnCheckmark: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgThumbnail.applyshadowWithCorner(containerView: self.vwContainer, cornerRadious: 10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
