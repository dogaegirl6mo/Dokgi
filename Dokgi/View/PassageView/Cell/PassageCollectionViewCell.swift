//
//  ParagraphCollectionViewCell.swift
//  Dokgi
//
//  Created by t2023-m0095 on 6/10/24.
//
import SnapKit
import UIKit

protocol PassageCollectionViewCellDelegate: AnyObject {
    func tappedDeleteButton(in cell: PassageCollectionViewCell)
}

class PassageCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PassageCollectionViewCell"
    
    let deleteButton = UIButton()
    let passageLabel = UILabel()
    let bookTitleLabel = UILabel()
    weak var delegate: PassageCollectionViewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setCell()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCell() {
        deleteButton.setImage(.deleteParagraph, for: .normal)
        deleteButton.addTarget(self, action: #selector(tappedDeleteButton), for: .touchUpInside)

        passageLabel.font = Pretendard.regular.dynamicFont(style: .subheadline)
        passageLabel.numberOfLines = 0  //자동 줄바꿈
        passageLabel.lineBreakMode = .byCharWrapping
        passageLabel.textColor = .black
        
        bookTitleLabel.font = Pretendard.regular.dynamicFont(style: .caption2)
        bookTitleLabel.textColor = .alarmMemoGray
        bookTitleLabel.numberOfLines = 3
        bookTitleLabel.lineBreakMode = .byCharWrapping
    }
    
    func setConstraints() {
        [deleteButton, passageLabel, bookTitleLabel].forEach {
            contentView.addSubview($0)
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(-7)
            $0.width.height.equalTo(26)
        }
        
        passageLabel.snp.makeConstraints {
            $0.top.trailing.leading.equalToSuperview().inset(15)
        }
        
        bookTitleLabel.snp.makeConstraints {
            $0.top.equalTo(passageLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(15)
        }
    }
    
    func setColor(with indexPath: IndexPath) {
        let colors = ["LightSkyBlue", "LightPastelBlue", "LavenderBlue", "LavenderDarkBlue"]
        let colorName = colors[indexPath.item % colors.count]
        contentView.backgroundColor = UIColor(named: colorName) ?? .gray
        contentView.layer.cornerRadius = 20
    }
    
    @objc private func tappedDeleteButton() {
        delegate?.tappedDeleteButton(in: self)
    }
}
