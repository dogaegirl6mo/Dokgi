//
//  AddVerseVC.swift
//  Dokgi
//
//  Created by 한철희 on 6/4/24.
//

import SnapKit
import UIKit
import Vision
import VisionKit

protocol BookSelectionDelegate: AnyObject {
    func didSelectBook(_ book: Item)
}

class AddVerseVC: UIViewController {
    
    var selectedBook: Item?
    
    var images: [UIImage] = []
    weak var delegate: BookSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        print("생명주기")
        setupViews()
        initLayout()
        setupActions()
        setupHideKeyboardOnTap()
    }
    
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    let viewInScroll: UIView = {
        let uv = UIView()
        return uv
    }()
    
    let scanButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("구절 스캔", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        btn.setTitleColor(UIColor(named: "CharcoalBlue"), for: .normal)
        btn.backgroundColor = .lightSkyBlue
        btn.setImage(UIImage(named: "camera.viewfinder")?.withTintColor(UIColor(named: "CharcoalBlue") ?? .black, renderingMode: .alwaysOriginal), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        btn.layer.cornerRadius = 18
        return btn
    }()

    let infoView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        return view
    }()
    
    let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightSkyBlue
        view.layer.cornerRadius = 15
        return view
    }()
    
    let searchButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "책 검색"
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor(named: "CharcoalBlue")
        config.image = UIImage(systemName: "magnifyingglass")
        config.imagePadding = 8
        config.imagePlacement = .leading
        button.configuration = config
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        return button
    }()
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "camera")
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .gray
        return imageView
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "책 제목"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    var authorLabel: UILabel = {
        let label = UILabel()
        label.text = "저자"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(named: "BookTextGray")
        return label
    }()
    
    lazy var verseTextView: UITextView = {
        let view = UITextView()
        view.text = "텍스트를 입력하세요"
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.7).cgColor
        view.textContainerInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        view.font = .systemFont(ofSize: 14)
        view.textColor = .placeholderText
        view.layer.cornerRadius = 8
        view.showsVerticalScrollIndicator = false
        view.delegate = self
        return view
    }()
    
    let keywordLabel: UILabel = {
        let label = UILabel()
        label.attributedText = AddVerseVC.createAttributedString(for: "키워드 (선택)")
        label.textAlignment = .left
        return label
    }()
    
    let keywordField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "키워드를 입력해 주세요"
        textField.borderStyle = .roundedRect
        textField.layer.masksToBounds = true
        return textField
    }()
    
    // 컬렉션 뷰 추가
    lazy var keywordCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    let pageLabel: UILabel = {
        let label = UILabel()
        label.text = "페이지"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    let pageNumberTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "페이지 수"
        textField.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    let percentageButton: UIButton = {
        let button = UIButton()
        button.setTitle("%", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        button.setTitleColor(UIColor(named: "CharcoalBlue"), for: .normal)
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1.0 // 테두리 두께 설정
        if let charcoalBlueColor = UIColor(named: "CharcoalBlue") {
            button.layer.borderColor = charcoalBlueColor.cgColor
        }
        return button
    }()
    
    let pageButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Page", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        btn.setTitleColor(.black, for: .normal)
        btn.layer.cornerRadius = 15
        btn.layer.borderWidth = 1.0
        if let charcoalBlueColor = UIColor(named: "CharcoalBlue") {
            btn.layer.borderColor = charcoalBlueColor.cgColor
        }
        return btn
    }()
    
    let recordButton: UIButton = {
        let button = UIButton()
        button.setTitle("기록 하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "CharcoalBlue") // 버튼 배경색 설정
        button.layer.cornerRadius = 8
        return button
    }()
    
    func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(viewInScroll)
        viewInScroll.addSubview(scanButton)
        viewInScroll.addSubview(infoView)
        infoView.addSubview(overlayView)
        overlayView.addSubview(searchButton)
        infoView.addSubview(imageView)
        infoView.addSubview(titleLabel)
        infoView.addSubview(authorLabel)
        viewInScroll.addSubview(verseTextView)
        viewInScroll.addSubview(keywordLabel)
        viewInScroll.addSubview(keywordField)
        viewInScroll.addSubview(keywordCollectionView)
        viewInScroll.addSubview(pageLabel)
        viewInScroll.addSubview(pageNumberTextField)
        viewInScroll.addSubview(percentageButton)
        viewInScroll.addSubview(pageButton)
        viewInScroll.addSubview(recordButton)
    }
    
    // MARK: - 제약조건
    func initLayout() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
        }
        
        viewInScroll.snp.makeConstraints {
            $0.edges.equalTo(scrollView.snp.edges)
            $0.width.equalTo(scrollView.snp.width)
            $0.height.equalTo(1000) // 임시로 1000으로 설정
        }
        
        scanButton.snp.makeConstraints {
            $0.top.equalTo(viewInScroll.snp.top).offset(10)
            $0.trailing.equalTo(viewInScroll.snp.trailing).offset(-16)
            $0.width.equalTo(112)
            $0.height.equalTo(35)
        }
        
        infoView.snp.makeConstraints {            $0.centerY.equalTo(viewInScroll.snp.top).offset(170)
            $0.horizontalEdges.equalTo(viewInScroll).inset(16)
            $0.height.equalTo(200)
        }
        
        overlayView.snp.makeConstraints {
            $0.edges.equalTo(infoView)
        }
        
        searchButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(35)
            $0.horizontalEdges.equalTo(viewInScroll).inset(140)
        }
        
        imageView.snp.makeConstraints {
            $0.leading.equalTo(infoView.snp.leading).offset(16)
            $0.centerY.equalTo(infoView.snp.centerY)
            $0.width.equalTo(100)
            $0.height.equalTo(140)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(16)
            $0.centerY.equalTo(infoView.snp.centerY).offset(-16)
            $0.trailing.equalTo(infoView.snp.trailing).offset(-16)
        }
        
        authorLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(16)
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.trailing.equalTo(infoView.snp.trailing).offset(-16)
        }
        
        verseTextView.snp.makeConstraints {
            $0.top.equalTo(infoView.snp.bottom).offset(32)
            $0.leading.equalTo(viewInScroll.snp.leading).offset(16)
            $0.trailing.equalTo(viewInScroll.snp.trailing).offset(-16)
            $0.height.equalTo(329)
        }
        
        keywordLabel.snp.makeConstraints {
            $0.top.equalTo(verseTextView.snp.bottom).offset(32)
            $0.leading.equalTo(viewInScroll.snp.leading).offset(16)
            $0.trailing.equalTo(viewInScroll.snp.trailing).offset(-16)
        }
        
        keywordField.snp.makeConstraints {
            $0.top.equalTo(keywordLabel.snp.bottom).offset(16)
            $0.leading.equalTo(viewInScroll.snp.leading).offset(16)
            $0.trailing.equalTo(viewInScroll.snp.trailing).offset(-16)
            $0.height.equalTo(33)
        }
        
        keywordCollectionView.snp.makeConstraints {
            $0.top.equalTo(keywordField.snp.bottom).offset(16)
            $0.leading.equalTo(viewInScroll.snp.leading).offset(16)
            $0.trailing.equalTo(viewInScroll.snp.trailing).offset(-16)
            $0.height.equalTo(35)
        }
        
        pageLabel.snp.makeConstraints {
            $0.top.equalTo(keywordCollectionView.snp.bottom).offset(50)
            $0.leading.equalTo(viewInScroll.snp.leading).offset(16)
        }
        
        pageNumberTextField.snp.makeConstraints {
            $0.centerY.equalTo(pageLabel.snp.centerY)
            $0.leading.equalTo(pageLabel.snp.trailing).offset(8)
            $0.width.equalTo(55)
            $0.height.equalTo(30)
        }
        
        percentageButton.snp.makeConstraints {
            $0.centerY.equalTo(pageLabel.snp.centerY)
            $0.trailing.equalTo(pageButton.snp.leading).offset(-8)
            $0.width.equalTo(60)
            $0.height.equalTo(pageLabel.snp.height)
        }
        
        pageButton.snp.makeConstraints {
            $0.centerY.equalTo(percentageButton.snp.centerY)
            $0.trailing.equalTo(viewInScroll.snp.trailing).offset(-16)
            $0.width.equalTo(60)
            $0.height.equalTo(percentageButton.snp.height)
        }
        
        recordButton.snp.makeConstraints {
            $0.top.equalTo(pageLabel.snp.bottom).offset(60)
            $0.leading.equalTo(viewInScroll.snp.leading).offset(16)
            $0.trailing.equalTo(viewInScroll.snp.trailing).offset(-16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        scrollView.contentSize = viewInScroll.bounds.size
    }
    
    func setupActions() {
        scanButton.addTarget(self, action: #selector(scanButtonTapped(_:)), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchButtonTapped(_:)), for: .touchUpInside)
        percentageButton.addTarget(self, action: #selector(percentageButtonTapped(_:)), for: .touchUpInside)
        pageButton.addTarget(self, action: #selector(pageButtonTapped(_:)), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(recordButtonTapped(_:)), for: .touchUpInside)
    }
    
    func setupHideKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    func visionKit() {
        let scan = VNDocumentCameraViewController()
        scan.delegate = self
        self.present(scan, animated: true)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func scanButtonTapped(_ sender: UIButton) {
        images = []
        visionKit()
        print("구절 스캔 버튼이 눌렸습니다.")
    }
    
    @objc func searchButtonTapped(_ sender: UIButton) {
        print("검색버튼이 눌렸습니다.")
        let bookSearchVC = BookSearchVC()
        bookSearchVC.delegate = self
        present(bookSearchVC, animated: true, completion: nil)
    }
    
    @objc func percentageButtonTapped(_ sender: UIButton) {
        print("% 버튼이 눌렸습니다.")
    }
    
    @objc func pageButtonTapped(_ sender: UIButton) {
        // 구절 스캔 버튼이 눌렸을 때 실행될 액션 구현
        print("page 버튼이 눌렸습니다.")
    }
    
    @objc func recordButtonTapped(_ sender: UIButton) {
        // 구절 스캔 버튼이 눌렸을 때 실행될 액션 구현
        print("기록하기 버튼이 눌렸습니다.")
    }
    
    // 텍스트 속성을 설정하는 함수
    private static func createAttributedString(for text: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        
        // "키워드" 부분에 대한 속성 설정
        let keywordRange = (text as NSString).range(of: "키워드")
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .semibold), range: keywordRange)
        
        // "선택" 부분에 대한 속성 설정
        let selectionRange = (text as NSString).range(of: "(선택)")
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .regular), range: selectionRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.gray, range: selectionRange)
        
        return attributedString
    }
    
    private func displayBookInfo() {
        if let book = selectedBook {
            titleLabel.text = book.title
            authorLabel.text = book.author
            if let url = URL(string: book.image) {
                imageView.kf.setImage(with: url)
            }
        }
    }
    
    func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else {
            fatalError("UIImage에서 CGImage를 얻을 수 없습니다.")
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { [weak self] (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                print("텍스트 인식 오류: \(error?.localizedDescription ?? "알 수 없는 오류")")
                return
            }
            
            let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
            DispatchQueue.main.async {
                self?.verseTextView.text = recognizedStrings.joined(separator: "\n")
            }
        }
        let revision3 = VNRecognizeTextRequestRevision3
        request.revision = revision3
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["ko-KR"]
        request.usesLanguageCorrection = true
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("텍스트 인식 수행 실패: \(error.localizedDescription)")
        }
    }
}

// MARK: - CollectionView 관련
extension AddVerseVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor(named: "LightSkyBlue")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 40)
    }
}

// MARK: - 텍스트뷰 placeholder 관련
extension AddVerseVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView.textColor == .placeholderText else { return }
        textView.textColor = .label
        textView.text = nil
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "텍스트를 입력하세요"
            textView.textColor = .placeholderText
        }
    }
}

extension AddVerseVC: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        let image = scan.imageOfPage(at: 0)
        recognizeText(from: image)
        controller.dismiss(animated: true)
    }

    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }

    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print("문서 스캔 실패: \(error.localizedDescription)")
        controller.dismiss(animated: true)
    }
}

extension AddVerseVC: BookSelectionDelegate {
    func didSelectBook(_ book: Item) {
        self.selectedBook = book
        displayBookInfo()
    }
}
