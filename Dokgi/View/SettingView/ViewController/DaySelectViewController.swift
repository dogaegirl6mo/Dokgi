//
//  DaySelectViewController.swift
//  Dokgi
//
//  Created by 송정훈 on 6/5/24.
//

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

class DaySelectViewController: BaseAlarmSettingSheetViewController {
    
    let tableView = UITableView().then {
        $0.backgroundColor = .white
    }
    
    // MARK: - Layout
    override func setLayout() {
        super.setLayout()
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleStack.snp.bottom).offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview().inset(40)
        }
    }
    
    override func initialize() {
        titleString = "알림 요일 설정"
        viewModel.selectday = DayTimeViewModel.dayCheck.value
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DayTableViewCell.self, forCellReuseIdentifier: DayTableViewCell.identifier)
    }
    
    override func buttonTapped() {
        super.buttonTapped()
        tableView.rx.itemSelected.subscribe { [weak self] item in
            self?.viewModel.dayimage(row: item.row)
            self?.tableView.reloadData()
        }.disposed(by: disposeBag)
    }
    
    override func saveAction() {
        if self.viewModel.selectday.contains(1) == false {
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.writeSwitch.rawValue)
            for i in 0...6 {
                self.viewModel.selectday[i] = 1
            }
        }
        DayTimeViewModel.dayCheck.accept((self.viewModel.selectday))
    }
}

extension DaySelectViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.DayArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DayTableViewCell.identifier, for: indexPath) as? DayTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        if viewModel.selectday[indexPath.row] != 0 {
            cell.check.isHidden = false
            cell.check.image = .check2
        } else {
            cell.check.isHidden = true
        }
        cell.dayLabel.text = viewModel.DayArr[indexPath.row]
        return cell
    }
}
