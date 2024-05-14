import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {

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
        view.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        blackView = UIView()
        blackView.backgroundColor = .black
        blackView.layer.cornerRadius = 15
        view.addSubview(blackView)

        blackView.translatesAutoresizingMaskIntoConstraints = false
        blackView.topAnchor.constraint(equalTo: view.topAnchor, constant: buttonPosition.y).isActive = true
        blackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: buttonPosition.x).isActive = true
        blackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        blackView.widthAnchor.constraint(equalToConstant: 50).isActive = true

        homeButton = UIButton(type: .system)
        let homeImage = UIImage(systemName: "house")
        homeButton.setImage(homeImage, for: .normal)
        homeButton.tintColor = .white
        homeButton.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)
        blackView.addSubview(homeButton)

        homeButton.translatesAutoresizingMaskIntoConstraints = false
        homeButton.centerXAnchor.constraint(equalTo: blackView.centerXAnchor).isActive = true
        homeButton.centerYAnchor.constraint(equalTo: blackView.centerYAnchor).isActive = true

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanButton(_:)))
        blackView.addGestureRecognizer(panGesture)

        if let url = URL(string: "https://tobiasbaertschi.wixsite.com/docscolaire") {
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
        }

        webView.allowsLinkPreview = true
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        decisionHandler(.allow)
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
