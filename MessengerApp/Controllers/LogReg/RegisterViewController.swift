//
//  RegisterViewController.swift
//  MessengerApp
//
//  Created by KM on 27/10/2021.
//

import UIKit
import RSKImageCropper

class RegisterViewController: UIViewController {
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        iv.image = UIImage(named: "profileImage")
        iv.layer.borderColor = UIColor.black.cgColor
        iv.layer.borderWidth = 3
        iv.roundedImage()
        return iv
    }()
    
    private let emailImageView = CustomImageView(ivType: .email)
    private lazy var emailTextField = CustomTextField(tfType: .email)
    private let emailContainerView = UIView()
    
    private let firstNameImageView = CustomImageView(ivType: .email)
    private lazy var firstNameTextField = CustomTextField(tfType: .firstName)
    private let firstNameContainerView = UIView()
    
    private let lastNameImageView = CustomImageView(ivType: .email)
    private lazy var lastNameTextField = CustomTextField(tfType: .lastName)
    private let lastNameContainerView = UIView()
    
    private let passwordImageView = CustomImageView(ivType: .password)
    private lazy var passwordTextField = CustomTextField(tfType: .password)
    private let passwordContainerView = UIView()
    
    private lazy var registerButton: CustomButton = {
        let btn = CustomButton(title: "Register")
        btn.addTarget(self, action: #selector(registerButtonPressed), for: .touchUpInside)
        return btn
    }()
    
    private lazy var signinLabel = CustomLabel(text: "Already have an account?", font: .Regular, textAlignment: .center, textColor: .white, numberOfLines: 1)
    
    private lazy var signinButton: CustomButton = {
        let btn = CustomButton(title: "Sign in", backgroundColor: .clear)
        btn.addTarget(self, action: #selector(signinButtonPressed), for: .touchUpInside)
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .Background
        
        view.add(subview: profileImageView) { (v, p) in [
            v.topAnchor.constraint(lessThanOrEqualTo: p.safeAreaLayoutGuide.topAnchor, constant: 50),
            v.centerXAnchor.constraint(equalTo: p.centerXAnchor),
            v.heightAnchor.constraint(equalToConstant: 200),
            v.widthAnchor.constraint(equalToConstant: 200)
        ]}
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
        profileImageView.isUserInteractionEnabled = true
        
        // Email Container
        view.add(subview: emailContainerView){ (v, p) in [
            v.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            v.leadingAnchor.constraint(equalTo: p.leadingAnchor, constant: 50),
            v.trailingAnchor.constraint(equalTo: p.trailingAnchor, constant: -50),
            v.heightAnchor.constraint(equalToConstant: 55)
        ]}
        Helper.createTextFieldWithAnchor(tf: emailTextField, iv: emailImageView, view: emailContainerView)
        
        // firstName Container
        view.add(subview: firstNameContainerView){ (v, p) in [
            v.topAnchor.constraint(equalTo: emailContainerView.bottomAnchor, constant: 30),
            v.leadingAnchor.constraint(equalTo: p.leadingAnchor, constant: 50),
            v.trailingAnchor.constraint(equalTo: p.trailingAnchor, constant: -50),
            v.heightAnchor.constraint(equalToConstant: 55)
        ]}
        Helper.createTextFieldWithAnchor(tf: firstNameTextField, iv: firstNameImageView, view: firstNameContainerView)
        
        // lastName Container
        view.add(subview: lastNameContainerView){ (v, p) in [
            v.topAnchor.constraint(equalTo: firstNameContainerView.bottomAnchor, constant: 30),
            v.leadingAnchor.constraint(equalTo: p.leadingAnchor, constant: 50),
            v.trailingAnchor.constraint(equalTo: p.trailingAnchor, constant: -50),
            v.heightAnchor.constraint(equalToConstant: 55)
        ]}
        Helper.createTextFieldWithAnchor(tf: lastNameTextField, iv: lastNameImageView, view: lastNameContainerView)
        
        // password Container
        view.add(subview: passwordContainerView){ (v, p) in [
            v.topAnchor.constraint(equalTo: lastNameContainerView.bottomAnchor, constant: 30),
            v.leadingAnchor.constraint(equalTo: p.leadingAnchor, constant: 50),
            v.trailingAnchor.constraint(equalTo: p.trailingAnchor, constant: -50),
            v.heightAnchor.constraint(equalToConstant: 55)
        ]}
        Helper.createTextFieldWithAnchor(tf: passwordTextField, iv: passwordImageView, view: passwordContainerView)
        
        view.add(subview: registerButton){ (v, p) in [
            v.topAnchor.constraint(equalTo: passwordContainerView.bottomAnchor, constant: 30),
            v.leadingAnchor.constraint(equalTo: p.leadingAnchor, constant: 50),
            v.trailingAnchor.constraint(equalTo: p.trailingAnchor, constant: -50),
            v.heightAnchor.constraint(equalToConstant: 55)
        ]}
        
        // signin

        let signinStackView = UIStackView(arrangedSubviews: [signinLabel, signinButton])
        signinStackView.axis = .horizontal
        signinStackView.distribution = .equalSpacing
        view.addSubview(signinStackView)

        signinStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            signinStackView.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 5),
            signinStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signinStackView.widthAnchor.constraint(equalToConstant: 260),
            signinStackView.heightAnchor.constraint(equalToConstant: 30),
            signinButton.widthAnchor.constraint(equalToConstant: 70)
        ])
        
    }
    
    @objc func registerButtonPressed() {
        if let email = emailTextField.text, email.count > 0,
           let password = passwordTextField.text, password.count > 0,
           let firstName = firstNameTextField.text, firstName.count > 0,
           let lastName = lastNameTextField.text, lastName.count > 0 {
            print ("Email: \(email) and Password: \(password)")
            print ("First Name: \(firstName) and Last Name: \(lastName)")
        }
    }
    
    @objc func signinButtonPressed() {
        dismiss(animated: false, completion: nil)
    }
    
    @objc func imageTapped() {
        print("UIImageView tapped")
        presentPhotoActionSheet()
    }
    

}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // get results of user taking picture or selecting from camera roll
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        if profileImageView.image != UIImage(named: "profileImage") {
            actionSheet.addAction(UIAlertAction(title: "Delete Photo", style: .default, handler: { [weak self] _ in
                self?.deletePhoto()
            }))
        }
        
        
        present(actionSheet, animated: true)
    }
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        //vc.allowsEditing = true
        present(vc, animated: true)
    }
    func deletePhoto() {
        profileImageView.image = UIImage(named: "profileImage")
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        let imageCropVC : RSKImageCropViewController!
        imageCropVC = RSKImageCropViewController(image: selectedImage, cropMode: RSKImageCropMode.circle)
        imageCropVC.moveAndScaleLabel.text = "Move And Scale"
        imageCropVC.cancelButton.setTitle("Cancel", for: .normal)
        imageCropVC.chooseButton.setTitle("Choose", for: .normal)
        imageCropVC.delegate = self
        picker.pushViewController(imageCropVC, animated: true)
        
        //self.profileImageView.image = selectedImage
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cccccc")
        picker.dismiss(animated: true, completion: nil)
    }
    
}


extension RegisterViewController: RSKImageCropViewControllerDelegate {
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        
        if controller.cropMode == .circle {
            UIGraphicsBeginImageContext(croppedImage.size)
            let layerView = UIImageView(image: croppedImage)
            layerView.frame.size = croppedImage.size
            layerView.layer.cornerRadius = layerView.frame.size.width * 0.5
            layerView.clipsToBounds = true
            let context = UIGraphicsGetCurrentContext()!
            layerView.layer.render(in: context)
            let capturedImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            let pngData = capturedImage.pngData()!
            self.profileImageView.image = UIImage(data: pngData)!
        }
        dismiss(animated: true, completion: nil)
    }
}
