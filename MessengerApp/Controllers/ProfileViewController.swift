//
//  ProfileViewController.swift
//  MessengerApp
//
//  Created by KM on 27/10/2021.
//

import UIKit
import Firebase
import FacebookLogin
import Kingfisher
import MBProgressHUD
import RSKImageCropper

struct section {
    let title: String
    let options: [settingsOption]
}
struct settingsOption {
    let title: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let handler: (() -> Void)
}

class ProfileViewController: UIViewController {
    
    var models = [section]()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        iv.image = UIImage(named: "profileImage")
//        iv.layer.borderColor = UIColor.black.cgColor
//        iv.layer.borderWidth = 3
        iv.roundedImage()
        return iv
    }()
    
    private lazy var fullNameLabel = CustomLabel(text: "Welcome Back!", font: UIFont.boldSystemFont(ofSize: 20), textAlignment: .center, textColor: .white, numberOfLines: 1)
    private lazy var emailLabel = CustomLabel(text: "", font: .Regular, textAlignment: .center, textColor: .lightGray, numberOfLines: 1)
    
    private var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.register(customCell.self, forCellReuseIdentifier: customCell.identifier)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureModals()
        showUserData()
    }
    
    func setupUI() {
        view.backgroundColor = .mainColor
        title = "Profile"
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let mainView = UIView()
        mainView.backgroundColor = .mainColor
        mainView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainView)
        
        mainView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mainView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainView.heightAnchor.constraint(equalToConstant: 280).isActive = true

        mainView.add(subview: profileImageView) { (v, p) in [
            v.topAnchor.constraint(equalTo: p.topAnchor, constant: 15),
            v.centerXAnchor.constraint(equalTo: p.centerXAnchor),
            v.heightAnchor.constraint(equalToConstant: 200),
            v.widthAnchor.constraint(equalToConstant: 200)
        ]}
        
        mainView.add(subview:emailLabel) { (v, p) in [
            v.centerXAnchor.constraint(equalTo: p.centerXAnchor),
            v.bottomAnchor.constraint(equalTo: p.bottomAnchor, constant: -15)
        ]}
        mainView.add(subview:fullNameLabel) { (v, p) in [
            v.centerXAnchor.constraint(equalTo: p.centerXAnchor),
            v.bottomAnchor.constraint(equalTo: p.bottomAnchor, constant: -35)
        ]}
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
    func configureModals() {
        self.models.append(section(title: "Setting", options: [
            settingsOption(title: "Change Password", icon: UIImage(systemName: "lock"), iconBackgroundColor: UIColor(rgb: 0xAD938D)) {
                self.changePassword()
            },
            settingsOption(title: "Change Profile Image", icon: UIImage(systemName: "person"), iconBackgroundColor: UIColor(rgb: 0xA6C8A0)) {
                self.changeProfileImage()
            },
            settingsOption(title: "Change Mode", icon: UIImage(systemName: "paintpalette.fill"), iconBackgroundColor: .systemGray) {
                self.changeMode()
            }
        ]))
        
        self.models.append(section(title: "Log out", options: [
            settingsOption(title: "Log out", icon: UIImage(systemName: "key.fill"), iconBackgroundColor: .systemRed) {
                self.logout()
            }
        ]))
    }
    
    func showUserData() {
        
        self.fullNameLabel.text = UserDefaults.standard.value(forKey: "name") as? String
        self.emailLabel.text = UserDefaults.standard.value(forKey: "email") as? String
        
        let userPath = UserDefaults.standard.value(forKey: "image") as! String
        StorageManager.shared.downloadURL(for: userPath) { result in
            switch result {
            case .success(let url):
                print("This is: \(url)")
                self.profileImageView.kf.setImage(with: url)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc func changeProfileImage() {
        presentPhotoActionSheet()
    }
    
    @objc func changePassword() {

        let alert = UIAlertController(title: "Enter the new password", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        let passwordTextField = alert.textFields![0]
        passwordTextField.placeholder = "New Password"
        passwordTextField.isSecureTextEntry = true
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            _ in
            let newPassword = passwordTextField.text! as String
            
            Auth.auth().currentUser?.updatePassword(to: newPassword) { (error) in
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
                else {
                    self.showAlert(title: "", message: "Password changed successfully")
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    func changeMode() {
        if self.view.overrideUserInterfaceStyle == .dark {
            self.view.overrideUserInterfaceStyle = .light
        } else {
            self.view.overrideUserInterfaceStyle = .dark
        }
    }
    
    func logout() {
        
        // logout the user
        // show alert
        let actionSheet = UIAlertController(title: "Are you sure to Log Out?", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            // action that is fired once selected
            guard let strongSelf = self else {
                return
            }
            
//            let email = UserDefaults.standard.value(forKey: "email") as? String
//            let safeEmail = DatabaseManger.shared.safeEmail(emailAddress: email!)
//            let userImage = self!.profileImageView.image!.pngData()
//            let fileName = "\(safeEmail)_profilepicture.png"
//            StorageManager.shared.uploadProfilePicture(with: userImage!, fileName: fileName) { result in
//                switch result {
//                    case .success(let url):
//                        print("!!!!!success: \(url)")
//                    case .failure(let error):
//                        print(error.localizedDescription)
//                        print("rrr")
//                    }
//            }
            
            do {
                if DatabaseManger.shared.isLoggedIn() {
                    // Show the ViewController with the logged in user
                    print("**PP** login with facebook")
                    LoginManager().logOut()
                }
                
                
                try FirebaseAuth.Auth.auth().signOut()
                let vc = LoginViewController()
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: false)
            }
            catch {
                print("failed to logout")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)

    }
    
    func showAlert(title: String, message: String) {
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
            alertVC.addAction(action)
            self.present(alertVC, animated: true, completion: nil)
        }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = models[section]
        return section.title
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section].options[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: customCell.identifier, for: indexPath) as? customCell else {
            return UITableViewCell()
        }
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = models[indexPath.section].options[indexPath.row]
        model.handler()
    }
    
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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


extension ProfileViewController: RSKImageCropViewControllerDelegate {
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

extension ProfileViewController {
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
