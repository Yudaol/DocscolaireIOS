import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    var webView: WKWebView!
    var homeButton: UIButton!
    var blackView: UIView!
    
    let userDefaults = UserDefaults.standard
    var buttonPosition: CGPoint {
        get {
            if let position = userDefaults.object(forKey: "buttonPosition") as? Data {
                return NSKeyedUnarchiver.unarchiveObject(with: position) as! CGPoint
            }
            return CGPoint(x: view.bounds.width - 70, y: 40)
        }
        set {
            let positionData = NSKeyedArchiver.archivedData(withRootObject: newValue)
            userDefaults.set(positionData, forKey: "buttonPosition")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WKWebView()
        webView.navigationDelegate = self
        webView.uiDelegate = self // Set the UI delegate
        view.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        blackView = UIView()
        blackView.backgroundColor = .black
        blackView.layer.cornerRadius = 15
        view.addSubview(blackView)

        blackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blackView.topAnchor.constraint(equalTo: view.topAnchor, constant: buttonPosition.y),
            blackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: buttonPosition.x),
            blackView.heightAnchor.constraint(equalToConstant: 50),
            blackView.widthAnchor.constraint(equalToConstant: 50)
        ])

        homeButton = UIButton(type: .system)
        let homeImage = UIImage(systemName: "house")
        homeButton.setImage(homeImage, for: .normal)
        homeButton.tintColor = .white
        homeButton.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)
        blackView.addSubview(homeButton)

        homeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            homeButton.centerXAnchor.constraint(equalTo: blackView.centerXAnchor),
            homeButton.centerYAnchor.constraint(equalTo: blackView.centerYAnchor)
        ])

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanButton(_:)))
        blackView.addGestureRecognizer(panGesture)

        if let url = URL(string: "https://tobiasbaertschi.wixsite.com/docscolaire") {
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
        }

        webView.allowsLinkPreview = true
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }

    // Handle new window requests
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let popupVC = PopupViewController()
        popupVC.modalPresentationStyle = .formSheet
        popupVC.url = navigationAction.request.url

        let navController = UINavigationController(rootViewController: popupVC)
        present(navController, animated: true, completion: nil)
        
        return nil
    }

    @objc func homeButtonTapped() {
        if let url = URL(string: "https://tobiasbaertschi.wixsite.com/docscolaire") {
            webView.load(URLRequest(url: url))
        }
    }

    @objc func didPanButton(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        guard let blackView = sender.view else { return }
        blackView.center = CGPoint(x: blackView.center.x + translation.x, y: blackView.center.y + translation.y)
        sender.setTranslation(.zero, in: view)
        
        if sender.state == .ended {
            buttonPosition = blackView.frame.origin
        }
    }
}
