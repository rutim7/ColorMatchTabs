import class UIKit.UIImage

extension UIImage {
    
    convenience init?(namedInCurrentBundle: String) {
        self.init(named: namedInCurrentBundle, in: Bundle(for: ColorMatchTabsViewController.self), compatibleWith: nil)
    }
    
}
