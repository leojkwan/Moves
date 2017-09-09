import Foundation
import UIKit


open class Animator<PresentingViewController: UIViewController, PresentedViewController: UIViewController>: NSObject, CustomPresenterDelegate, UIViewControllerAnimatedTransitioning {
  
  public let duration: Double
  public var registeredContextualViews: (() -> ([ContextualViewPair]))?
  
  public init(duration: Double) {
    self.duration = duration
  }
  
  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }
  
  open func prepareAnimationBlock(using transitionContext: UIViewControllerContextTransitioning, from presentingVC: UIViewController, to presentedVC: UIViewController) {
  }
  
  open func performAnimations(using transitionContext: UIViewControllerContextTransitioning, from presentingVC: UIViewController, to presentedVC: UIViewController, completion: @escaping ()-> ()) {
    completion()
  }
  
  open func completeAnimation(using transitionContext: UIViewControllerContextTransitioning, from presentingVC: UIViewController, to presentedVC: UIViewController) {
    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
  }
  
  open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    let fromVC = transitionContext.viewController(forKey: .from) as! PresentingViewController
    let toVC = transitionContext.viewController(forKey: .to) as! PresentedViewController
    print(toVC)
    
    prepareAnimationBlock(using: transitionContext, from: fromVC, to: toVC)
    performAnimations(using: transitionContext, from: fromVC, to: toVC) {
      self.completeAnimation(using: transitionContext, from: fromVC, to: toVC)
    }
    
    // animate registered contextual views
    if let contextualViews = registeredContextualViews?() {
      animateContextualViews(
        using: transitionContext,
        contextualViews: contextualViews,
        from: fromVC,
        to: toVC,
        duration: duration
      )
    }
  }
 
  public func animateContextualViews(using transitionContext: UIViewControllerContextTransitioning, contextualViews: [ContextualViewPair], from presentingVC: UIViewController, to presentedVC: UIViewController, duration: Double) {
    
    let container = transitionContext.containerView
    let canvas = UIView(frame: container.bounds)
    container.addSubview(canvas)
    
    
    for viewConfig in contextualViews {
      
//      let masterView = viewConfig.fromView
//      let detailView = viewConfig.toView
      
      let masterView = viewConfig.toView
      let detailView = viewConfig.fromView
      
      let snapshot = masterView.snapshotView(afterScreenUpdates: true)!
      snapshot.frame = masterView.frame
      canvas.addSubview(snapshot)
      
      masterView.alpha = 0
      detailView.alpha = 0
      
      UIView.animateKeyframes(
        withDuration: duration,
        delay: 0,
        options: UIViewKeyframeAnimationOptions.calculationModeLinear,
        animations: {
          UIView.addKeyframe(
            withRelativeStartTime: 0,
            relativeDuration: duration) {
                
                let frame = presentedVC.view.convert(detailView.frame, to: canvas)
                let center = presentedVC.view.convert(detailView.center, to: canvas)
                snapshot.frame = frame
                snapshot.center = center
          }
          
      }) { _ in
        
        masterView.alpha = 1
        detailView.alpha = 1
        canvas.removeFromSuperview()
      }
    }
  }
  
}

