//
//  AddVerseViewModel.swift
//  Dokgi
//
//  Created by 한철희 on 6/17/24.
//

import UIKit
import Vision
import VisionKit

class AddPassageViewModel {
    // MARK: - Properties
    var onRecognizedTextUpdate: ((String) -> Void)?
    weak var delegate: BookSelectionDelegate?
    var selectedBook: Item?
    var images: [UIImage] = []
    var keywords: [String] = []
    var pageType: String = "Page"
    var recognizedText: String = "" {
        didSet {
            onRecognizedTextUpdate?(recognizedText)
        }
    }
    
    // MARK: - func
    func visionKit(presenter: UIViewController) {
        let scan = VNDocumentCameraViewController()
        scan.delegate = presenter as? VNDocumentCameraViewControllerDelegate
        presenter.present(scan, animated: true)
    }
    
    func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else {
            fatalError("UIImage에서 CGImage를 얻을 수 없습니다.")
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = createTextRecognitionRequest()
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("텍스트 인식 수행 실패: \(error.localizedDescription)")
        }
    }
    
    private func createTextRecognitionRequest() -> VNRecognizeTextRequest {
        return VNRecognizeTextRequest { [weak self] (request, error) in
            self?.handleTextRecognition(request: request, error: error)
        }.apply {
            $0.revision = VNRecognizeTextRequestRevision3
            $0.recognitionLevel = VNRequestTextRecognitionLevel.accurate
            $0.recognitionLanguages = ["ko-KR"]
            $0.usesLanguageCorrection = true
        }
    }
    
    private func handleTextRecognition(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
            print("텍스트 인식 오류: \(error?.localizedDescription ?? "알 수 없는 오류")")
            return
        }
        
        let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
        let joinedString = recognizedStrings.joined(separator: "\n")
        let limitedString = String(joinedString.prefix(200))
        
        DispatchQueue.main.async {
            self.recognizedText = limitedString
        }
    }
    
    func saveVerse(selectedBook: Item?, verseText: String, pageNumberText: String?, pageType: String, keywords: [String], completion: @escaping (Bool) -> Void) {
        guard let book = selectedBook,
              let pageNumberText = pageNumberText,
              let pageNumber = Int(pageNumberText),
              !verseText.isEmpty,
              verseText != "텍스트를 입력하세요" else {
            completion(false)
            return
        }
        
        let currentDate = Date()
        
        // Verse 인스턴스 생성
        let verse = Verse(name: book.title, author: book.author, image: book.image, text: verseText, pageNumber: pageNumber, pageType: pageType, keywords: keywords, date: currentDate)
        
        CoreDataManager.shared.saveData(verse: verse)
        completion(true)
    }
    
    func updateCharacterCountText(for text: String?, label: UILabel) {
        let currentCount = text == "텍스트를 입력하세요" ? 0 : (text?.count ?? 0)
        label.text = "\(currentCount)/200"
    }
}

// MARK: - extension
private extension VNRecognizeTextRequest {
    func apply(configure: (VNRecognizeTextRequest) -> Void) -> VNRecognizeTextRequest {
        configure(self)
        return self
    }
}
