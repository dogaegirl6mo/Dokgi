//
//  ParagraphViewController.swift
//  Dokgi
//
//  Created by t2023-m0095 on 6/10/24.
//

import RxSwift
import SnapKit
import UIKit

class PassageViewController: UIViewController {
    
    let viewModel = PassageViewModel()
    var disposeBag = DisposeBag()
    
    private let paragraphLabel = UILabel()
    private let selectionButton = UIButton()
    private let selectionButtonImageView = UIImageView()
    private let selectionButtonLabel = UILabel()
    private let doneButton = UIButton()

    private let searchBar = UISearchBar()
    private var isFiltering: Bool = false
    
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
        let layout = PassageCollectionViewLayout()
        layout.delegate = self
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 2, left: 14, bottom: 15, right: 14)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PassageCollectionViewCell.self, forCellWithReuseIdentifier: PassageCollectionViewCell.identifier)
        
        return collectionView
    }()

    private var searchResultItems: [(String, Date)] = [] {
        didSet {
            if let layout = paragraphCollectionView.collectionViewLayout as? PassageCollectionViewLayout {
                layout.invalidateCache()
            }
            
            paragraphCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.paragraphData.subscribe(with: self) { (self, data) in
            if let layout = self.paragraphCollectionView.collectionViewLayout as? PassageCollectionViewLayout {
                layout.invalidateCache()
            }
            self.paragraphCollectionView.reloadData()
        }.disposed(by: disposeBag)
        
        setUI()
        setConstraints()
        setSearchBar()
        setSortMenuView()
        setFloatingButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = true
        if sortButton.titleLabel?.text != "최신순" {
            let sortedPassageAndDate = viewModel.paragraphData.value.sorted { $0.1 > $1.1 }
            
            isFiltering ? searchResultItems.sort { $0.1 > $1.1 } : viewModel.paragraphData.accept(sortedPassageAndDate)
        }
        self.paragraphCollectionView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        sortMenuView.isHidden = true
    }
    
    private func setUI() {
        view.backgroundColor = .white
        
        paragraphLabel.text = "구절"
        paragraphLabel.font = Pretendard.bold.dynamicFont(style: .title1)
        
        selectionButton.backgroundColor = .white
        selectionButton.addTarget(self, action: #selector(tappedSelectionButton), for: .touchUpInside)
        
        selectionButtonImageView.image = .filter
        
        selectionButtonLabel.text = "선택"
        selectionButtonLabel.font = Pretendard.semibold.dynamicFont(style: .headline)
        selectionButtonLabel.textColor = .charcoalBlue
        selectionButton.sizeToFit()
        
        doneButton.isHidden = true
        doneButton.addTarget(self, action: #selector(tappedDoneButton), for: .touchUpInside)
        doneButton.titleLabel?.font = Pretendard.semibold.dynamicFont(style: .headline)
        doneButton.setTitle("완료", for: .normal)
        doneButton.setTitleColor(.brightRed, for: .normal)
        
        sortButton.backgroundColor = .lightSkyBlue
        sortButton.layer.cornerRadius = 15
        sortButton.clipsToBounds = true
        sortButton.addTarget(self, action: #selector(showOrHideSortMenuView), for: .touchUpInside)
        
        sortButtonImageView.image = .down
        sortButtonTitleLabel.text = "최신순"
        sortButtonTitleLabel.font = Pretendard.regular.dynamicFont(style: .footnote)
        sortButtonTitleLabel.textColor = .charcoalBlue
        
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
        latestTextLabel.textColor = .charcoalBlue
        
        oldestTextLabel.text = "오래된순"
        oldestTextLabel.font = Pretendard.regular.dynamicFont(style: .footnote)
        oldestTextLabel.textColor = .charcoalBlue
        
        latestFirstcheckImageView.image = .check
        oldestFirstcheckImageView.image = .check
        
        emptyMessageLabel.text = "기록한 구절이 없어요\n구절을 등록해 보세요"
        emptyMessageLabel.font = Pretendard.regular.dynamicFont(style: .subheadline)
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
        }
        
        // 정렬 옵션 메뉴(최신순 버튼, 오래된순 버튼)
        [latestFirstButton, oldestFirstButton].forEach {
            sortMenuView.addSubview($0)
        }
        
        latestFirstButton.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(oldestFirstButton.snp.top)
        }
        
        oldestFirstButton.snp.makeConstraints {
            $0.top.equalTo(latestFirstButton.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
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
            $0.trailing.equalToSuperview().inset(25)
        }
        
        paragraphCollectionView.snp.makeConstraints {
            $0.top.equalTo(sortButton.snp.bottom).offset(14)
            $0.bottom.leading.trailing.equalToSuperview()
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
        searchBar.searchTextField.layer.borderColor = UIColor(resource: .searchBarLightGray).cgColor
        searchBar.searchTextField.layer.backgroundColor = UIColor.white.cgColor
        searchBar.searchTextField.layer.cornerRadius = 17
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.searchTextField.font = Pretendard.regular.dynamicFont(style: .footnote)
        
        searchBar.delegate = self
    }
    // MARK: - 설정버튼
    private func setSortMenuView() {
        sortMenuView.isHidden = true
        
        latestFirstcheckImageView.isHidden = false
        oldestFirstcheckImageView.isHidden = true
    }
    
    @objc private func showOrHideSortMenuView() {
        if sortMenuView.isHidden {
            sortMenuView.isHidden = false
            view.bringSubviewToFront(sortMenuView)
        } else {
            sortMenuView.isHidden = true
        }
    }
    
    @objc private func tappedLatestFirst() {
        sortButtonTitleLabel.text = "최신순"
        latestFirstcheckImageView.isHidden = false
        oldestFirstcheckImageView.isHidden = true
        sortMenuView.isHidden = true
        
        let sortedPassageAndDate = viewModel.paragraphData.value.sorted { $0.1 > $1.1 }
        
        isFiltering ? searchResultItems.sort { $0.1 > $1.1 } : viewModel.paragraphData.accept(sortedPassageAndDate)
    }
    
    @objc private func tappedOldestFirst() {
        sortButtonTitleLabel.text = "오래된순"
        latestFirstcheckImageView.isHidden = true
        oldestFirstcheckImageView.isHidden = false
        sortMenuView.isHidden = true
        
        let sortedPassageAndDate = viewModel.paragraphData.value.sorted { $0.1 < $1.1 }
        
        isFiltering ? searchResultItems.sort { $0.1 < $1.1 } : viewModel.paragraphData.accept(sortedPassageAndDate)
    }
    
    @objc private func tappedSelectionButton() {
        isEditingMode = true
        selectionButton.isHidden = true
        doneButton.isHidden = false
        
        self.paragraphCollectionView.reloadData()
    }
    
    @objc private func tappedDoneButton() {
        isEditingMode = false
        selectionButton.isHidden = false
        doneButton.isHidden = true
        
        self.paragraphCollectionView.reloadData()
    }
}
//MARK: -CollectionView
extension PassageViewController: UICollectionViewDelegate, UICollectionViewDataSource, PassageCollectionViewLayoutDelegate, PassageCollectionViewCellDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let cellCount = viewModel.paragraphData.value.count
        let resultCount = searchResultItems.count
        let itemCount = isFiltering ? resultCount : cellCount
        
        emptyMessageLabel.isHidden = itemCount > 0
        if isFiltering { emptyMessageLabel.text = "검색결과가 없습니다." }
        
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PassageCollectionViewCell.identifier, for: indexPath) as? PassageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.setColor(with: indexPath)
        cell.deleteButton.isHidden = !isEditingMode
        cell.delegate = self
        
        let (text, date) = isFiltering ? searchResultItems[indexPath.item] : viewModel.paragraphData.value[indexPath.item]
        cell.paragraphLabel.text = text
        let dateString = String(date.toString()).suffix(10)
        cell.dateLabel.text = String(dateString)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForTextAtIndexPath indexPath: IndexPath) -> CGFloat {
        let text = isFiltering ? searchResultItems[indexPath.item].0 : viewModel.paragraphData.value[indexPath.item].0
        let date = isFiltering ? searchResultItems[indexPath.item].1 : viewModel.paragraphData.value[indexPath.item].1
        return calculateCellHeight(for: text, for: date.toString(), in: collectionView)
    }
    
    func heightForText(_ text: String, width: CGFloat) -> CGFloat {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0  // 멀티라인
        label.preferredMaxLayoutWidth = width
        label.lineBreakMode = .byCharWrapping
        label.font = Pretendard.regular.dynamicFont(style: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        
        let constraintSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let size = label.sizeThatFits(constraintSize)
        
        return size.height
    }
    
    func heightForDateText(_ date: String, width: CGFloat) -> CGFloat {
        let label = UILabel()
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = width
        label.font = Pretendard.regular.dynamicFont(style: .caption2)
        label.adjustsFontForContentSizeCategory = true
        label.text = date
        
        let constraintSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let size = label.sizeThatFits(constraintSize)
        
        return size.height
    }
    
    func calculateCellHeight(for text: String, for date: String, in collectionView: UICollectionView) -> CGFloat {
        let cellPadding: CGFloat = 6
        let leftRightinsets: CGFloat = 15 * 2
        let width = (collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right + cellPadding * 4)) / 2 - leftRightinsets + 0.5
        
        let paragraphLabelHeight = heightForText(text, width: width)
        let paragraphDateSpacing: CGFloat = 30
        let dateLabelHeight: CGFloat = heightForDateText(date, width: width)
        let topBottomPadding: CGFloat = 14 * 2
        return paragraphLabelHeight + paragraphDateSpacing + dateLabelHeight + topBottomPadding
    }
    
    func tappedDeleteButton(in cell: PassageCollectionViewCell) {
        guard let indexPath = paragraphCollectionView.indexPath(for: cell) else { return }
        self.viewModel.selectParagraph(text: isFiltering ? searchResultItems[indexPath.item].0 : viewModel.paragraphData.value[indexPath.item].0, at: indexPath.item)
        var currentParagraph = isFiltering ? searchResultItems : viewModel.paragraphData.value
        currentParagraph.remove(at: indexPath.item)
        viewModel.paragraphData.accept(currentParagraph)
        searchResultItems = currentParagraph
        CoreDataManager.shared.deleteData(verse: viewModel.detailParagraph.value)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let modalVC = PassageDetailViewController()
        
        viewModel.selectParagraph(text: isFiltering ? searchResultItems[indexPath.item].0 : viewModel.paragraphData.value[indexPath.item].0, at: indexPath.item)
        modalVC.viewModel.detailParagraph.accept(viewModel.detailParagraph.value)
        present(modalVC, animated: true, completion: nil)
    }
}

//MARK: - SearchBar
extension PassageViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.isFiltering = true
        self.searchBar.showsCancelButton = true
        searchResultItems = viewModel.paragraphData.value
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterItems(with: searchText)
    }
    
    private func filterItems(with searchText: String) {
        if searchText.isEmpty {
            searchResultItems = viewModel.paragraphData.value
        } else {
            searchResultItems = viewModel.paragraphData.value.filter { $0.0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.resignFirstResponder()
        self.isFiltering = false
        self.searchBar.text = ""
        self.searchResultItems = []
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        filterItems(with: searchText)
        
        self.searchBar.showsCancelButton = false
        self.searchBar.resignFirstResponder()
    }
}