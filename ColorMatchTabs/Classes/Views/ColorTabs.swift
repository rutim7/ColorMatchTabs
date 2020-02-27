import UIKit

private let HighlighterViewOffScreenOffset: CGFloat = 0

private let SwitchAnimationDuration: TimeInterval = 0.3
private let HighlighterAnimationDuration: TimeInterval = SwitchAnimationDuration / 2

@objc public protocol ColorTabsDataSource: class {
    
    func numberOfItems(inTabSwitcher tabSwitcher: ColorTabs) -> Int
    func tabSwitcher(_ tabSwitcher: ColorTabs, titleAt index: Int) -> String
    func tabSwitcher(_ tabSwitcher: ColorTabs, titleFontAt index: Int) -> UIFont
    func tabSwitcher(_ tabSwitcher: ColorTabs, iconAt index: Int) -> UIImage
    func tabSwitcher(_ tabSwitcher: ColorTabs, hightlightedIconAt index: Int) -> UIImage
    func tabSwitcher(_ tabSwitcher: ColorTabs, tintColorAt index: Int) -> UIColor
    
}

open class ColorTabs: UIControl {
    
    open weak var dataSource: ColorTabsDataSource?
    
    /// Text color for titles.
    open var titleTextColor: UIColor = .white
    
    /// Font for titles.
    
    private let stackView = UIStackView()
    private var buttons: [UIButton] = []
    private var labels: [UILabel] = []
    private(set) lazy var highlighterView: UIView = {
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 0, height: self.bounds.height))
        let highlighterView = UIView(frame: frame)
        highlighterView.layer.cornerRadius = self.bounds.height / 2
        self.addSubview(highlighterView)
        self.sendSubviewToBack(highlighterView)
        
        return highlighterView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override open var frame: CGRect {
        didSet {
            stackView.frame = bounds
        }
    }
    
    override open var bounds: CGRect {
        didSet {
            stackView.frame = bounds
        }
    }
    
    open var selectedSegmentIndex: Int = 0 {
        didSet {
            if oldValue != selectedSegmentIndex {
                transition(from: oldValue, to: selectedSegmentIndex)
                sendActions(for: .valueChanged)
            }
        }
    }
    
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if window != nil {
            layoutIfNeeded()
            let countItems = dataSource?.numberOfItems(inTabSwitcher: self) ?? 0
            if countItems > selectedSegmentIndex {
                transition(from: selectedSegmentIndex, to: selectedSegmentIndex)
            }
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        moveHighlighterView(toItemAt: selectedSegmentIndex)
    }
    
    open func centerOfItem(atIndex index: Int) -> CGPoint {
        return buttons[index].center
    }
    
    open func setIconsHidden(_ hidden: Bool) {
        buttons.forEach {
            $0.alpha = hidden ? 0 : 1
        }
    }
    
    open func setHighlighterHidden(_ hidden: Bool) {
        let sourceHeight = hidden ? bounds.height : 0
        let targetHeight = hidden ? 0 : bounds.height - 20
        
        let animation: CAAnimation = {
            $0.fromValue = sourceHeight / 2
            $0.toValue = targetHeight / 2
            $0.duration = HighlighterAnimationDuration
            return $0
        }(CABasicAnimation(keyPath: "cornerRadius"))
        highlighterView.layer.add(animation, forKey: nil)
        highlighterView.layer.cornerRadius = targetHeight / 2
        
        UIView.animate(withDuration: HighlighterAnimationDuration) {
            self.highlighterView.frame.size.height = targetHeight
            self.highlighterView.alpha = hidden ? 0 : 1
            
            for label in self.labels {
                label.alpha = hidden ? 0 : 1
            }
        }
    }
    
    open func reloadData() {
        guard let dataSource = dataSource else {
            return
        }
        
        selectedSegmentIndex = 0
        stackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        buttons = []
        labels = []
        
        let count = dataSource.numberOfItems(inTabSwitcher: self)
        for index in 0..<count {
            let button = createButton(forIndex: index, withDataSource: dataSource)
            buttons.append(button)
            stackView.addArrangedSubview(button)
            
            let label = createLabel(forIndex: index, withDataSource: dataSource)
            labels.append(label)
            stackView.addArrangedSubview(label)
        }
        stackView.layoutIfNeeded()
        transition(from: selectedSegmentIndex, to: selectedSegmentIndex)
    }
    
}

/// Setup
private extension ColorTabs {
    
    func commonInit() {
        addSubview(stackView)
        stackView.distribution = .fillEqually
    }
    
    func createButton(forIndex index: Int, withDataSource dataSource: ColorTabsDataSource) -> UIButton {
        let button = UIButton()
        
        button.setImage(dataSource.tabSwitcher(self, iconAt: index), for: UIControl.State())
        button.setImage(dataSource.tabSwitcher(self, hightlightedIconAt: index), for: .selected)
        button.addTarget(self, action: #selector(selectButton(_:)), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        
        return button
    }
    
    func createLabel(forIndex index: Int, withDataSource dataSource: ColorTabsDataSource) -> UILabel {
        let label = UILabel()
        
        label.isHidden = true
        label.textAlignment = .left
        label.text = dataSource.tabSwitcher(self, titleAt: index)
        label.textColor = titleTextColor
        label.adjustsFontSizeToFitWidth = true
        label.sizeToFit()
        label.font = dataSource.tabSwitcher(self, titleFontAt: index)
        
        return label
    }
    
}

private extension ColorTabs {
    
    @objc
    func selectButton(_ sender: UIButton) {
        if let index = buttons.firstIndex(of: sender) {
            selectedSegmentIndex = index
        }
    }
    
    func transition(from fromIndex: Int, to toIndex: Int) {
        guard let fromLabel = labels[safe: fromIndex],
            let fromIcon = buttons[safe: fromIndex],
            let toLabel = labels[safe: toIndex],
            let toIcon = buttons[safe: toIndex] else {
                return
        }
        
        let animation = {
            fromLabel.isHidden = true
            fromLabel.alpha = 0
            fromIcon.isSelected = false
            
            toLabel.isHidden = false
            toLabel.alpha = 1
            toIcon.isSelected = true
            
            self.moveHighlighterView(toItemAt: toIndex)
        }
        
        UIView.animate(
            withDuration: SwitchAnimationDuration,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 3,
            options: [],
            animations: animation,
            completion: nil
        )
    }
    
    func moveHighlighterView(toItemAt toIndex: Int) {
        
        guard let countItems = dataSource?.numberOfItems(inTabSwitcher: self), countItems > toIndex else {
            return
        }
        
        stackView.layoutIfNeeded()
        
        let toLabel = labels[toIndex]
        let toIcon = buttons[toIndex]
        
        // offset for first item
        let point = convert(toIcon.frame.origin, to: self)
        highlighterView.frame.origin.x = point.x + 12.5
        highlighterView.frame.origin.y = 10
        
        highlighterView.frame.size.width = toLabel.bounds.width + (toLabel.frame.origin.x - toIcon.frame.origin.x) - 27.5
        
        highlighterView.backgroundColor = dataSource!.tabSwitcher(self, tintColorAt: toIndex)
    }
    
}
