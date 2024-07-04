//
//  CustomNavigationController.swift
//  Dokgi
//
//  Created by 송정훈 on 7/2/24.
//

import RxCocoa
import RxSwift
import UIKit

class CustomNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    let disposeBag = DisposeBag()

    let backButton = UIButton().then {
        $0.setImage(UIImage.backicon, for: .normal)
        $0.setTitle("Back", for: .normal)
        $0.setTitleColor(.brightBlue, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        $0.sizeToFit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        setupCustomBackButton(for: viewController)
        super.pushViewController(viewController, animated: animated)
    }
    
    private func setupCustomBackButton(for viewController: UIViewController) {
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        viewController.navigationItem.leftBarButtonItem = backBarButtonItem
        
        backButton.rx.tap.subscribe(with: self) { (self, _) in
            self.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            return viewControllers.count > 1
        }
}
