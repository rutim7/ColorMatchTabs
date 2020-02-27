import UIKit

/**
 *  Describes an item to display in top switcher.
 */
public struct TabSwitcherMenuItem {
    
    public let title: String
    public let titleFont: UIFont
    public let tintColor: UIColor
    public let normalImage: UIImage
    public let highlightedImage: UIImage
    
    public init(title: String, titleFont: UIFont, tintColor: UIColor, normalImage: UIImage, highlightedImage: UIImage) {
        self.title = title
        self.titleFont = titleFont
        self.tintColor = tintColor
        self.normalImage = normalImage
        self.highlightedImage = highlightedImage
    }
    
}
