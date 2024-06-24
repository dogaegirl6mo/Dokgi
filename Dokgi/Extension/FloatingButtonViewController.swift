//
//  FloatingButtonViewController.swift
//  Dokgi
//
//  Created by IMHYEONJEONG on 6/20/24.
//

import SnapKit
import UIKit

extension UIViewController {
    func setFloatingButton() {
        let floatButton = FloatButton()
        view.addSubview(floatButton)
        
        floatButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-25)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-40)
            $0.width.height.equalTo(70)
        }
        
        floatButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    @objc func didTapButton() {
        let addVC = AddPassageViewController()
        self.navigationController?.pushViewController(addVC, animated: true)
    }
}
