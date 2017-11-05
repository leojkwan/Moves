import Foundation
import MiniObservable
import UIKit

public enum AnimaterLifecycleEvent: CustomStringConvertible {
  case transitionWillAnimate(transitionContext: UIViewControllerContextTransitioning)
  case transitionAnimating(transitionContext: UIViewControllerContextTransitioning)
  case transitionDidAnimate(transitionContext: UIViewControllerContextTransitioning)
  
  public var description: String {
    switch self {
    case .transitionAnimating:
      return "transition animating"
    case .transitionWillAnimate:
      return "transition will animate"
    case .transitionDidAnimate:
      return "transition did animate"
    }
  }
}

extension AnimaterLifecycleEvent: Equatable {}
public func ==(lhs: AnimaterLifecycleEvent, rhs: AnimaterLifecycleEvent) -> Bool {
  return lhs.description == rhs.description
}

open class Animator<PresentingVC: UIViewController, PresentedVC: UIViewController>: NSObject, UIViewControllerAnimatedTransitioning {
  
  public let events: Observable<AnimaterLifecycleEvent?> = Observable(nil)
  public let duration: Double
  public var registeredContextualViews: (() -> ([ContextualViewPair]))?
  public let isPresenter: Bool
  
  public init(isPresenter: Bool, duration: Double) {
    self.isPresenter = isPresenter
    self.duration = duration
  }
  
  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }
  
  open func prepareAnimationBlock(using transitionContext: UIViewControllerContextTransitioning, from presentingVC: PresentingVC, to presentedVC: PresentedVC) {
    events.value = AnimaterLifecycleEvent.transitionWillAnimate(transitionContext: transitionContext)
  }
  
  open func performAnimations(using transitionContext: UIViewControllerContextTransitioning, from presentingVC: PresentingVC, to presentedVC: PresentedVC, completion: @escaping ()-> ()) {
    events.value = AnimaterLifecycleEvent.transitionAnimating(transitionContext: transitionContext)
    
    // Should be subclassed; here we define how the presented view controller
    // is animated in while the presenting view controller is animated out.
  }
  
  open func completeAnimation(using transitionContext: UIViewControllerContextTransitioning, from presentingVC: PresentingVC, to presentedVC: PresentedVC) {
    events.value = AnimaterLifecycleEvent.transitionDidAnimate(transitionContext: transitionContext)
    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
  }
  
  open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    let presentingViewController: PresentingVC!
    
    if let fromVC = transitionContext.viewController(forKey: isPresenter ? .from : .to) as? PresentingVC {
      presentingViewController = fromVC
    } else if let fromVCNav = transitionContext.viewController(forKey: isPresenter ? .from : .to) as? UINavigationController,
      let embeddedFromVC = fromVCNav.topViewController as? PresentingVC {
      
      /* type check this common edge case.
       * if a presenting view controller is embedded
       * from a navigation controller, a modal presentation
       * will present from the root navigation.
       */
      
      presentingViewController = embeddedFromVC
    } else {
      // could not perform animation
      return
    }
    
    let toVC = transitionContext.viewController(forKey: isPresenter ? .to : .from) as! PresentedVC
    
    // Animate Contextual Views before preparation and primary animations if animator is a dismissor.
    // Animate Contextual Views at the end if animator is presenter.
    func animationContextualViewsIfNecessary() {
      
      if let contextualViews = registeredContextualViews?() {
        animateContextualViews(
          isPresenting: isPresenter,
          using: transitionContext,
          contextualViews: contextualViews
        )
        
        // nil registered contextual views once animations are run
        // we do not want to keep references to detail view controller subviews
        registeredContextualViews = nil
      }
    }
    
    if !isPresenter { animationContextualViewsIfNecessary() }
    
    // Prepare, Perform, Complete animation lifecycles sequentially invoked
    prepareAnimationBlock(using: transitionContext, from: presentingViewController, to: toVC)
    performAnimations(using: transitionContext, from: presentingViewController, to: toVC) { [weak self] in
      self?.completeAnimation(using: transitionContext, from: presentingViewController, to: toVC)
    }

    if isPresenter { animationContextualViewsIfNecessary() }
  }
  
  private func animateContextualViews(isPresenting: Bool, using transitionContext: UIViewControllerContextTransitioning, contextualViews: [ContextualViewPair]) {
    
    let container = transitionContext.containerView
    
    for viewConfig in contextualViews {
      
      let canvas = UIView(frame: container.bounds)
      container.addSubview(canvas)
      
      let startingContextualView = isPresenting ? viewConfig.fromView : viewConfig.toView
      let destinationContextualView = isPresenting ? viewConfig.toView : viewConfig.fromView
      
      guard let snapshot = startingContextualView.snapshotView(afterScreenUpdates: true) else {
        continue
      }
      
      var startingAnimationFrame: CGRect = startingContextualView.frame
      var startingAnimationCenter: CGPoint = startingContextualView.center
      var currentSuperView: UIView = startingContextualView.superview!
      
      func completeAnimation() {
        DispatchQueue.main.async {
          destinationContextualView.alpha = 1
          canvas.removeFromSuperview()
        }
      }
      
        while currentSuperView.superview != canvas {
          
          guard let animationSuperviewSuperView = currentSuperView.superview else { break }
          
          let convertedFrame = currentSuperView.convert(startingAnimationFrame, to: animationSuperviewSuperView)
          let convertedCenter = currentSuperView.convert(startingAnimationCenter, to: animationSuperviewSuperView)
          startingAnimationFrame = convertedFrame
          startingAnimationCenter = convertedCenter
          currentSuperView = animationSuperviewSuperView
        }
        
        if let startingViewControllerView = transitionContext.view(forKey: .from),
          startingViewControllerView.bounds.contains(startingAnimationFrame) == false {
          // Contextual view is completely outside it's containing view controller .
          // Do not animate and clean up transition
          completeAnimation()
          return
        }
        
        var destinationFrame: CGRect = destinationContextualView.frame
        var destinationCenter: CGPoint = destinationContextualView.center
        var currentDestinationSuperView: UIView = destinationContextualView.superview!
        
        while currentDestinationSuperView.superview != canvas {
          
          guard let animationSuperviewSuperView = currentDestinationSuperView.superview else { break }
          let convertedFrame = currentDestinationSuperView.convert(destinationFrame, to: animationSuperviewSuperView)
          let convertedCenter = currentDestinationSuperView.convert(destinationCenter, to: animationSuperviewSuperView)
          destinationFrame = convertedFrame
          destinationCenter = convertedCenter
          currentDestinationSuperView = animationSuperviewSuperView
        }
        
        
        snapshot.frame = startingAnimationFrame
        snapshot.center = startingAnimationCenter
        
        canvas.addSubview(snapshot)
        
        startingContextualView.alpha = 0
        destinationContextualView.alpha = 0
        
        UIView.animate(withDuration: self.duration, delay: 0, options: [
          .curveEaseInOut,
          .allowAnimatedContent
          ], animations: {
            
            snapshot.frame = destinationFrame
            snapshot.center = destinationCenter
            
        }, completion: {  _ in
          completeAnimation()
        })
      }
  }
}
