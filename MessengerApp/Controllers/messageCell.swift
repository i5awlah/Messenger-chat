//
//  messageCell.swift
//  MessengerApp
//
//  Created by KM on 03/11/2021.
//

import UIKit

class messageCell: UITableViewCell {
    static let identifier = "messageCell"
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        iv.image = UIImage(named: "profileImage")
        iv.roundedImage()
        return iv
    }()
    
    private let namelabel = CustomLabel(font: .boldSystemFont(ofSize: 18), textAlignment: .left, textColor: .darkGray, numberOfLines: 1)
    
    private let msglabel = CustomLabel(font: .Regular, textAlignment: .left, textColor: .lightGray, numberOfLines: 2)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(namelabel)
        contentView.addSubview(msglabel)
        contentView.addSubview(profileImageView)
        
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        contentView.add(subview: profileImageView) { (v, p) in [
            v.leadingAnchor.constraint(equalTo: p.leadingAnchor, constant: 20),
            v.centerYAnchor.constraint(equalTo: p.centerYAnchor),
            v.heightAnchor.constraint(equalToConstant: 100),
            v.widthAnchor.constraint(equalToConstant: 100)
        ]}
        contentView.add(subview: namelabel) { (v, p) in [
            v.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            v.centerYAnchor.constraint(equalTo: p.centerYAnchor, constant: -10),
        ]}
        contentView.add(subview: msglabel) { (v, p) in [
            v.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            v.topAnchor.constraint(equalTo: namelabel.bottomAnchor, constant: 5),
            v.trailingAnchor.constraint(equalTo: p.trailingAnchor, constant: -15)
        ]}
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //profileImageView.image = nil
        namelabel.text = nil
        msglabel.text = nil
    }
    
    public func configure(with name: String, textMSG: String, otherUserEmail: String) {
        namelabel.text = name
        msglabel.text = textMSG
        let userPath = "images/" + "\(otherUserEmail)_profilepicture.png"
        StorageManager.shared.downloadURL(for: userPath) { result in
            switch result {
            case .success(let url):
                self.profileImageView.kf.setImage(with: url)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
}
