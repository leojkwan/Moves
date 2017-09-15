import Foundation
import Observable
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
  
  public var isPresenter: Bool {
    return self is CustomPresenterDelegate
  }
  
  public init(duration: Double) {
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
    
    let fromVC =  transitionContext.viewController(forKey: self is CustomPresenterDelegate ? .from : .to) as! PresentingVC
    let toVC = transitionContext.viewController(forKey: self is CustomPresenterDelegate ? .to : .from) as! PresentedVC
    let isPresenting = self is CustomPresenterDelegate
    
    // Animate Contextual Views before preparation and primary animations if animator is a dismissor.
    // Animate Contextual Views at the end if animator is presenter.
    func animationContextualViewsIfNecessary() {
      
      if let contextualViews = registeredContextualViews?() {
        animateContextualViews(
          isPresenting: isPresenting,
          using: transitionContext,
          contextualViews: contextualViews
        )
        
        // nil registered contextual views once animations are run
        // we do not want to keep references to detail view controller subviews
        registeredContextualViews = nil
      }
    }
    
    if !isPresenting { animationContextualViewsIfNecessary() }
    
    prepareAnimationBlock(using: transitionContext, from: fromVC, to: toVC)
    performAnimations(using: transitionContext, from: fromVC, to: toVC) { [weak self] in
      self?.completeAnimation(using: transitionContext, from: fromVC, to: toVC)
    }
    
    if isPresenting { animationContextualViewsIfNecessary() }
  }
  
  private func animateContextualViews(isPresenting: Bool, using transitionContext: UIViewControllerContextTransitioning, contextualViews: [ContextualViewPair]) {
    
    let startingVC = transitionContext.viewController(forKey: .from)!
    let destinationVC = transitionContext.viewController(forKey: .to)!
    
    let container = transitionContext.containerView
    let canvas = UIView(frame: container.bounds)
    container.addSubview(canvas)
    
    for viewConfig in contextualViews {
      
      let startingView = isPresenting ? viewConfig.fromView : viewConfig.toView
      let destinationView = isPresenting ? viewConfig.toView : viewConfig.fromView
      
      let snapshot = startingView.snapshotView(afterScreenUpdates: isPresenting)!
      let startingFrame = startingVC.view.convert(startingView.frame, to: canvas)
      let startingCenter = startingVC.view.convert(startingView.center, to: canvas)
      
      snapshot.frame = startingFrame
      snapshot.center = startingCenter
      
      canvas.addSubview(snapshot)
      
      startingView.alpha = 0
      destinationView.alpha = 0
      
      UIView.animate(withDuration: self.duration, delay: 0, options: [
        .curveEaseInOut,
        .allowAnimatedContent
        ], animations: {
          
          let frame = destinationVC.view.convert(destinationView.frame, to: canvas)
          let center = destinationVC.view.convert(destinationView.center, to: canvas)
          
          snapshot.frame = frame
          snapshot.center = center
          
      }, completion: {  _ in
        
        destinationView.alpha = 1
        canvas.removeFromSuperview()
      })
    
    }
  }
}
