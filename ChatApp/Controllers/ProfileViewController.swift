//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by Hoang Tung Lam on 10/20/20.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tblProfile:UITableView!
    
    /// - data row table
    let data = ["Logout"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tblProfile.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tblProfile.delegate = self
        tblProfile.dataSource = self
        tblProfile.tableHeaderView = createTableHeader()
        tblProfile.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tblProfile.width, height: 0))
    }

    /// - Create Table Header
    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            return nil
        }
        
        // path image to database storage
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName
        
        // header view table
        let headerView = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: self.view.width,
                                        height: 300))
        headerView.backgroundColor = .link
        
        // image view in header
        let imageView = UIImageView(frame: CGRect(x: (headerView.width - 150) / 2,
                                                  y: 75,
                                                  width: 150,
                                                  height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        imageView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        imageView.layer.borderWidth = 3
        imageView.layer.cornerRadius = imageView.width / 2
        imageView.layer.masksToBounds = true
        
        // add image view into header table
        headerView.addSubview(imageView)
        
        // set image into image view
        StorageManager.share.downloadURL(for: path) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let url):
                strongSelf.downloadImage(imageView: imageView, url: url)
            case .failure(let error):
                print("Failed to download url: \(error)")
            }
        }
        
        return headerView
    }
    
    /// - set image with url
    func downloadImage(imageView: UIImageView, url: URL){
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data , error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }.resume()
    }
}

//MARK: - Table datasource , delegate
extension ProfileViewController: UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actionSheet = UIAlertController(title: "",
                                      message: "",
                                      preferredStyle: .actionSheet)
        
        /// - action sheet logout
        actionSheet.addAction(UIAlertAction(title: "Logout",
                                      style: .destructive,
                                      handler: { [weak self] (_) in
                                        guard let strongSelf = self else {
                                            return
                                        }
                                        
                                        /// - Logout facebook
                                        FBSDKLoginKit.LoginManager().logOut()
                                        
                                        /// - Logout google
                                        GIDSignIn.sharedInstance()?.signOut()
                                        
                                        do {
                                            try FirebaseAuth.Auth.auth().signOut()
                                            
                                            let vc = LoginViewController()
                                            let nav = UINavigationController(rootViewController: vc)
                                            nav.modalPresentationStyle = .fullScreen
                                            strongSelf.present(nav, animated: true)
                                        } catch {
                                            debugPrint("Fail to logout error")
                                        }
                                      }))
        
        /// - action sheet Cancel
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
        
        
    }
}
