//
//  RegisterViewController.swift
//  MessengerApp
//
//  Created by KM on 27/10/2021.
//

import UIKit
import Firebase
import RSKImageCropper
import MBProgressHUD

class RegisterViewController: UIViewController {
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        iv.image = UIImage(named: "profileImage")
        iv.layer.borderColor = UIColor.black.cgColor
        iv.layer.borderWidth = 3
        iv.roundedImage()
        return iv
    }()
    
    private lazy var emailImageView = CustomImageView(ivType: .email)
    private lazy var emailTextField = CustomTextField(tfType: .email)
    private lazy var emailContainerView = UIView()
    
    private lazy var firstNameImageView = CustomImageView(ivType: .name)
    private lazy var firstNameTextField = CustomTextField(tfType: .firstName)
    private lazy var firstNameContainerView = UIView()
    
    private lazy var lastNameImageView = CustomImageView(ivType: .name)
    private lazy var lastNameTextField = CustomTextField(tfType: .lastName)
    private lazy var lastNameContainerView = UIView()
    
    private lazy var passwordImageView = CustomImageView(ivType: .password)
    private lazy var passwordTextField = CustomTextField(tfType: .password)
    private lazy var passwordContainerView = UIView()
    
    private lazy var registerButton: CustomButton = {
        let btn = CustomButton(title: "Register")
        btn.addTarget(self, action: #selector(registerButtonPressed), for: .touchUpInside)
        return btn
    }()
    
    private lazy var signinLabel: CustomLabel = {
        let lbl = CustomLabel(text: "", font: .Regular, textAlignment: .center, textColor: .white, numberOfLines: 1)
        let attributedString = NSMutableAttributedString(string: "Already have an account? ")
        attributedString.append(NSAttributedString(string: "Sign in", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)] ))
        lbl.attributedText = attributedString
        lbl.isUserInteractionEnabled = true
        lbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signinButtonPressed)))
        return lbl
    }()
    
    // ********************************************** viewDidLoad **********************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .Background
        
        // Profie image
        view.add(subview: profileImageView) { (v, p) in [
            v.topAnchor.constraint(lessThanOrEqualTo: p.safeAreaLayoutGuide.topAnchor, constant: 50),
            v.centerXAnchor.constraint(equalTo: p.centerXAnchor),
            v.heightAnchor.constraint(equalToConstant: 200),
            v.widthAnchor.constraint(equalToConstant: 200)
        ]}
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
        profileImageView.isUserInteractionEnabled = true

        // Email, First Name, Last Name, Password and Register Button
        let dataStackView = UIStackView(arrangedSubviews: [emailContainerView,firstNameContainerView, lastNameContainerView, passwordContainerView, registerButton])
        dataStackView.axis = .vertical
        dataStackView.distribution = .fillEqually
        dataStackView.spacing = 30
        view.addSubview(dataStackView)
        dataStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dataStackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            dataStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            dataStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
        ])
        Helper.createTextFieldWithAnchor(tf: emailTextField, iv: emailImageView, view: emailContainerView)
        Helper.createTextFieldWithAnchor(tf: firstNameTextField, iv: firstNameImageView, view: firstNameContainerView)
        Helper.createTextFieldWithAnchor(tf: lastNameTextField, iv: lastNameImageView, view: lastNameContainerView)
        Helper.createTextFieldWithAnchor(tf: passwordTextField, iv: passwordImageView, view: passwordContainerView)
        
        // Already have an account? sign in
        view.add(subview: signinLabel) { v, p in [
            v.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 7),
            v.centerXAnchor.constraint(equalTo: p.centerXAnchor)
        ]}
        
    }
    
    // ********************************************** func **********************************************
    
    @objc func registerButtonPressed() {
        createNewUser()
    }
    
    @objc func signinButtonPressed() {
        dismiss(animated: false, completion: nil)
    }
    
    @objc func imageTapped() {
        print("UIImageView tapped")
        presentPhotoActionSheet()
    }
    
    func createNewUser() {
        guard let firstName = firstNameTextField.text else {return}
        guard let lastName = lastNameTextField.text else {return}
            if emailTextField.text != nil || emailTextField.text != "" {
                Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authResult: AuthDataResult?, error: Error?) in
                    if let error = error {
                        self.showAlert(message: error.localizedDescription)
                        //print(error.localizedDescription)
                    } else {
                        print("user succesfully created account: \(self.emailTextField.text!)")
                        let newUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: self.emailTextField.text!)
                        DatabaseManger.shared.insertUser(with: newUser) { boolreselt in
                            print(boolreselt)
                        }
                        
                        let userImage = self.profileImageView.image?.pngData()
                        let fileName = "\(newUser.safeEmail)_profilepicture.png"
                        StorageManager.shared.uploadProfilePicture(with: userImage!, fileName: fileName) { result in
                            switch result {
                                case .success(let url):
                                    print("This is: \(url)")
                                case .failure(let error):
                                    print(error.localizedDescription)
                                }
                        }
                        //profileImageView.image
                        self.openConversationVC()
                    }
                }
            } else {
                showAlert(message: "Please enter a valid email")
            }
        }
    
    func openConversationVC() {
        let vc = tabBarVC()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
    }
    
    func showAlert(message: String) {
            let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
            alertVC.addAction(action)
            self.present(alertVC, animated: true, completion: nil)
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
        present(vc, animated: true)
    }
    func presentPhotoPicker() {
        self.showHUD(progressLabel: "Loading...")
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
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
        dismissHUD(isAnimated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        dismissHUD(isAnimated: true)
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

extension RegisterViewController {
    func showHUD(progressLabel:String){
        DispatchQueue.main.async{
            let progressHUD = MBProgressHUD.showAdded(to: (self.view)!, animated: true)
            progressHUD.label.text = progressLabel
        }
    }

    func dismissHUD(isAnimated:Bool) {
        DispatchQueue.main.async{
            MBProgressHUD.hide(for: (self.view)!, animated: isAnimated)
        }
    }
}
