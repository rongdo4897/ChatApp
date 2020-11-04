//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Hoang Tung Lam on 10/20/20.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.clipsToBounds = true
        return scroll
    }()
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "logo")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let emailField: UITextField = {
        let email = UITextField()
        // Tự động viết hoa
        email.autocapitalizationType = .none
        // Tự động sửa
        email.autocorrectionType = .no
        // Loại khoá
        email.returnKeyType = .continue
        // layout
        email.layer.cornerRadius = 12
        email.layer.borderWidth = 1
        email.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        email.placeholder = "Email Address ..."
        email.keyboardType = .emailAddress
        email.clearButtonMode = .whileEditing
        email.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: email.height))
        email.leftViewMode = .always
        email.backgroundColor = .white
        return email
    }()
    
    private let passwordField: UITextField = {
        let pass = UITextField()
        // Tự động viết hoa
        pass.autocapitalizationType = .none
        // Tự động sửa
        pass.autocorrectionType = .no
        // Loại khoá
        pass.returnKeyType = .done
        // layout
        pass.layer.cornerRadius = 12
        pass.layer.borderWidth = 1
        pass.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        pass.placeholder = "Password ..."
        pass.keyboardType = .emailAddress
        pass.clearButtonMode = .whileEditing
        pass.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: pass.height))
        pass.leftViewMode = .always
        pass.backgroundColor = .white
        pass.isSecureTextEntry = true
        return pass
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        button.backgroundColor = .link
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        return button
    }()
    
    private let loginFacebookButton:FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email,public_profile"]
        return button
    }()
    
    private let loginGoogleButton = GIDSignInButton()
    
    private var loginObserver:NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLoginNotification,
                                               object: nil,
                                               queue: .main) { [weak self] (_) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        navigationItem.title = "Login"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        loginFacebookButton.delegate = self
        
        // Add subview
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(loginFacebookButton) //login facebook
        scrollView.addSubview(loginGoogleButton)
        
        // hiden keyboard when tap screen
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnScreen))
        scrollView.addGestureRecognizer(tapGestureRecognizer)
        
        // delegate textfield
        emailField.delegate = self
        passwordField.delegate = self
        
        // login button action
        loginButton.addTarget(self, action: #selector(btnLoginTapped), for: .touchUpInside)
        
    }
    
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width / 3
        imageView.frame = CGRect(x: (scrollView.width - size) / 2,
                                 y: 10,
                                 width: size,
                                 height: size)
        
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom + 30,
                                  width: scrollView.width - 60,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
        
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom + 10,
                                   width: scrollView.width - 60,
                                   height: 52)
        
        loginFacebookButton.frame = CGRect(x: 30,
                                           y: loginButton.bottom + 10,
                                           width: scrollView.width - 60,
                                           height: 52)
        
        loginGoogleButton.frame = CGRect(x: 30,
                                           y: loginFacebookButton.bottom + 10,
                                           width: scrollView.width - 60,
                                           height: 52)
    }
    
    // tap login button
    @objc private func btnLoginTapped(){
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text , let pass = passwordField.text ,
              !email.isEmpty , !pass.isEmpty , pass.count >= 6 else {
            alertUserLoginError(title: "", messeage: "Please enter full information login and password length more than 6 !")
            return
        }
        
        spinner.show(in: view)
        
        /// - Firebase Login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: pass) { [weak self] (authResult, error) in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult , error == nil else {
                return
            }
            
            let user = result.user
            
            // UserDefault email when login account
            UserDefaults.standard.set(email,forKey: "email")
            
            /// - If exist -> dismiss 
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func alertUserLoginError(title:String , messeage:String){
        let alert = UIAlertController(title: title, message: messeage, preferredStyle: .alert)
        let alertItemOK = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(alertItemOK)
        present(alert, animated: true)
    }
    
    // tap button item bar Register
    @objc private func didTapRegister(){
        let vc = RegisterViewController()
        vc.navigationItem.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Hide keyboard when tap out textfield
    @objc func tapOnScreen() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
}

//MARK: - TextField delegate
extension LoginViewController : UITextFieldDelegate {
    
    //Hỏi người được ủy quyền có xử lý việc nhấn nút Quay lại cho trường văn bản hay không.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            // an continue -> password
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            // an done -> btn Login
            btnLoginTapped()
        }
        return true
    }
}

//MARK: - Login button delegate
extension LoginViewController : LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no operation
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            debugPrint("User failed to login facebook")
            return
        }
        
        /// - facebook request
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields":"email, first_name, last_name, picture.type(large)"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        
        facebookRequest.start { (connection, result, error) in
            guard let result = result as? [String:Any], error == nil else {
                debugPrint("Failed to make facebook graph request")
                return
            }

            guard let firstName = result["first_name"] as? String ,
                  let lastName = result["last_name"] as? String ,
                  let email = result["email"] as? String ,
                  let picture = result["picture"] as? [String:Any] ,
                  let data = picture["data"] as? [String:Any] ,
                  let pictureUrl = data["url"] as? String else {
                
                debugPrint("Fail to get email and name from fb result")
                return
            }
            
            // UserDefault email when login facebook
            UserDefaults.standard.set(email,forKey: "email")
      
            DatabaseManager.shared.checkUserExists(with: email) { (exists) in
                if !exists {
                    let chatUser = ChatAppUser(firstName: firstName,
                                               lastName: lastName,
                                               emailAddress: email)
                    DatabaseManager.shared.insertUser(with: chatUser) { (success) in
                        if success {
                            
                            guard let url = URL(string: pictureUrl) else {
                                return
                            }
        
                            URLSession.shared.dataTask(with: url) { (data, _, _) in
                                guard let data = data else {
                                    return
                                }
                                
                                /// - upload image
                                // file name
                                let fileName = chatUser.profilePictureFileName
                                // upload image to database
                                StorageManager.share.uploadProfilePicture(with: data, fileName: fileName) { (result) in
                                    switch result {
                                    case .success(let downloadUrl):
                                        // user default url image
                                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                    case .failure(let error):
                                        print("Storage manager error: \(error)")
                                    }
                                }
                            }.resume()
                        }
                    }
                }
            }
            
            /// - credential
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
                guard let strongSelf = self else {
                    return
                }
                
                guard authResult != nil , error == nil else {
                    if let error = error {
                        debugPrint("Facebook login failed - \(error)")
                    }
                    return
                }
                
                debugPrint("Successfully logged user in facebook")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
