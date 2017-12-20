import Foundation

/*
 * This animated transitioning object slides modal DOWN under a screen's view.
 */
public class FadeOutOverContextAnimator<PresentingVC: UIViewController, PresentedVC: UIViewController>: Animator<PresentingVC, PresentedVC> {
  
  public override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }
  
  public required init(duration: Double) {
    super.init(isPresenter: false, duration: duration)
  }
  
  open override func performAnimations(using transitionContext: UIViewControllerContextTransitioning, from presentingVC: PresentingVC, to presentedVC: PresentedVC, completion: @escaping () -> ()) {
    super.performAnimations(using: transitionContext, from: presentingVC, to: presentedVC, completion: completion)
    

    let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
    
    UIView.animate(withDuration: duration, animations: {
      fromView.alpha = 0
    }) { _ in
      
      // must call this to proceed to completing view controller transition.
      completion()
    }
  }
}

