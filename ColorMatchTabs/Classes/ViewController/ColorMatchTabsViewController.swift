import UIKit

public protocol ColorMatchTabsViewControllerDataSource: class {
    
    func numberOfItems(inController controller: ColorMatchTabsViewController) -> Int
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, viewControllerAt index: Int) -> UIViewController
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, titleAt index: Int) -> String
    func tabsViewController(_ controller: ColorMatchTabsViewController, titleFontAt index: Int) -> UIFont
    func tabsViewController(_ controller: ColorMatchTabsViewController, iconAt index: Int) -> UIImage
    func tabsViewController(_ controller: ColorMatchTabsViewController, hightlightedIconAt index: Int) -> UIImage
    func tabsViewController(_ controller: ColorMatchTabsViewController, tintColorAt index: Int) -> UIColor
    
}

public protocol ColorMatchTabsViewControllerDelegate: class {
    
    func didSelectItemAt(_ index: Int)
    
}

extension ColorMatchTabsViewControllerDelegate {
    
    func didSelectItemAt(_ index: Int) {}
    
}

open class ColorMatchTabsViewController: UITabBarController {
    
    open weak var colorMatchTabDataSource: ColorMatchTabsViewControllerDataSource? {
        didSet {
            _view.scrollMenu.dataSource = colorMatchTabDataSource == nil ? nil : self
            _view.tabs.dataSource = colorMatchTabDataSource == nil ? nil : self
            reloadData()
        }
    }
    
    open weak var colorMatchTabDelegate: ColorMatchTabsViewControllerDelegate?
    
    open var scrollEnabled = true {
        didSet {
            updateScrollEnabled()
        }
    }
    
    public let titleLabel = UILabel()
    
    override open var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    open var selectedSegmentIndex: Int {
        return _view.tabs.selectedSegmentIndex
    }
    
    private var icons: [UIImageView] = []
    
    var _view: MenuView! {
        return view as? MenuView
    }
    
    open override func loadView() {
        super.loadView()
        view = MenuView(frame: view.frame)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTabSwitcher()
        setupIcons()
        setupScrollMenu()
        updateScrollEnabled()
    }
    
    open func selectItem(at index: Int) {
        updateNavigationBar(forSelectedIndex: index)
        _view.tabs.selectedSegmentIndex = index
        _view.scrollMenu.selectItem(atIndex: index)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectItem(at: _view.tabs.selectedSegmentIndex)
        setDefaultPositions()
    }
    
    open func reloadData() {
        _view.tabs.reloadData()
        _view.scrollMenu.reloadData()
        
        updateNavigationBar(forSelectedIndex: 0)
        setupIcons()
    }
    
}

// setup
private extension ColorMatchTabsViewController {
    
    func setupIcons() {
        guard let dataSource = colorMatchTabDataSource else {
            return
        }
        
        icons.forEach { $0.removeFromSuperview() }
        icons = []
        
        for index in 0..<dataSource.numberOfItems(inController: self) {
            let size = CGSize(width: 0, height: 0)
            let frame = CGRect(origin: .zero, size: CGSize(width: size.width / 2, height: size.height / 2))
            let iconImageView = UIImageView(frame: frame)
            iconImageView.image = dataSource.tabsViewController(self, hightlightedIconAt: index)
            iconImageView.contentMode = .center
            iconImageView.isHidden = true
            
            view.addSubview(iconImageView)
            icons.append(iconImageView)
        }
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.shadowImage = UIImage(namedInCurrentBundle: "transparent_pixel")
        let pixelImage = UIImage(namedInCurrentBundle: "pixel")
        navigationController?.navigationBar.setBackgroundImage(pixelImage, for: .default)
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: 120, height: 40)
        titleLabel.text = title
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel
    }
    
    func setupTabSwitcher() {
        _view.tabs.selectedSegmentIndex = 0
        _view.tabs.addTarget(self, action: #selector(changeContent(_:)), for: .valueChanged)
        _view.tabs.dataSource = self
    }
    
    func setupScrollMenu() {
        _view.scrollMenu.menuDelegate = self
    }
    
    func updateNavigationBar(forSelectedIndex index: Int) {
        let color = colorMatchTabDataSource?.tabsViewController(self, tintColorAt: index) ?? .white
        
        titleLabel.textColor = color
        _view.scrollMenu.backgroundColor = color.withAlphaComponent(0.2)
    }
    
    func updateScrollEnabled() {
        _view.scrollMenu.isScrollEnabled = scrollEnabled
    }
}

// animations
private extension ColorMatchTabsViewController {
    
    func setDefaultPositions() {
        _view.tabs.setHighlighterHidden(false)
        
        for (index, iconImageView) in icons.enumerated() {
            UIView.animate(
                withDuration: AnimationDuration,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 3,
                options: [],
                animations: {
                    let point = self._view.tabs.centerOfItem(atIndex: index)
                    iconImageView.center = self._view.tabs.convert(point, to: self.view)
                    
                    let image: UIImage?
                    if index == self._view.tabs.selectedSegmentIndex {
                        image = self.colorMatchTabDataSource?.tabsViewController(self, hightlightedIconAt: index)
                    } else {
                        image = self.colorMatchTabDataSource?.tabsViewController(self, iconAt: index)
                    }
                    iconImageView.image = image
            },
                completion: { _ in
                    self._view.tabs.setIconsHidden(false)
                    iconImageView.isHidden = true
            }
            )
        }
    }

    @objc
    func changeContent(_ sender: ColorTabs) {
        updateNavigationBar(forSelectedIndex: sender.selectedSegmentIndex)
        if _view.scrollMenu.destinationIndex != sender.selectedSegmentIndex {
            _view.scrollMenu.selectItem(atIndex: sender.selectedSegmentIndex)
        }
    }
    
}

extension ColorMatchTabsViewController: ScrollMenuDelegate {
    
    open func scrollMenu(_ scrollMenu: ScrollMenu, didSelectedItemAt index: Int) {
        updateNavigationBar(forSelectedIndex: index)
        if _view.tabs.selectedSegmentIndex != index {
            _view.tabs.selectedSegmentIndex = index
        }
        colorMatchTabDelegate?.didSelectItemAt(index)
    }
    
}

// MARK: - Data sources

extension ColorMatchTabsViewController: ColorTabsDataSource {
    
    open func numberOfItems(inTabSwitcher tabSwitcher: ColorTabs) -> Int {
        return colorMatchTabDataSource?.numberOfItems(inController: self) ?? 0
    }
    
    open func tabSwitcher(_ tabSwitcher: ColorTabs, titleAt index: Int) -> String {
        return colorMatchTabDataSource!.tabsViewController(self, titleAt: index)
    }
    
    public func tabSwitcher(_ tabSwitcher: ColorTabs, titleFontAt index: Int) -> UIFont {
        return (colorMatchTabDataSource?.tabsViewController(self, titleFontAt: index))!
    }
    
    open func tabSwitcher(_ tabSwitcher: ColorTabs, iconAt index: Int) -> UIImage {
        return colorMatchTabDataSource!.tabsViewController(self, iconAt: index)
    }
    
    open func tabSwitcher(_ tabSwitcher: ColorTabs, hightlightedIconAt index: Int) -> UIImage {
        return colorMatchTabDataSource!.tabsViewController(self, hightlightedIconAt: index)
    }
    
    open func tabSwitcher(_ tabSwitcher: ColorTabs, tintColorAt index: Int) -> UIColor {
        return colorMatchTabDataSource!.tabsViewController(self, tintColorAt: index)
    }
    
}

extension ColorMatchTabsViewController: ScrollMenuDataSource {
    
    open func numberOfItemsInScrollMenu(_ scrollMenu: ScrollMenu) -> Int {
        return colorMatchTabDataSource?.numberOfItems(inController: self) ?? 0
    }
    
    open func scrollMenu(_ scrollMenu: ScrollMenu, viewControllerAtIndex index: Int) -> UIViewController {
        return colorMatchTabDataSource!.tabsViewController(self, viewControllerAt: index)
    }
    
}


