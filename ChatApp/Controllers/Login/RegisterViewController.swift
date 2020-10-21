//
//  RegisterViewController.swift
//  ChatApp
//
//  Created by Hoang Tung Lam on 10/20/20.
//

import UIKit

class RegisterViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.clipsToBounds = true
        return scroll
    }()
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "person")
        image.tintColor = .gray
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let firstNameField: UITextField = {
        let pass = UITextField()
        // Tự động viết hoa
        pass.autocapitalizationType = .none
        // Tự động sửa
        pass.autocorrectionType = .no
        // Loại khoá
        pass.returnKeyType = .continue
        // layout
        pass.layer.cornerRadius = 12
        pass.layer.borderWidth = 1
        pass.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        pass.placeholder = "First Name ..."
        pass.keyboardType = .emailAddress
        pass.clearButtonMode = .whileEditing
        pass.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: pass.height))
        pass.leftViewMode = .always
        pass.backgroundColor = .white
        pass.isSecureTextEntry = true
        return pass
    }()
    
    private let lastNameField: UITextField = {
        let pass = UITextField()
        // Tự động viết hoa
        pass.autocapitalizationType = .none
        // Tự động sửa
        pass.autocorrectionType = .no
        // Loại khoá
        pass.returnKeyType = .continue
        // layout
        pass.layer.cornerRadius = 12
        pass.layer.borderWidth = 1
        pass.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        pass.placeholder = "Last Name ..."
        pass.keyboardType = .emailAddress
        pass.clearButtonMode = .whileEditing
        pass.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: pass.height))
        pass.leftViewMode = .always
        pass.backgroundColor = .white
        pass.isSecureTextEntry = true
        return pass
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
        button.setTitle("Register", for: .normal)
        button.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        button.backgroundColor = .link
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back",
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(didTapBack))
        
        // Add subview
        view.addSubview(scrollView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        
        // hiden keyboard when tap screen
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnScreen))
        scrollView.addGestureRecognizer(tapGestureRecognizer)
        
        // delegate textfield
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        // login button action
        loginButton.addTarget(self, action: #selector(btnRegisterTapped), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width / 3
        imageView.frame = CGRect(x: (scrollView.width - size) / 2,
                                 y: 10,
                                 width: size,
                                 height: size)
        
        firstNameField.frame = CGRect(x: 30,
                                      y: imageView.bottom + 30,
                                      width: scrollView.width - 60,
                                      height: 52)
        
        lastNameField.frame = CGRect(x: 30,
                                     y: firstNameField.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
        
        emailField.frame = CGRect(x: 30,
                                  y: lastNameField.bottom + 10,
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
    @objc private func btnRegisterTapped(){
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let first = firstNameField.text ,
              let last = lastNameField.text ,
              let email = emailField.text ,
              let pass = passwordField.text ,
              !first.isEmpty , !last.isEmpty , !email.isEmpty , !pass.isEmpty , pass.count >= 6 else {
            
            alertUserLoginError(title: "", messeage: "Please enter full information create new account and password length more than 6 !")
            return
        }
    }
    
    func alertUserLoginError(title:String , messeage:String){
        let alert = UIAlertController(title: title, message: messeage, preferredStyle: .alert)
        let alertItemOK = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(alertItemOK)
        present(alert, animated: true)
    }
    
    @objc private func didTapBack(){
        navigationController?.popViewController(animated: true)
    }
    
    // Hide keyboard when tap out textfield
    @objc func tapOnScreen() {
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
}

extension RegisterViewController : UITextFieldDelegate {
    
    //Hỏi người được ủy quyền có xử lý việc nhấn nút Quay lại cho trường văn bản hay không.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstNameField {
            // an continue -> password
            lastNameField.becomeFirstResponder()
        }
        else if textField == lastNameField {
            emailField.becomeFirstResponder()
        }
        else if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            // an done -> btn Login
            btnRegisterTapped()
        }
        return true
    }
}
