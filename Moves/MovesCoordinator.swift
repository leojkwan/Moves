import Foundation
import UIKit
import MiniObservable

public typealias ContextualViewPair = (fromView: UIView, toView: UIView)

open class MovesCoordinator<T: UIViewController, U: UIViewController>: NSObject, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {
  
  public typealias VCAnimator = Animator<T, U>
  
  private let disposeBag = DisposeBag()
  private var originPoint: CGPoint = CGPoint.zero
  public let presenter: VCAnimator
  public var dismisser: VCAnimator
  public var movesConfig: MovesConfiguration
  public var dimConfig: DimOverlayConfiguration
  public var panConfig: PannableConfiguration
  private weak var presentingViewController: T?
  private weak var presentedViewController: U?
  
  // Background dim
  fileprivate var dimBackgroundView: UIView?
  
  public init(
    presenter: VCAnimator,
    dismisser: VCAnimator,
    movesConfig: MovesConfiguration = MovesConfiguration.defaultConfig(),
    dimConfig: DimOverlayConfiguration = DimOverlayConfiguration.defaultConfig()
    ) {
    self.presenter = presenter
    self.dismisser = dismisser
    self.movesConfig = movesConfig
    self.dimConfig = dimConfig
    self.panConfig = PannableConfiguration.defaultOptions()
    super.init()
    
    self.observeAnimatorLifeCycles(presenter: presenter, dismisser: dismisser)
  }
  
  private func observeAnimatorLifeCycles(presenter: VCAnimator, dismisser: VCAnimator) {
    
    for animator in [presenter, dismisser] {
      
      animator.events.observe { [weak self] (_, newEvent) in
        
        guard let strongSelf = self else { return }
        guard let event = newEvent else { return }
        
        switch event {
        case .transitionDidAnimate:
          
          if !animator.isPresenter {
            // clean up any references coordinator has with
            // the transition that just finished
            strongSelf.performCleanup()
          }
        case .transitionWillAnimate(let transitionContext):
          strongSelf.presentingViewController?.view.transform = CGAffineTransform.identity

          strongSelf.resetVCTransformationsIfNecessary(animator: animator, with: transitionContext)
          
          if strongSelf.movesConfig.showBackgroundDimView {
            strongSelf.handleBackgroundDimView(
              isPresenting: animator.isPresenter,
              transitionContext: transitionContext
            )
          }
        }
        }.disposed(by: disposeBag)
    }
  }
  
  private func performCleanup() {
    presentedViewController = nil
    presentingViewController = nil
    presenter.registeredContextualViews = nil
    dismisser.registeredContextualViews = nil
    presenter.events.value = nil
    dismisser.events.value = nil
  }
  
  private func resetVCTransformationsIfNecessary(animator: VCAnimator, with transitionContext: UIViewControllerContextTransitioning) {
    
    // Make sure we are dismissing and presenter transformed presenting view controller
    guard !animator.isPresenter && presenter is TransformAnimator else { return }
    
    // Reset any view transformations presenter made
    DispatchQueue.main.async { [weak self] in
      guard let strongSelf = self else { return }
      UIView.animate(withDuration: strongSelf.dismisser.transitionDuration(using: transitionContext), animations: {
        strongSelf.presentingViewController?.view.transform = CGAffineTransform.identity
      })
    }
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
      if dimConfig.dismissDimViewOnTap {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dimBackgroundTapped))
        dimView.addGestureRecognizer(tap)
      }
      
      // keep reference to dim view for future dismissal
      dimBackgroundView = dimView
      
      UIView.animate(withDuration: self.presenter.duration, delay: 0, options: [], animations: {
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
    
    // Register the same contextual views for the dismiss transition back.
    // This animates contextual views back into place when dismissing.
    if movesConfig.unwindContextualViewsOnDismiss {
      dismisser.registeredContextualViews = registeredContextualViews
    }
    
    presentedVC.transitioningDelegate = self
    presentedVC.modalPresentationStyle = .overCurrentContext
    presentingVC.present(presentedVC, animated: true, completion: { [weak self] in
      guard let strongSelf = self else { return }
      if strongSelf.movesConfig.pannable {
        strongSelf.enablePan()
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
  
  @objc func dimBackgroundTapped() {
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
  
  @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
    
    guard let presentedVC = presentedViewController else { return }
    guard let toView = gesture.view else { return }
    
    // On Pan
    let translation = gesture.translation(in: toView)
    var xTranslation: CGFloat = 0
    var yTranslation: CGFloat = 0
    
    switch panConfig.direction {
    case .horizontal:
      xTranslation = translation.x
    case .vertical:
      yTranslation = translation.y
    case .free:
      xTranslation = translation.x
      yTranslation = translation.y
    }
    
    for lockedDirection in panConfig.lockedDirections {
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
        if (distanceFromCenter > self.panConfig.dismissRadiusThreshold) {
          
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
  
  // Helpers
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
  
  // MARK: UIViewControllerTransitioningDelegate
  public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return presenter
  }
  
  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return dismisser
  }
  
  // MARK: UIGestureRecognizerDelegate
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return false
  }
}


