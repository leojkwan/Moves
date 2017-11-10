// This protocol decorator informs Moves to reset presenting
// view controller transformations when dismissor is called
public protocol TransformAnimator {}

public protocol ModalAnimator {
  var modalConfig: ModalConfiguration { get set }
  func determineModalOriginPoint(from containerView: UIView)-> CGPoint
}

extension ModalAnimator {
  public func determineModalOriginPoint(from containerView: UIView)-> CGPoint {
    
    let destinationXPoint: CGFloat
    let destinationYPoint: CGFloat
    
    switch modalConfig.horizontalAlignment {
    case .centered:
      destinationXPoint = containerView.frame.midX - modalConfig.width/2
    case .left:
      destinationXPoint = modalConfig.horizontalOffset
    case .right:
      destinationXPoint = (containerView.bounds.width - modalConfig.width) - modalConfig.horizontalOffset
    }
    
    switch modalConfig.verticalAlignment {
    case .centered:
      destinationYPoint = containerView.frame.midY - modalConfig.height/2
    case .top:
      destinationYPoint = modalConfig.verticalOffset
    case .bottom:
      destinationYPoint = (containerView.bounds.height - modalConfig.height) - modalConfig.verticalOffset
    }
    
    
    return CGPoint(
      x: destinationXPoint,
      y: destinationYPoint
    )
  }
}
