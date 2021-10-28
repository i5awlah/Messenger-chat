//
//  UIKit.swift
//  MessengerApp
//
//  Created by KM on 27/10/2021.
//
import UIKit
public extension UIView {
    
    /// Adds the selected view to the superview and create constraints through the closure block
    func add(subview: UIView, createConstraints: (_ view: UIView, _ parent: UIView) -> ([NSLayoutConstraint])) {
        addSubview(subview)
        
        subview.activate(constraints: createConstraints(subview, self))
    }
    
//    public func createConstraints (for subview: UIView, topAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>, leadingAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, trailingAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, bottomAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor> ) {
//        self.add(subview: subview) { (v, p) in [
//            v.topAnchor.constraint(equalTo: topAnchor),
//            v.leadingAnchor.constraint(equalTo: leadingAnchor),
//            v.trailingAnchor.constraint(equalTo: trailingAnchor),
//            v.leadingAnchor.constraint(equalTo: leadingAnchor)
//        ]}
//    }
    
    /// Removes specified views in the array
    func remove(subviews: [UIView]) {
        subviews.forEach({
            $0.removeFromSuperview()
        })
    }
    
    /// Activates the given constraints
    func activate(constraints: [NSLayoutConstraint]) {
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(constraints)
    }
    
    /// Deactivates the give constraints
    func deactivate(constraints: [NSLayoutConstraint]) {
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.deactivate(constraints)
    }
    
    /// Lays out the view to fill the superview
    func fillToSuperview(_ subview: UIView) {
        if #available(iOS 11.0, *) {
            self.add(subview: subview) { (v, p) in [
                v.topAnchor.constraint(equalTo: p.safeAreaLayoutGuide.topAnchor),
                v.leadingAnchor.constraint(equalTo: p.safeAreaLayoutGuide.leadingAnchor),
                v.trailingAnchor.constraint(equalTo: p.safeAreaLayoutGuide.trailingAnchor),
                v.bottomAnchor.constraint(equalTo: p.safeAreaLayoutGuide.bottomAnchor)
                ]}
        }
    }
    
    /// Adds a separator line at the bottom of a view
    func addSeparatorLine(color: UIColor) {
        let view = UIView()
        view.backgroundColor = color
        if #available(iOS 9.0, *) {
            add(subview: view) { (v, p) in [
                v.bottomAnchor.constraint(equalTo: p.bottomAnchor),
                v.leadingAnchor.constraint(equalTo: p.leadingAnchor),
                v.trailingAnchor.constraint(equalTo: p.trailingAnchor),
                v.heightAnchor.constraint(equalToConstant: 0.5)
                ]}
        }
    }
    
}
