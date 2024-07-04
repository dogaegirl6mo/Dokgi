//
//  AddVerseVC.swift
//  Dokgi
//
//  Created by 한철희 on 6/4/24.
//

import Kingfisher
import SnapKit
import Then
import UIKit
import VisionKit

protocol BookSelectionDelegate: AnyObject {
    func didSelectBook(_ book: Item)
}

class AddPassageViewController: UIViewController {
    
    let viewModel = AddPassageViewModel()
    private let containerView = AddPassageContainerView()
    var dataScannerViewController: DataScannerViewController?
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.contentInsetAdjustmentBehavior = .never
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setConstraints()
        setupActions()
        updateCharacterCountLabel()
        containerView.updateViewForSearchResult(isSearched: viewModel.showUi)
        containerView.updateViewForKeyword(isAdded: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func setupViews() {
        view.backgroundColor = .white
        containerView.pageSegment.selectedIndex = 0
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.keywordCollectionView.register(KeywordCollectionViewCell.self, forCellWithReuseIdentifier: KeywordCollectionViewCell.identifier)
        setupDelegates()
    }
    
    func setupDelegates() {
        containerView.keywordCollectionView.delegate = self
        containerView.keywordCollectionView.dataSource = self
        containerView.keywordField.delegate = self
        containerView.pageNumberTextField.delegate = self
        containerView.passageTextView.delegate = self
    }
    
    func setConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        containerView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }
    }
    
    func setupActions() {
        containerView.scanButton.addTarget(self, action: #selector(scanButtonTapped(_:)), for: .touchUpInside)
        containerView.searchButton.addTarget(self, action: #selector(searchButtonTapped(_:)), for: .touchUpInside)
        containerView.recordButton.addTarget(self, action: #selector(recordButtonTapped(_:)), for: .touchUpInside)
        containerView.keywordField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        containerView.pageSegment.buttons.enumerated().forEach { index, button in
            button.addTarget(self, action: #selector(pageSegmentButtonTapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc func scanButtonTapped(_ sender: UIButton) {
        startScanning()
    }
    
    func startScanning() {
        guard DataScannerViewController.isSupported else {
            print("DataScannerViewController is not supported on this device")
            return
        }
        
        let recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType> = [.text()]
    
        let dataScanner = DataScannerViewController(
            recognizedDataTypes: recognizedDataTypes,
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        
        dataScanner.delegate = self
        dataScannerViewController = dataScanner
        
        present(dataScanner, animated: true) {
            try? dataScanner.startScanning()
        }
    }
    
    @objc func searchButtonTapped(_ sender: UIButton) {
        let bookSearchVC = BookSearchViewController()
        bookSearchVC.delegate = self
        present(bookSearchVC, animated: true, completion: nil)
    }
    
    @objc func pageSegmentButtonTapped(_ sender: UIButton) {
        guard let index = containerView.pageSegment.buttons.firstIndex(of: sender) else { return }
        containerView.pageSegment.selectedIndex = index
        if index == 0{
            viewModel.pageType = true
            containerView.pageLabel.text = "페이지"
            containerView.pageNumberTextField.placeholder = "페이지"
        } else {
            viewModel.pageType = false
            containerView.pageLabel.text = "퍼센트"
            containerView.pageNumberTextField.placeholder = "퍼센트"
        }
    }
    
    @objc func recordButtonTapped(_ sender: UIButton) {
        let (isValid, message) = viewModel.validatePassage(passageText: containerView.passageTextView.text, pageNumberText: containerView.pageNumberTextField.text)
        if !isValid {
            showAlert(title: "경고", message: message)
            return
        }
        
        viewModel.removeEmptyKeywords()
        
        viewModel.savePassage(selectedBook: viewModel.selectedBook,
                              passageText: containerView.passageTextView.text ?? "",
                              pageNumberText: containerView.pageNumberTextField.text ?? "",
                              pageType: viewModel.pageType,
                              keywords: viewModel.keywords) { success in
            if success {
                self.navigationController?.popViewController(animated: true)
                let viewModel = DayTimeViewModel()
                if UserDefaults.standard.bool(forKey: UserDefaultsKeys.remindSwitch.rawValue) == true {
                    viewModel.sendLocalPushRemind(identifier: "remindTime", time: UserDefaults.standard.array(forKey: UserDefaultsKeys.remindTime.rawValue) as? [Int] ?? [3, 00, 1])
                }
                CoreDataManager.shared.readBook()
            } else {
                self.showAlert(title: "경고", message: "모든 필수 정보를 입력해주세요.")
            }
        }
    }
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func updateCharacterCountLabel() {
        viewModel.updateCharacterCountText(for: containerView.passageTextView.text, label: containerView.characterCountLabel)
    }
    
    func displayBookInfo() {
        if let book = viewModel.selectedBook {
            containerView.infoView.titleLabel.text = book.title
            containerView.infoView.titleLabel.font = Pretendard.semibold.dynamicFont(style: .headline)
            containerView.infoView.titleLabel.textColor = .black
            containerView.infoView.authorLabel.text = book.formattedAuthor
            if let url = URL(string: book.image) {
                containerView.infoView.imageView.kf.setImage(with: url)
                containerView.infoView.imageView.contentMode = .scaleAspectFill
            }
        }
    }
    
    private func updateTextView(with text: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.containerView.passageTextView.text = text
            self.containerView.passageTextView.textColor = .black
            self.containerView.passageTextView.font = Pretendard.regular.dynamicFont(style: .body)
            self.updateCharacterCountLabel()
            
            let range = NSMakeRange(self.containerView.passageTextView.text.count - 1, 0)
            self.containerView.passageTextView.scrollRangeToVisible(range)
        }
    }
    
    func removeKeyword(at indexPath: IndexPath) {
        let reversedIndex = viewModel.keywords.count - 1 - indexPath.item
        viewModel.keywords.remove(at: reversedIndex)
        containerView.keywordField.text = ""
        containerView.keywordField.resignFirstResponder()
        if viewModel.keywords.count == 0 {
            containerView.updateViewForKeyword(isAdded: true)
        }
        containerView.keywordCollectionView.reloadData()
    }
}

// MARK: - DataScannerViewControllerDelegate
extension AddPassageViewController: DataScannerViewControllerDelegate {
    func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
        switch item {
        case .text(let text):
            updateTextView(with: text.transcript)
            dataScanner.stopScanning()
            dataScanner.dismiss(animated: true, completion: nil)
        default:
            print("Unexpected item type")
        }
    }
}

// MARK: - UITextFieldDelegate
extension AddPassageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == containerView.pageNumberTextField {
            textField.resignFirstResponder()
            return true
        }
        
        if let keyword = textField.text, !keyword.isEmpty {
            if viewModel.keywords.count < 11 {
                viewModel.keywords[textField.tag] = keyword
                containerView.keywordCollectionView.reloadData()
            } else {
                showAlert(title: "알림", message: "키워드는 최대 10개까지 입력할 수 있습니다.")
            }
        }
        textField.text = ""
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard textField == containerView.keywordField else { return }
        
        if let text = textField.text, text.isEmpty {
            if !viewModel.keywords.contains("") {
                if viewModel.keywords.count < 10 {
                    viewModel.keywords.append("")
                    containerView.keywordCollectionView.reloadData()
                    textField.tag = viewModel.keywords.count - 1
                } else {
                    showAlert(title: "알림", message: "키워드는 최대 10개까지 입력할 수 있습니다.")
                }
            }
        }
        containerView.updateViewForKeyword(isAdded: false)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == containerView.keywordField else { return true }
        
        guard let currentText = textField.text as NSString? else { return true }
        let newText = currentText.replacingCharacters(in: range, with: string)
        return newText.count <= 20
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard textField == containerView.keywordField else { return }
        
        if let text = textField.text {
            if viewModel.keywords.count > textField.tag {
                viewModel.keywords[textField.tag] = text
            }
            containerView.keywordCollectionView.reloadData()
        }
    }
}

// MARK: - CollectionView
extension AddPassageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.keywords.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KeywordCollectionViewCell.identifier, for: indexPath) as? KeywordCollectionViewCell else {
            return UICollectionViewCell()
        }
        let reversedIndex = viewModel.keywords.count - 1 - indexPath.item
        let keyword = viewModel.keywords[reversedIndex]
        cell.xButton.isHidden = false
        cell.keywordLabel.text = keyword
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let reversedIndex = viewModel.keywords.count - 1 - indexPath.item
            let keyword = viewModel.keywords[reversedIndex]
            return calculateCellSize(for: keyword)
        }

        private func calculateCellSize(for keyword: String) -> CGSize {
            let font = Pretendard.regular.dynamicFont(style: .callout)
            let attributes = [NSAttributedString.Key.font: font]
            let textSize = (keyword as NSString).size(withAttributes: attributes)
            let cellWidth = textSize.width + 40
            let cellHeight: CGFloat = 34
            return CGSize(width: cellWidth, height: cellHeight)
        }
}

// MARK: - 텍스트뷰 placeholder
extension AddPassageViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard containerView.passageTextView.textColor == .textFieldGray else { return }
        containerView.passageTextView.textColor = .black
        containerView.passageTextView.font = Pretendard.regular.dynamicFont(style: .body)
        containerView.passageTextView.text = nil
        updateCharacterCountLabel()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "텍스트를 입력하세요"
            textView.textColor = .textFieldGray
        }
        updateCharacterCountLabel()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateCharacterCountLabel()
    }
}

// MARK: - 데이터 전달
extension AddPassageViewController: BookSelectionDelegate {
    func didSelectBook(_ book: Item) {
        viewModel.selectedBook = book
        displayBookInfo()
        viewModel.showUi = true
        containerView.updateViewForSearchResult(isSearched: viewModel.showUi)
    }
}
