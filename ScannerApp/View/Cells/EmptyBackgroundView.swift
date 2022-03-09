//
//  EmptyBackgroundView.swift
//  ScannerApp
//
//  Created by Ashfaq Shaikh on 02/03/22.
//

import UIKit

class EmptyBackgroundView: UIView {
    
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDes: UILabel!
    @IBOutlet weak var btnScanNow: UIButton!{
        didSet{
            btnScanNow.layer.cornerRadius = 25
            btnScanNow.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
            btnScanNow.layer.shadowOffset = CGSize(width: 0, height: 3)
            btnScanNow.layer.shadowOpacity = 1.0
            btnScanNow.layer.shadowRadius = 10.0
            btnScanNow.layer.masksToBounds = false
        }
    }
    
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "EmptyBackgroundView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    func setValue(img: UIImage, title: String, des: String){
        self.imgLogo.image = img
        self.lblTitle.text = title
        self.lblDes.text = des
    }
    
}
