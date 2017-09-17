import Foundation
import UIKit
import MiniObservable

public typealias ContextualViewPair = (fromView: UIView, toView: UIView)

public enum Direction {
  case left
  case right
  case up
  case down
}

public enum PannableMoveDirection {
  case vertical
  case horizontal
  case free
}

public struct PannableMoveOptions {
  static public func defaultOptions() -> PannableMoveOptions {
    return PannableMoveOptions(
      direction: PannableMoveDirection.free,
      dismissRadiusThreshold: 50,
      lockedDirections: []
    )
  }
  
  public let direction: PannableMoveDirection
  public let dismissRadiusThreshold: CGFloat
  public let lockedDirections: [Direction]
  
  public init(
    direction: PannableMoveDirection,
    dismissRadiusThreshold: CGFloat,
    lockedDirections: [Direction]
    ) {
    self.direction = direction
    self.dismissRadiusThreshold = dismissRadiusThreshold
    self.lockedDirections = lockedDirections
  }
}


public struct MovesConfiguration {
  public static func defaultConfig() -> MovesConfiguration {
    return MovesConfiguration(
      showBackgroundDimView: true,
      dismissDimViewOnTap: true,
      presentedVCIsPannable: true,
      panOptions: PannableMoveOptions.defaultOptions()
    )
  }
  
  public let showBackgroundDimView: Bool
  public let dismissDimViewOnTap: Bool
  public let presentedVCIsPannable: Bool
  public let panOptions: PannableMoveOptions
  
  public init(
    showBackgroundDimView: Bool,
    dismissDimViewOnTap: Bool,
    presentedVCIsPannable: Bool,
    panOptions: PannableMoveOptions
    ) {
    self.showBackgroundDimView = showBackgroundDimView
    self.dismissDimViewOnTap = dismissDimViewOnTap
    self.presentedVCIsPannable = presentedVCIsPannable
    self.panOptions = panOptions
  }
}


open class MovesCoordinator<Presenter: Animator<T, U>, Dismisser: Animator<T, U>, T, U>: NSObject, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate  {
  
  private let disposeBag = DisposeBag()
  fileprivate var dimBackgroundView: UIView?
  fileprivate var originPoint: CGPoint!
  public let presenter: Presenter
  public var dismisser: Dismisser
  public let config: MovesConfiguration
  public let unwindContextualViewsOnDismiss: Bool = true
  weak var presentedViewController: U?
  weak var presentingViewController: T?
  
  public init(
    presenter: Presenter,
    dismisser: Dismisser,
    config: MovesConfiguration = MovesConfiguration.defaultConfig()) {
    self.presenter = presenter
    self.dismisser = dismisser
    self.config = config
    super.init()
    
    self.observeAnimatorLifeCycles(presenter: presenter, dismisser: dismisser)
  }
  
  private func observeAnimatorLifeCycles(presenter: Presenter, dismisser: Dismisser) {
    
    // Observe presenter
    presenter.events.observe { [weak self] (_, newEvent) in
      
      guard let strongSelf = self else { return }
      guard let event = newEvent else { return }
      
      
      switch event {
      case .transitionAnimating(let transitionContext):
        if strongSelf.config.showBackgroundDimView {
          strongSelf.handleBackgroundDimView(isPresenting: true, transitionContext: transitionContext)
        }
      default:
        break
      }
      }.disposed(by: disposeBag)
    
    
    // Observe dismisser
    dismisser.events.observe { [weak self] (_, newEvent) in
      
      guard let strongSelf = self else { return }
      guard let event = newEvent else { return }
      
      
      switch event {
      case .transitionAnimating(let transitionContext):
        if strongSelf.config.showBackgroundDimView {
          strongSelf.handleBackgroundDimView(isPresenting: false, transitionContext: transitionContext)
        }
      default:
        break
      }
      }.disposed(by: disposeBag)
  }
  
  private func handleBackgroundDimView(isPresenting: Bool, transitionContext: UIViewControllerContextTransitioning) {
    
    if isPresenting {
      guard let toView = transitionContext.view(forKey: .to) else { return }
      guard dimBackgroundView == nil else { return }
      
      let containerView = transitionContext.containerView
      
      // Create dim view
      let dimView = UIView(frame: containerView.bounds)
      dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      dimView.backgroundColor = UIColor(white: 0.0, alpha: 0)
      containerView.insertSubview(dimView, belowSubview: toView)
      
      // Add gesture recognizer to remove dim view
      if config.dismissDimViewOnTap {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dimBackgroundTapped))
        dimView.addGestureRecognizer(tap)
      }
      
      // keep reference to dim view for future dismissal
      dimBackgroundView = dimView
      
      UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
        dimView.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
      }, completion: nil)
      
    } else {
      self.removeDim(duration: self.dismisser.duration)
    }
  }
  
  public func present(_ presentedVC: U, presentingVC: T, with registeredContextualViews: (()->([ContextualViewPair]))? = nil){
    
    self.presenter.registeredContextualViews = registeredContextualViews
    self.presentedViewController = presentedVC
    self.presentingViewController = presentingVC
    
    // Register the same contextual views on the dismiss back, the animation are flip flopped.
    if unwindContextualViewsOnDismiss {
      dismisser.registeredContextualViews = registeredContextualViews
    }
    
    presentedVC.transitioningDelegate = self
    presentedVC.modalPresentationStyle = .overCurrentContext
    presentingVC.present(presentedVC, animated: true, completion: {
      if self.config.presentedVCIsPannable {
        self.enablePan()
      }
    })
  }
  
  public func enablePan() {
    if let toView = presentedViewController?.view {
      let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
      pan.delegate = self
      toView.addGestureRecognizer(pan)
      
      // keep a reference of origin when we need to
      // animated back to starting position(minimal pan gestures)
      self.originPoint = toView.frame.origin
    }
  }
  
  public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return presenter
  }
  
  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return dismisser
  }
  
  private func removeDim(duration: TimeInterval) {
    
    UIView.animate(withDuration: duration, delay: 0, options: [], animations: { [weak self] in
      
      guard let strongSelf = self else { return }
      
      strongSelf.dimBackgroundView?.backgroundColor = UIColor(white: 0.0, alpha: 0)
      }, completion: { [weak self] _ in
        
        guard let strongSelf = self else { return }
        
        strongSelf.dimBackgroundView?.removeFromSuperview()
        strongSelf.dimBackgroundView = nil
    })
  }
  
  internal func dimBackgroundTapped() {
    // Dismiss presented view controller
    presentedViewController?.dismiss(animated: true, completion: nil)
  }
  
  public func resize(
    verticalOffset: CGFloat,
    fromTop: Bool = true,
    relativeSizeToParent: CGFloat = 1,
    sideOffset: CGFloat = 20
    ){
    
    guard let fromVC = presentingViewController,
      let toVC = presentedViewController else { return }
    
    toVC.beginAppearanceTransition(true, animated: true)
    
    let repositionedX = sideOffset/2
    let repositionedY = fromTop ?
      verticalOffset:
      fromVC.view.bounds.height - verticalOffset
    
    UIView.animate(withDuration: 0.3) {
      toVC.view.frame = CGRect(
        x: repositionedX,
        y: repositionedY,
        width: fromVC.view.bounds.width - sideOffset,
        height: fromVC.view.bounds.height * relativeSizeToParent
      )
    }
    
    // Update origin point
    self.originPoint = toVC.view.frame.origin
    
    toVC.view.translatesAutoresizingMaskIntoConstraints = true
    toVC.view.layoutIfNeeded()
    toVC.endAppearanceTransition()
  }
  
  internal func handlePan(_ gesture: UIPanGestureRecognizer) {
    
    guard let presentedVC = presentedViewController else { return }
    guard let toView = gesture.view else { return }
    
    // On Pan
    let translation = gesture.translation(in: toView)
    var xTranslation: CGFloat = 0
    var yTranslation: CGFloat = 0
    
    switch config.panOptions.direction {
    case .horizontal:
      xTranslation = translation.x
    case .vertical:
      yTranslation = translation.y
    case .free:
      xTranslation = translation.x
      yTranslation = translation.y
    }
    
    for lockedDirection in config.panOptions.lockedDirections {
      switch lockedDirection {
      case .up:
        if yTranslation < 0 { yTranslation = 0 }
      case .down:
        if yTranslation > 0 { yTranslation = 0 }
      case .left:
        if xTranslation < 0 { xTranslation = 0 }
      case .right:
        if xTranslation > 0 { xTranslation = 0 }
      }
    }
    
    toView.center = CGPoint(
      x: toView.center.x + xTranslation,
      y: toView.center.y + yTranslation
    )
    
    gesture.setTranslation(CGPoint.zero, in: toView)
    
    // On Release
    if(gesture.state == .ended) {
      
      func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
      }
      
      
      let distanceFromCenter = distance(originPoint, toView.frame.origin)
      
      DispatchQueue.main.async {
        if (distanceFromCenter > self.config.panOptions.dismissRadiusThreshold) {
          
          presentedVC.dismiss(animated: true, completion: nil)
          
        } else {
          
          UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 1,
            options: [],
            animations: {
              toView.frame.origin = self.originPoint
          }, completion: nil)
        }
      }
    }
  }
  
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    if let scrollView = otherGestureRecognizer.view as? UIScrollView {
      if scrollView.contentOffset.y <= 0 {
        return true
      }
    }
    
    return false
  }
}


