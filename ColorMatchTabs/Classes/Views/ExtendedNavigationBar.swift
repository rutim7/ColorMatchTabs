import UIKit

final class ExtendedNavigationBar: UIView {
    
    override func willMove(toWindow newWindow: UIWindow?) {
        layer.shadowOffset = CGSize(width: 0, height: 1 / UIScreen.main.scale)
        layer.shadowRadius = 0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
    }
    
}
