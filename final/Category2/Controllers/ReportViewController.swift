//
//  ReportViewController.swift
//  final
//
//  Created by MacBookPro on 31/12/2024.
//

import UIKit
import FirebaseFirestore

class ReportViewController: UIViewController {

    @IBOutlet weak var txtfReport: UITextField!
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    
    @IBAction func actionReport(_ sender: Any) {
        if txtfReport.text == ""{
            self.showError("Please write report text")
        }
        else{
            let feedbackData: [String: Any] = [
                "report": self.txtfReport.text ?? "",
            ]

            db.collection("Reports").addDocument(data: feedbackData) { error in
                if let error = error {
                    self.showError("Error adding the report")
                } else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReportAlertViewController") as! ReportAlertViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
