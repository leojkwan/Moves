import Foundation

/*
 * This animated transitioning object slides modal DOWN under a screen's view.
 */
public class SlideOutOverContextAnimator<PresentingVC: UIViewController, PresentedVC: UIViewController>: Animator<PresentingVC, PresentedVC> {
  
  fileprivate var slidingTo: Direction

  public override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }
  
  public required init(slidingTo: Direction, duration: Double) {
    self.slidingTo = slidingTo
    super.init(isPresenter: false, duration: duration)
  }
  
  open override func performAnimations(using transitionContext: UIViewControllerContextTransitioning, from presentingVC: PresentingVC, to presentedVC: PresentedVC, completion: @escaping () -> ()) {
    super.performAnimations(using: transitionContext, from: presentingVC, to: presentedVC, completion: completion)
    
    // Setup the transition
    let containerView = transitionContext.containerView
    let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
    
    UIView.animateKeyframes(
      withDuration: self.duration,
      delay: 0.0,
      options: UIView.KeyframeAnimationOptions(),
      animations: {
        
        // Slide view out
        switch self.slidingTo {
        case .up:
          fromView.frame.origin.y -= containerView.frame.height
        case .down:
          fromView.frame.origin.y += containerView.frame.height
        case .left:
          fromView.frame.origin.x -= containerView.frame.width
        case .right:
          fromView.frame.origin.x += containerView.frame.width
        }
                
    } , completion: { _ in
      
      // must call this to proceed to completing
      // view controller transition.
      completion()
      
    })
  }
}
