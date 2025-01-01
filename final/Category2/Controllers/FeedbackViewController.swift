//
//  FeedbackViewController.swift
//  final
//
//  Created by MacBookPro on 31/12/2024.
//

import UIKit
import FirebaseFirestore

class FeedbackViewController: UIViewController {

    @IBOutlet weak var txtViewFeedback: UITextField!
    @IBOutlet weak var ratings: RatingController!
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        ratings.starsRating = 1
       
        // Do any additional setup after loading the view.
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    
    @IBAction func actionFeedback(_ sender: Any) {
        if ratings.starsRating == 0 {
            self.showError("Please add rating")
        }
        else if txtViewFeedback.text == ""{
            self.showError("Please write feedback")
        }
        else{
            let feedbackData: [String: Any] = [
                "feedback": self.txtViewFeedback.text ?? "",
                "rating": self.ratings.starsRating,
            ]

            db.collection("Feedback").addDocument(data: feedbackData) { error in
                if let error = error {
                    self.showError("Error adding the feedback")
                } else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "FeedbackAlertViewController")
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
            }
        }
    }
   
    @IBAction func actionReport(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReportViewController") as! ReportViewController
        self.navigationController?.pushViewController(vc, animated: true)
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


class RatingController: UIStackView {
    var starsRating = 0
    var starsEmptyPicName = "star" // change it to your empty star picture name
    var starsFilledPicName = "starfill" // change it to your filled star picture name
    override func draw(_ rect: CGRect) {
        let starButtons = self.subviews.filter{$0 is UIButton}
        var starTag = 1
        for button in starButtons {
            if let button = button as? UIButton{
                button.setImage(UIImage(named: starsEmptyPicName), for: .normal)
                button.addTarget(self, action: #selector(self.pressed(sender:)), for: .touchUpInside)
                button.tag = starTag
                starTag = starTag + 1
            }
        }
       setStarsRating(rating:starsRating)
    }
    func setStarsRating(rating:Int){
        self.starsRating = rating
        let stackSubViews = self.subviews.filter{$0 is UIButton}
        for subView in stackSubViews {
            if let button = subView as? UIButton{
                if button.tag > starsRating {
                    button.setImage(UIImage(named: starsEmptyPicName), for: .normal)
                }else{
                    button.setImage(UIImage(named: starsFilledPicName), for: .normal)
                }
            }
        }
    }
    @objc func pressed(sender: UIButton) {
        setStarsRating(rating: sender.tag)
    }
}
