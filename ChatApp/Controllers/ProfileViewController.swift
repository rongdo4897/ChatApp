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
    
    let data = ["Logout"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tblProfile.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tblProfile.delegate = self
        tblProfile.dataSource = self
        
    }

}

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
