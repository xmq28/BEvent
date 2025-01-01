//
//  ReportAlertViewController.swift
//  final
//
//  Created by MacBookPro on 31/12/2024.
//

import UIKit

class ReportAlertViewController: UIViewController {

   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func actionDone(_ sender: Any) {
        if let navigationController = self.navigationController {
            for viewController in navigationController.viewControllers {
                if let targetVC = viewController as? FeedbackViewController {
                    // Pop to the specific view controller
                    navigationController.popToViewController(targetVC, animated: true)
                    break
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
