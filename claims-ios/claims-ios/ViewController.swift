//  Created on 2020/11/25

import UIKit

struct Claim : Codable {
    var id : UUID?
    var title : String
    var date : String
    var isSolved : Bool?
}

class ViewController: UIViewController {

    @IBOutlet weak var tfClaimTitle: UITextField!
    @IBOutlet weak var tfDate: UITextField!
    @IBOutlet weak var btnAdd: UIButton!
    
    @IBOutlet weak var aivLoading: UIActivityIndicatorView!
    @IBOutlet weak var labelSatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }


    @IBAction func actionAdd(_ sender: Any) {
        guard let title = tfClaimTitle.text else {
            return
        }
        guard let date = tfDate.text else {
            return
        }
        guard !title.isEmpty else {
            showAlert(message: "Claim Title should not be empty.")
            return
        }
        guard !date.isEmpty else {
            showAlert(message: "Date should not be empty.")
            return
        }
        let claim = Claim(title: title, date: date)
        addClaim(claim)
    }
    
    func addClaim(_ pObj: Claim) {
        let requestUrl = "http://localhost:8020/ClaimService/add"
        var request = URLRequest(url: NSURL(string: requestUrl)! as URL)
        let jsonData : Data! = try! JSONEncoder().encode(pObj)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        aivLoading.startAnimating()
        aivLoading.isHidden = false
        labelSatus.isHidden = true
        btnAdd.isEnabled = false
        let task = URLSession.shared.uploadTask(with: request, from: jsonData) {
            (data, response, error) in
            DispatchQueue.main.async {
                self.aivLoading.stopAnimating()
                self.labelSatus.isHidden = false
                self.btnAdd.isEnabled = true
            }
            if let resp = data {
                let respStr = String(bytes: resp, encoding: .utf8)
                print("The response data sent from the server is \(respStr!)")
                DispatchQueue.main.async {
                    self.labelSatus.text = "Claim \(pObj.title) was successfully created."
                }
            } else if let respError = error {
                print("Server Error : \(respError)")
                DispatchQueue.main.async {
                    self.labelSatus.text = "Claim \(pObj.title) was failed created."
                }
            }
        }
        task.resume()
    }
    
    func showAlert(message: String?) {
        let alert = UIAlertController(title: "Tip", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

