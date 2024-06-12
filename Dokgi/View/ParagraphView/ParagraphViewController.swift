//
//  ParagraphViewController.swift
//  Dokgi
//
//  Created by t2023-m0095 on 6/10/24.
//
import SnapKit
import UIKit

class ParagraphViewController: UIViewController {
    
    private let paragraphLabel = UILabel()
    private let selectionButton = UIButton()
    private let selectionButtonImageView = UIImageView()
    private let selectionButtonLabel = UILabel()
    private let doneButton = UIButton()
    private let searchBar = UISearchBar()
    
    private let sortButton = UIButton()
    private let sortButtonImageView = UIImageView()
    private let sortButtonTitleLabel = UILabel()
    
    private let sortMenuView = UIView()
    private let latestFirstButton = UIButton()
    private let oldestFirstButton = UIButton()
    private let latestFirstcheckImageView = UIImageView()
    private let oldestFirstcheckImageView = UIImageView()
    private let latestTextLabel = UILabel()
    private let oldestTextLabel = UILabel()
    
    private var isLatestFirst: Bool = true
    private var isOldestFirst: Bool = false
    private var isEditingMode: Bool = false
    private var selectedIndexPaths = [IndexPath]()
    
    private let emptyMessageLabel = UILabel()
    
    lazy var paragraphCollectionView: UICollectionView = {
        let layout = ParagraphCollectionViewLayout()
        layout.delegate = self
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 1, left: 14, bottom: 14, right: 14)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ParagraphCollectionViewCell.self, forCellWithReuseIdentifier: ParagraphCollectionViewCell.identifier)
        
        return collectionView
    }()
    
    var paragraphData = [
        ("짧은 텍스트입니다끝", "24.05.26"),
        ("짧은 텍스트입니다. 짧은 텍스트입니다. 짧은 텍스트입니다. 짧은 텍스트입니다끝", "24.05.27"),
        ("뭘 쓰고 싶었는지 전혀 기억이 나지 않았다. 아무 것도 쓰기 싫었다. 그저 빨리 돌아가 씻고 싶을 뿐이었다. 뭘 쓰고 싶었는지 전혀 기억이 나지 않았다. 아무 것도 쓰기 싫었다. 그저 빨리 돌아가 씻고 싶을 뿐이었다. 뭘 쓰고 싶었는지 전혀 기억이 나지 않았다. 아무 것도 쓰기 싫었다. 그저 빨리 돌아가 씻고 싶을 뿐이었다. 뭘 쓰고 싶었는지 전혀 기억이끝", "24.06.12"),
        ("짧은 텍스트입니.짧은 텍스트입니.짧은 텍스트입니끝", "24.05.29"),
        ("뭘 쓰고 싶었는지 전혀 기억이 나지 않았다. 아무 것도 쓰기 싫었다. 그저 빨리 돌아가 씻고 싶을 뿐이었다. 뭘 쓰고 싶었는지 전혀 기억이 나지 않았다. 아무 것도 쓰기 싫었다. 그저 빨리 돌아가 씻고 싶을 뿐이었다끝", "24.05.30"),
        ("뭘 쓰고 싶었는지 전혀 기억이 나지 않았다. 아무 것도 쓰기 싫었다. 그저 빨리 돌아가 씻고 싶을 뿐이었다 끝", "24.06.06"),
        ("뭘 쓰고 싶었는지 전혀 기억이 나지 않았다. 아무 것도 쓰기 싫었다. 그저 빨리 돌아가 씻고 싶을 뿐이었다 끝", "24.06.08"),
        ("뭘 쓰고 싶었는지 전혀 기억이 나지 않았다. 아무 것도 쓰기 싫었다. 그저 빨리 돌아가 씻고 싶을 뿐이었다 끝", "24.06.10")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setConstraints()
        setSearchBar()
        setSortMenuView()
    }
    
    private func setUI() {
        view.backgroundColor = .white
        
        paragraphLabel.text = "구절"
        paragraphLabel.font = Pretendard.bold.dynamicFont(style: .title1)
        paragraphLabel.textColor = .black
        
        selectionButton.backgroundColor = .white
        selectionButton.addTarget(self, action: #selector(tappedSelectionButton), for: .touchUpInside)
        
        selectionButtonImageView.image = UIImage(named: "Filter")
        
        selectionButtonLabel.text = "선택"
        selectionButtonLabel.font = Pretendard.medium.dynamicFont(style: .subheadline)
        selectionButtonLabel.textColor = UIColor(named: "CharcoalBlue")
        selectionButton.sizeToFit()
        
        doneButton.backgroundColor = .white
        doneButton.isHidden = true
        doneButton.addTarget(self, action: #selector(tappedDoneButton), for: .touchUpInside)
        doneButton.titleLabel?.font = Pretendard.medium.dynamicFont(style: .subheadline)
        doneButton.setTitle("완료", for: .normal)
        doneButton.setTitleColor(UIColor(named: "BrightRed"), for: .normal)
        
        sortButton.backgroundColor = UIColor(named: "LightSkyBlue")
        sortButton.layer.cornerRadius = 15
        sortButton.clipsToBounds = true
        sortButton.addTarget(self, action: #selector(showSortMenuView), for: .touchUpInside)
        
        sortButtonImageView.image = UIImage(named: "down")
        
        sortButtonTitleLabel.text = "최신순"
        sortButtonTitleLabel.font = Pretendard.regular.dynamicFont(style: .footnote)
        sortButtonTitleLabel.textColor = UIColor(named: "CharcoalBlue")
        
        sortMenuView.backgroundColor = .white
        sortMenuView.layer.cornerRadius = 10
        
        sortMenuView.layer.shadowColor = UIColor.black.cgColor
        sortMenuView.layer.shadowOpacity = 0.3
        sortMenuView.layer.shadowOffset = CGSize(width: 1, height: 1)
        sortMenuView.layer.shadowRadius = 2
        
        latestFirstButton.backgroundColor = .white
        latestFirstButton.addTarget(self, action: #selector(tappedLatestFirst), for: .touchUpInside)
        latestFirstButton.layer.cornerRadius = 10
        
        oldestFirstButton.backgroundColor = .white
        oldestFirstButton.addTarget(self, action: #selector(tappedOldestFirst), for: .touchUpInside)
        oldestFirstButton.layer.cornerRadius = 10
        
        latestTextLabel.text = "최신순"
        latestTextLabel.font = Pretendard.regular.dynamicFont(style: .footnote)
        latestTextLabel.textColor = UIColor(named: "CharcoalBlue")
        
        oldestTextLabel.text = "오래된순"
        oldestTextLabel.font = Pretendard.regular.dynamicFont(style: .footnote)
        oldestTextLabel.textColor = UIColor(named: "CharcoalBlue")
        
        latestFirstcheckImageView.image = UIImage(named: "check")
        oldestFirstcheckImageView.image = UIImage(named: "check")
        
        emptyMessageLabel.text = "기록한 구절이 없어요\n구절을 등록해 보세요"
        emptyMessageLabel.font = Pretendard.regular.dynamicFont(style: .subheadline)
        emptyMessageLabel.textColor = .black
        emptyMessageLabel.isHidden = true
        emptyMessageLabel.numberOfLines = 0
        let attrString = NSMutableAttributedString(string: emptyMessageLabel.text!)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 4
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
        emptyMessageLabel.attributedText = attrString
    }
    
    private func setConstraints() {
        [paragraphLabel, selectionButton, doneButton, searchBar, sortButton, sortMenuView, paragraphCollectionView, emptyMessageLabel].forEach {
            view.addSubview($0)
        }
        
        paragraphLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.leading.equalToSuperview().inset(20)
            $0.height.equalTo(41)
        }
        
        //선택 버튼
        selectionButton.snp.makeConstraints {
            $0.centerY.equalTo(paragraphLabel.snp.centerY)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(22)
            $0.width.equalTo(53)
        }
        
        [selectionButtonImageView, selectionButtonLabel].forEach {
            selectionButton.addSubview($0)
        }
        
        selectionButtonImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(4)
            $0.width.equalTo(14.67)
            $0.height.equalTo(13.2)
        }
        
        selectionButtonLabel.snp.makeConstraints {
            $0.centerY.trailing.equalToSuperview()
            $0.leading.equalTo(selectionButtonImageView.snp.trailing).offset(5)
        }
        
        doneButton.snp.makeConstraints {
            $0.centerY.equalTo(paragraphLabel.snp.centerY)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(24)
            $0.width.equalTo(30)
        }
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(paragraphLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
        
        //정렬 버튼
        sortButton.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(10)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(29)
            $0.width.greaterThanOrEqualTo(87)
        }
        
        [sortButtonImageView, sortButtonTitleLabel].forEach {
            sortButton.addSubview($0)
        }
        
        sortButtonImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(15)
            $0.width.height.equalTo(18)
        }
        
        sortButtonTitleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(sortButtonImageView.snp.trailing).offset(5)
            $0.trailing.equalToSuperview().inset(15)
        }
        
        // 정렬 버튼 클릭 시 - 정렬 옵션 메뉴
        sortMenuView.snp.makeConstraints {
            $0.top.equalTo(sortButton.snp.bottom).offset(3)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(60)
            $0.width.equalTo(113)
        }
        
        // 정렬 옵션 메뉴(최신순 버튼, 오래된순 버튼)
        [latestFirstButton, oldestFirstButton].forEach {
            sortMenuView.addSubview($0)
        }
        
        latestFirstButton.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(oldestFirstButton.snp.top)
            $0.height.equalTo(30)
        }
        
        oldestFirstButton.snp.makeConstraints {
            $0.top.equalTo(latestFirstButton.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        // 최신순 버튼
        [latestFirstcheckImageView, latestTextLabel].forEach {
            latestFirstButton.addSubview($0)
        }
        
        latestFirstcheckImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12)
            $0.height.width.equalTo(10)
        }
        
        latestTextLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(latestFirstcheckImageView.snp.trailing).offset(6)
        }
        
        //오래된순
        [oldestFirstcheckImageView, oldestTextLabel].forEach {
            oldestFirstButton.addSubview($0)
        }
        
        oldestFirstcheckImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12)
            $0.height.width.equalTo(10)
        }
        
        oldestTextLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(latestFirstcheckImageView.snp.trailing).offset(6)
        }
        
        paragraphCollectionView.snp.makeConstraints {
            $0.top.equalTo(sortButton.snp.bottom).offset(14)
            $0.bottom.leading.trailing.equalToSuperview().inset(0)
        }
        
        emptyMessageLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    //MARK: - searchBar
    private func setSearchBar() {
        searchBar.searchBarStyle = .minimal
        searchBar.setPositionAdjustment(UIOffset(horizontal: 8, vertical: 0), for: .search)
        searchBar.setPositionAdjustment(UIOffset(horizontal: -8, vertical: 0), for: .clear)
        searchBar.placeholder = "기록한 구절을 검색해보세요"
        searchBar.searchTextField.borderStyle = .line
        searchBar.searchTextField.layer.borderWidth = 1
        searchBar.searchTextField.layer.borderColor = UIColor(named: "SearchBarLightGray")?.cgColor
        searchBar.searchTextField.layer.backgroundColor = UIColor.white.cgColor
        searchBar.searchTextField.layer.cornerRadius = 17
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.searchTextField.font = Pretendard.regular.dynamicFont(style: .caption2)
    }
    // MARK: - 설정버튼
    private func setSortMenuView() {
        sortMenuView.isHidden = true
        
        latestFirstcheckImageView.isHidden = false
        oldestFirstcheckImageView.isHidden = true
    }
    
    @objc private func showSortMenuView() {
        sortMenuView.isHidden = false
        view.bringSubviewToFront(sortMenuView)
    }
    
    @objc private func tappedLatestFirst() {
        sortButtonTitleLabel.text = "최신순"
        
        latestFirstcheckImageView.isHidden = false
        oldestFirstcheckImageView.isHidden = true
        
        sortMenuView.isHidden = true
        
        paragraphData.sort { $0.1 > $1.1 }
        paragraphCollectionView.reloadData()
    }
    
    @objc private func tappedOldestFirst() {
        sortButtonTitleLabel.text = "오래된순"
        
        latestFirstcheckImageView.isHidden = true
        oldestFirstcheckImageView.isHidden = false
        
        sortMenuView.isHidden = true
        
        paragraphData.sort { $0.1 < $1.1 }
        paragraphCollectionView.reloadData()
    }
    
    @objc private func tappedSelectionButton() {
        isEditingMode = true
        selectionButton.isHidden = true
        doneButton.isHidden = false
        paragraphCollectionView.reloadData()
    }
    
    @objc private func tappedDoneButton() {
        isEditingMode = false
        selectionButton.isHidden = false
        doneButton.isHidden = true
        paragraphCollectionView.reloadData()
    }
}
//MARK: -CollectionView
extension ParagraphViewController: UICollectionViewDelegate, UICollectionViewDataSource, ParagraphCollectionViewLayoutDelegate, ParagraphCollectionViewCellDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let cellCount = paragraphData.count
        
        emptyMessageLabel.isHidden = cellCount > 0
        return cellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ParagraphCollectionViewCell.identifier, for: indexPath) as? ParagraphCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let (text, date) = paragraphData[indexPath.item]
        cell.paragraphLabel.text = text
        cell.dateLabel.text = date
        cell.setColor(with: indexPath)
        cell.deleteButton.isHidden = !isEditingMode
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForTextAtIndexPath indexPath: IndexPath) -> CGFloat {
        let width = (collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right)) / 2 - 4
        let text = paragraphData[indexPath.item].0
        let paragraphLabelHeight = heightForText(text, width: width)
        let paragraphDateSpacing: CGFloat = 30
        let dataLabelHeight: CGFloat = 22
        let topBottomPadding: CGFloat = 12 * 2
        
        return paragraphLabelHeight + paragraphDateSpacing + dataLabelHeight + topBottomPadding
    }
    
    private func heightForText(_ text: String, width: CGFloat) -> CGFloat {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0  // 멀티라인
        label.preferredMaxLayoutWidth = width
        
        let constraintSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let size = label.sizeThatFits(constraintSize)
        
        return size.height
    }
    
    func tappedDeleteButton(in cell: ParagraphCollectionViewCell) {
        guard let indexPath = paragraphCollectionView.indexPath(for: cell) else { return }
        paragraphData.remove(at: indexPath.item)
        
        paragraphCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           let selectedData = paragraphData[indexPath.item]
           
           let modalVC = ParagrapViewController()
           
           present(modalVC, animated: true, completion: nil)
       }
}
