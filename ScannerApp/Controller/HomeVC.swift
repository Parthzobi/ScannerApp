//
//  HomeVC.swift
//  ScannerApp
//
//  Created by Ashfaq Shaikh on 01/03/22.
//

import UIKit
import WeScan

class HomeVC: UIViewController{
    
    @IBOutlet weak var tblScanDocumentList: UITableView!{
        didSet{
            tblScanDocumentList.delegate = self
            tblScanDocumentList.dataSource = self
            tblScanDocumentList.tableFooterView = UIView()
            tblScanDocumentList.backgroundColor = UIColor.white
            tblScanDocumentList.backgroundView?.backgroundColor = UIColor.white
        }
    }
    @IBOutlet weak var btnShare: UIButton!{
        didSet{
            btnShare.layer.cornerRadius = 25
            btnShare.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
            btnShare.layer.shadowOffset = CGSize(width: 0, height: 3)
            btnShare.layer.shadowOpacity = 1.0
            btnShare.layer.shadowRadius = 10.0
            btnShare.layer.masksToBounds = false
        }
    }
    
    var originalScan: ImageScannerResults?
    var selectedDoc = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblScanDocumentList.register(UINib.init(nibName: "tblScanDocumentListCell", bundle: nil), forCellReuseIdentifier: "tblScanDocumentListCell")
        self.setupEmptyBackgroundView()
        guard let scanData = self.originalScan else { return }
        APIManager.arrImageScannerResults.append(scanData)
        self.tblScanDocumentList.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View Appear")
    }

    static func instance() -> HomeVC{
        return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
    }
    
    @IBAction func btnCameraTap(_ sender: UIBarButtonItem) {
        self.openCamera()
    }
    
    @IBAction func btnShare(_ sender: UIButton) {
        let alert = UIAlertController.init(title: "Share", message: "Select Any One Option To Share", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction.init(title: "PDF", style: .default, handler: { action in
            self.shareImageAndPDF(isImageShare: false)
        }))
        alert.addAction(UIAlertAction.init(title: "Share Image", style: .default, handler: { action in
            self.shareImageAndPDF()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { action in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func shareImageAndPDF(isImageShare: Bool = true){
        if isImageShare{
            var arrImage = [AnyObject]()
            self.selectedDoc.forEach { str in
                if let index = APIManager.arrImageScannerResults.firstIndex(where: { obj in
                    obj.originalScan.image.accessibilityIdentifier ?? "" == str
                }){
                    arrImage.append(APIManager.arrImageScannerResults[index].enhancedScan != nil ? APIManager.arrImageScannerResults[index].enhancedScan!.image : APIManager.arrImageScannerResults[index].originalScan.image)
                }
            }
            let activityViewController = UIActivityViewController(activityItems: arrImage , applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }else{
            var arrImage = [UIImage]()
            self.selectedDoc.forEach { str in
                if let index = APIManager.arrImageScannerResults.firstIndex(where: { obj in
                    obj.originalScan.image.accessibilityIdentifier ?? "" == str
                }){
                    arrImage.append(APIManager.arrImageScannerResults[index].enhancedScan != nil ? APIManager.arrImageScannerResults[index].enhancedScan!.image : APIManager.arrImageScannerResults[index].originalScan.image)
                }
            }
            if let imageShare = arrImage.makePDF()?.dataRepresentation(){
                let activityViewController = UIActivityViewController(activityItems: [imageShare] , applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func setupEmptyBackgroundView() {
        let image = UIImage(named: "no_document")!
        let topMessage = "Nothing In Here"
        let bottomMessage = "You haven't any document yet!"
        let emptyBackgroundView = EmptyBackgroundView.instanceFromNib() as! EmptyBackgroundView
        emptyBackgroundView.setValue(img: image, title:topMessage, des:bottomMessage)
        emptyBackgroundView.btnScanNow.addAction(UIAction.init(handler: { action in
            self.openCamera()
        }), for: .touchUpInside)
        tblScanDocumentList.backgroundView = emptyBackgroundView
    }
    
    private func openCamera(){
        guard let vc = sceneDelegate?.scannerViewController else { return }
        sceneDelegate?.window?.switchRootViewController(to: vc, options: .transitionFlipFromLeft)
    }

}

extension HomeVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if APIManager.arrImageScannerResults.count == 0 {
            tableView.backgroundView?.isHidden = false
        } else {
            tableView.backgroundView?.isHidden = true
        }
        return APIManager.arrImageScannerResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tblScanDocumentListCell", for: indexPath) as! tblScanDocumentListCell
        let obj = APIManager.arrImageScannerResults[indexPath.row]
        cell.lblName.text = obj.originalScan.image.accessibilityIdentifier ?? "N/A"
        cell.imgThumbnail.image = obj.enhancedScan != nil ? obj.enhancedScan?.image : obj.originalScan.image
        cell.btnCheckmark.isHidden = !self.selectedDoc.contains(obj.originalScan.image.accessibilityIdentifier ?? "")
        cell.btnCheckmark.addAction(UIAction.init(handler: { action in
            if self.selectedDoc.contains(obj.originalScan.image.accessibilityIdentifier ?? ""){
                if let index = self.selectedDoc.firstIndex(of: obj.originalScan.image.accessibilityIdentifier ?? ""){
                    self.selectedDoc.remove(at: index)
                }
            }else{
                self.selectedDoc.append(obj.originalScan.image.accessibilityIdentifier ?? "")
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
            self.btnShare.isHidden = self.selectedDoc.count <= 0
        }), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = APIManager.arrImageScannerResults[indexPath.row]
        if self.selectedDoc.contains(obj.originalScan.image.accessibilityIdentifier ?? ""){
            if let index = self.selectedDoc.firstIndex(of: obj.originalScan.image.accessibilityIdentifier ?? ""){
                self.selectedDoc.remove(at: index)
            }
        }else{
            self.selectedDoc.append(obj.originalScan.image.accessibilityIdentifier ?? "")
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
        self.btnShare.isHidden = self.selectedDoc.count <= 0
    }
}
