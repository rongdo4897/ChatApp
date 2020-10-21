//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Hoang Tung Lam on 10/20/20.
//

import UIKit

class LoginViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Login"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        // Add subview
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        
        // hiden keyboard when tap screen
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnScreen))
        scrollView.addGestureRecognizer(tapGestureRecognizer)
        
        // delegate textfield
        emailField.delegate = self
        passwordField.delegate = self
        
        // login button action
        loginButton.addTarget(self, action: #selector(btnLoginTapped), for: .touchUpInside)
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
