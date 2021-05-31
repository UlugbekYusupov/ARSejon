//
//  TestFoldingCell.swift
//  MapWithAR
//
//  Created by Ulugbek Yusupov on 12/22/19.
//  Copyright © 2019 Ulugbek Yusupov. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    enum Const {
        static let closeCellHeight: CGFloat = 179
        static let openCellHeight: CGFloat = 488
        static let rowsCount = 10
    }
    
    var cellHeights: [CGFloat] = []

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: Helpers
    private func setup() {
        cellHeights = Array(repeating: Const.closeCellHeight, count: Const.rowsCount)
        tableView.estimatedRowHeight = Const.closeCellHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "logo-brand-red-font-the-start-button"))
        if #available(iOS 10.0, *) {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(refreshHandler), for: .valueChanged)
        }
    }
    
    // MARK: Actions
    @objc func refreshHandler() {
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: { [weak self] in
            if #available(iOS 10.0, *) {
                self?.tableView.refreshControl?.endRefreshing()
            }
            self?.tableView.reloadData()
        })
    }
}

// MARK: - TableView

extension TableViewController {

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 10
    }

    override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as DemoCell = cell else {
            return
        }

        cell.backgroundColor = .clear

        if cellHeights[indexPath.row] == Const.closeCellHeight {
            cell.unfold(false, animated: false, completion: nil)
        } else {
            cell.unfold(true, animated: false, completion: nil)
        }

        cell.number = indexPath.row
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldingCell", for: indexPath) as! FoldingCell
        let durations: [TimeInterval] = [0.26, 0.2, 0.2]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
        return cell
    }

    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell

        if cell.isAnimating() {
            return
        }

        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == Const.closeCellHeight
        if cellIsCollapsed {
            cellHeights[indexPath.row] = Const.openCellHeight
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = Const.closeCellHeight
            cell.unfold(false, animated: true, completion: nil)
            duration = 0.8
        }

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
            
            // fix https://github.com/Ramotion/folding-cell/issues/169
            if cell.frame.maxY > tableView.frame.maxY {
                tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }, completion: nil)
    }
}

class DemoCell: FoldingCell {

    @IBOutlet var closeNumberLabel: UILabel!
    @IBOutlet var openNumberLabel: UILabel!

    var number: Int = 0 {
        didSet {
            closeNumberLabel.text = String(number)
            openNumberLabel.text = String(number)
        }
    }

    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }

    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
}

// MARK: - Actions ⚡️

extension DemoCell {

    @IBAction func buttonHandler(_: AnyObject) {
        print("tap")
    }
}

open class FoldingCell: UITableViewCell {
    
    @objc open var isUnfolded = false
    
    /// UIView is displayed when cell open
    @IBOutlet open var containerView: UIView!
    @IBOutlet open var containerViewTop: NSLayoutConstraint!
    
    /// UIView whitch display when cell close
    @IBOutlet open var foregroundView: RotatedView!
    @IBOutlet open var foregroundViewTop: NSLayoutConstraint!
    var animationView: UIView?
    
    ///  the number of folding elements. Default 2
    @IBInspectable open var itemCount: NSInteger = 2
    
    /// The color of the back cell
    @IBInspectable open var backViewColor: UIColor = UIColor.brown
    
    var animationItemViews: [RotatedView]?
    
    /**
     Folding animation types
     
     - Open:  Open direction
     - Close: Close direction
     */
    @objc public enum AnimationType : Int {
        case open
        case close
    }
    
    // MARK: Life Cycle
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        commonInit()
    }
    
    /**
     Call this method in methods init(style: UITableViewCellStyle, reuseIdentifier: String?) after creating Views
     */
    @objc open func commonInit() {
        configureDefaultState()
        
        selectionStyle = .none
        
        containerView.layer.cornerRadius = foregroundView.layer.cornerRadius
        containerView.layer.masksToBounds = true
    }
    
    // MARK: configure
    
    private func configureDefaultState() {
        
        guard let foregroundViewTop = self.foregroundViewTop,
            let containerViewTop = self.containerViewTop else {
                fatalError("set foregroundViewTop or containerViewTop outlets in storyboard")
        }
        
        containerViewTop.constant = foregroundViewTop.constant
        containerView.alpha = 0
        
        if let height = (foregroundView.constraints.filter { $0.firstAttribute == .height && $0.secondItem == nil }).first?.constant {
            foregroundView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
            foregroundViewTop.constant += height / 2
        }
        foregroundView.layer.transform = foregroundView.transform3d()
        
        createAnimationView()
        contentView.bringSubviewToFront(foregroundView)
    }
    
    private func createAnimationItemView() -> [RotatedView] {
        
        var items = [RotatedView]()
        items.append(foregroundView)
        var rotatedViews = [RotatedView]()
        
        animationView?.subviews
            .lazy
            .compactMap({ $0 as? RotatedView })
            .sorted(by: { $0.tag < $1.tag })
            .forEach { itemView in
                rotatedViews.append(itemView)
                if let backView = itemView.backView {
                    rotatedViews.append(backView)
                }
        }
        
        items.append(contentsOf: rotatedViews)
        return items
    }
    
    func configureAnimationItems(_ animationType: AnimationType) {
        
        if animationType == .open {
            animationView?.subviews
                .lazy
                .compactMap { $0 as? RotatedView }
                .forEach { $0.alpha = 0 }
        } else {
            animationView?.subviews
                .lazy
                .compactMap { $0 as? RotatedView }
                .forEach {
                    $0.alpha = animationType == .open ? 0 : 1
                    if animationType != .open { $0.backView?.alpha = 0 }
            }
        }
    }
    
    func createAnimationView() {
        animationView = UIView(frame: containerView.frame)
        animationView?.layer.cornerRadius = foregroundView.layer.cornerRadius
        animationView?.backgroundColor = .clear
        animationView?.translatesAutoresizingMaskIntoConstraints = false
        animationView?.alpha = 0
        
        guard let animationView = self.animationView else { return }
        
        self.contentView.addSubview(animationView)
        
        // copy constraints from containerView
        var newConstraints = [NSLayoutConstraint]()
        for constraint in self.contentView.constraints {
            if let item = constraint.firstItem as? UIView, item == containerView {
                let newConstraint = NSLayoutConstraint(item: animationView, attribute: constraint.firstAttribute,
                                                       relatedBy: constraint.relation, toItem: constraint.secondItem, attribute: constraint.secondAttribute,
                                                       multiplier: constraint.multiplier, constant: constraint.constant)
                
                newConstraints.append(newConstraint)
            } else if let firstItem = constraint.firstItem as? UIView, let secondItem: UIView = constraint.secondItem as? UIView, secondItem == containerView {
                let newConstraint = NSLayoutConstraint(item: firstItem, attribute: constraint.firstAttribute,
                                                       relatedBy: constraint.relation, toItem: animationView, attribute: constraint.secondAttribute,
                                                       multiplier: constraint.multiplier, constant: constraint.constant)
                
                newConstraints.append(newConstraint)
            }
        }
        self.contentView.addConstraints(newConstraints)
        
        for constraint in containerView.constraints { // added height constraint
            if constraint.firstAttribute == .height, let item: UIView = constraint.firstItem as? UIView, item == containerView {
                let newConstraint = NSLayoutConstraint(item: animationView, attribute: constraint.firstAttribute,
                                                       relatedBy: constraint.relation, toItem: nil, attribute: constraint.secondAttribute,
                                                       multiplier: constraint.multiplier, constant: constraint.constant)
                
                animationView.addConstraint(newConstraint)
            }
        }
    }
    
    func addImageItemsToAnimationView() {
        containerView.alpha = 1
        let containerViewSize = containerView.bounds.size
        let foregroundViewSize = foregroundView.bounds.size
        
        // added first item
        var image = containerView.takeSnapshot(CGRect(x: 0, y: 0, width: containerViewSize.width, height: foregroundViewSize.height))
        var imageView = UIImageView(image: image)
        imageView.tag = 0
        imageView.layer.cornerRadius = foregroundView.layer.cornerRadius
        animationView?.addSubview(imageView)
        
        // added secod item
        image = containerView.takeSnapshot(CGRect(x: 0, y: foregroundViewSize.height, width: containerViewSize.width, height: foregroundViewSize.height))
        
        imageView = UIImageView(image: image)
        let rotatedView = RotatedView(frame: imageView.frame)
        rotatedView.tag = 1
        rotatedView.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        rotatedView.layer.transform = rotatedView.transform3d()
        
        rotatedView.addSubview(imageView)
        animationView?.addSubview(rotatedView)
        rotatedView.frame = CGRect(x: imageView.frame.origin.x, y: foregroundViewSize.height, width: containerViewSize.width, height: foregroundViewSize.height)
        
        // added other views
        let itemHeight = (containerViewSize.height - 2 * foregroundViewSize.height) / CGFloat(itemCount - 2)
        
        if itemCount == 2 {
            // decrease containerView height or increase itemCount
            assert(containerViewSize.height - 2 * foregroundViewSize.height == 0, "contanerView.height too high")
        } else {
            // decrease containerView height or increase itemCount
            assert(containerViewSize.height - 2 * foregroundViewSize.height >= itemHeight, "contanerView.height too high")
        }
        
        var yPosition = 2 * foregroundViewSize.height
        var tag = 2
        for _ in 2 ..< itemCount {
            image = containerView.takeSnapshot(CGRect(x: 0, y: yPosition, width: containerViewSize.width, height: itemHeight))
            
            imageView = UIImageView(image: image)
            let rotatedView = RotatedView(frame: imageView.frame)
            
            rotatedView.addSubview(imageView)
            rotatedView.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
            rotatedView.layer.transform = rotatedView.transform3d()
            animationView?.addSubview(rotatedView)
            rotatedView.frame = CGRect(x: 0, y: yPosition, width: rotatedView.bounds.size.width, height: itemHeight)
            rotatedView.tag = tag
            
            yPosition += itemHeight
            tag += 1
        }
        
        containerView.alpha = 0
        
        if let animationView = self.animationView {
            // added back view
            var previuosView: RotatedView?
            for case let container as RotatedView in animationView.subviews.sorted(by: { $0.tag < $1.tag })
                where container.tag > 0 && container.tag < animationView.subviews.count {
                    previuosView?.addBackView(container.bounds.size.height, color: backViewColor)
                    previuosView = container
            }
        }
        animationItemViews = createAnimationItemView()
    }
    
    fileprivate func removeImageItemsFromAnimationView() {
        
        guard let animationView = self.animationView else {
            return
        }
        
        animationView.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    // MARK: public
    
    /// Unfold cell.
    ///
    /// - Parameters:
    ///   - value: unfold = true; collapse = false.
    ///   - animated: animate changes.
    ///   - completion: A block object to be executed when the animation sequence ends.
    @objc open func unfold(_ value: Bool, animated: Bool = true, completion: (() -> Void)? = nil) {
        if animated {
            value ? openAnimation(completion) : closeAnimation(completion)
        } else {
            foregroundView.alpha = value ? 0 : 1
            containerView.alpha = value ? 1 : 0
        }
    }
    
    @objc open func isAnimating() -> Bool {
        return animationView?.alpha == 1 ? true : false
    }
    
    // MARK: Animations
    
    @objc open dynamic func animationDuration(_ itemIndex: NSInteger, type: AnimationType) -> TimeInterval {
        return type == .close ? durationsForCollapsedState[itemIndex] : durationsForExpandedState[itemIndex]
    }
    
    @objc open var durationsForExpandedState: [TimeInterval] = []
    @objc open var durationsForCollapsedState: [TimeInterval] = []
    
    func durationSequence(_ type: AnimationType) -> [TimeInterval] {
        var durations = [TimeInterval]()
        for i in 0 ..< itemCount - 1 {
            let duration = animationDuration(i, type: type)
            durations.append(TimeInterval(duration / 2.0))
            durations.append(TimeInterval(duration / 2.0))
        }
        return durations
    }
    
    func openAnimation(_ completion: (() -> Void)?) {
        isUnfolded = true
        removeImageItemsFromAnimationView()
        addImageItemsToAnimationView()
        
        animationView?.alpha = 1
        containerView.alpha = 0
        
        let durations = durationSequence(.open)
        
        var delay: TimeInterval = 0
        var timing = convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.easeIn)
        var from: CGFloat = 0.0
        var to: CGFloat = -CGFloat.pi / 2
        var hidden = true
        configureAnimationItems(.open)
        
        guard let animationItemViews = self.animationItemViews else {
            return
        }
        
        for index in 0 ..< animationItemViews.count {
            let animatedView = animationItemViews[index]
            
            animatedView.foldingAnimation(timing, from: from, to: to, duration: durations[index], delay: delay, hidden: hidden)
            
            from = from == 0.0 ? CGFloat.pi / 2 : 0.0
            to = to == 0.0 ? -CGFloat.pi / 2 : 0.0
            timing = timing == convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.easeIn) ? convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.easeOut) : convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.easeIn)
            hidden = !hidden
            delay += durations[index]
        }
        
        let firstItemView = animationView?.subviews.filter { $0.tag == 0 }.first
        
        firstItemView?.layer.masksToBounds = true
        DispatchQueue.main.asyncAfter(deadline: .now() + durations[0], execute: {
            firstItemView?.layer.cornerRadius = 0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.animationView?.alpha = 0
            self.containerView.alpha = 1
            completion?()
        }
    }
    
    func closeAnimation(_ completion: (() -> Void)?) {
        isUnfolded = false
        removeImageItemsFromAnimationView()
        addImageItemsToAnimationView()
        
        guard let animationItemViews = self.animationItemViews else {
            fatalError()
        }
        
        animationView?.alpha = 1
        containerView.alpha = 0
        
        let durations: [TimeInterval] = durationSequence(.close).reversed()
        
        var delay: TimeInterval = 0
        var timing = convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.easeIn)
        var from: CGFloat = 0.0
        var to: CGFloat = CGFloat.pi / 2
        var hidden = true
        configureAnimationItems(.close)
        
        if durations.count < animationItemViews.count {
            fatalError("wrong override func animationDuration(itemIndex:NSInteger, type:AnimationType)-> NSTimeInterval")
        }
        for index in 0 ..< animationItemViews.count {
            let animatedView = animationItemViews.reversed()[index]
            
            animatedView.foldingAnimation(timing, from: from, to: to, duration: durations[index], delay: delay, hidden: hidden)
            
            to = to == 0.0 ? CGFloat.pi / 2 : 0.0
            from = from == 0.0 ? -CGFloat.pi / 2 : 0.0
            timing = timing == convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.easeIn) ? convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.easeOut) : convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.easeIn)
            hidden = !hidden
            delay += durations[index]
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            self.animationView?.alpha = 0
            completion?()
        })
        
        let firstItemView = animationView?.subviews.filter { $0.tag == 0 }.first
        firstItemView?.layer.cornerRadius = 0
        firstItemView?.layer.masksToBounds = true
        if let durationFirst = durations.first {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay - durationFirst * 2, execute: {
                firstItemView?.layer.cornerRadius = self.foregroundView.layer.cornerRadius
                firstItemView?.setNeedsDisplay()
                firstItemView?.setNeedsLayout()
            })
        }
    }
}

// MARK: RotatedView

open class RotatedView: UIView {
    
    private enum Const {
        static let rotationX = "rotation.x"
        static let transformRotationX = "transform.rotation.x"
    }
    
    var hiddenAfterAnimation = false
    var backView: RotatedView?
    
    func addBackView(_ height: CGFloat, color: UIColor) {
        let view = RotatedView(frame: CGRect.zero)
        view.backgroundColor = color
        view.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        view.layer.transform = view.transform3d()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        backView = view
        
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height,
                                              multiplier: 1, constant: height))
        
        self.addConstraints([
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1,
                               constant: self.bounds.size.height - height + height / 2),
            NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing,
                               multiplier: 1, constant: 0),
            ])
    }
}

extension RotatedView: CAAnimationDelegate {
    
    func rotatedX(_ angle: CGFloat) {
        var allTransofrom = CATransform3DIdentity
        let rotateTransform = CATransform3DMakeRotation(angle, 1, 0, 0)
        allTransofrom = CATransform3DConcat(allTransofrom, rotateTransform)
        allTransofrom = CATransform3DConcat(allTransofrom, transform3d())
        self.layer.transform = allTransofrom
    }
    
    func transform3d() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = 2.5 / -2000
        return transform
    }
    
    // MARK: animations
    
    func foldingAnimation(_ timing: String, from: CGFloat, to: CGFloat, duration: TimeInterval, delay: TimeInterval, hidden: Bool) {
        
        let rotateAnimation = CABasicAnimation(keyPath: Const.transformRotationX)
        rotateAnimation.timingFunction = CAMediaTimingFunction(name: convertToCAMediaTimingFunctionName(timing))
        rotateAnimation.fromValue = from
        rotateAnimation.toValue = to
        rotateAnimation.duration = duration
        rotateAnimation.delegate = self
        rotateAnimation.fillMode = CAMediaTimingFillMode.forwards
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.beginTime = CACurrentMediaTime() + delay
        
        self.hiddenAfterAnimation = hidden
        
        self.layer.add(rotateAnimation, forKey: Const.rotationX)
    }
    
    public func animationDidStart(_: CAAnimation) {
        self.layer.shouldRasterize = true
        self.alpha = 1
    }
    
    public func animationDidStop(_: CAAnimation, finished _: Bool) {
        if hiddenAfterAnimation {
            self.alpha = 0
        }
        self.layer.removeAllAnimations()
        self.layer.shouldRasterize = false
        self.rotatedX(CGFloat(0))
    }
}

// MARK: UIView + extension
private extension UIView {
    
    func takeSnapshot(_ frame: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.translateBy(x: frame.origin.x * -1, y: frame.origin.y * -1)
        
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCAMediaTimingFunctionName(_ input: CAMediaTimingFunctionName) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAMediaTimingFunctionName(_ input: String) -> CAMediaTimingFunctionName {
    return CAMediaTimingFunctionName(rawValue: input)
}
