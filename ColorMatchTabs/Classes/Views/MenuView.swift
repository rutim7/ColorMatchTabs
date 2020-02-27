import UIKit

class MenuView: UIView {
    
    private(set) var navigationBar: UIView!
    private(set) var tabs: ColorTabs!
    private(set) var scrollMenu: ScrollMenu!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        layoutIfNeeded()
    }
    
}

// Init
private extension MenuView {
    
    func commonInit() {
        backgroundColor = .white
        createSubviews()
        layoutNavigationBar()
        layoutTabs()
        layoutScrollMenu()
    }
    
    func createSubviews() {
        scrollMenu = ScrollMenu()
        scrollMenu.showsHorizontalScrollIndicator = false
        addSubview(scrollMenu)
        
        navigationBar = ExtendedNavigationBar()
        navigationBar.backgroundColor = .white
        addSubview(navigationBar)
        
        tabs = ColorTabs()
        tabs.isUserInteractionEnabled = true
        navigationBar.addSubview(tabs)
    }
    
}

// Layout
private extension MenuView {
    
    func layoutNavigationBar() {
        
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant:0).isActive = true
        navigationBar.topAnchor.constraint(equalTo: topAnchor).isActive = false
        navigationBar.heightAnchor.constraint(equalToConstant: 65).isActive = true
        navigationBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: safeAreaInsets.bottom).isActive = true
    }
    
    func layoutTabs() {
        tabs.translatesAutoresizingMaskIntoConstraints = false
        tabs.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor).isActive = true
        tabs.topAnchor.constraint(equalTo: navigationBar.topAnchor).isActive = true
        tabs.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor).isActive = true
        tabs.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -6).isActive = true
        tabs.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor).isActive = true
    }
    
    func layoutScrollMenu() {
        scrollMenu.translatesAutoresizingMaskIntoConstraints = false
        scrollMenu.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        scrollMenu.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        scrollMenu.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        scrollMenu.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
}
