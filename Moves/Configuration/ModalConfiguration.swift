import UIKit

public class ModalConfiguration {
  
  // No effect if vertical alignment is `centered`
  public var verticalOffset: CGFloat = 0
  
  // No effect if horizontalAlignment is `centered`
  public var horizontalOffset: CGFloat = 0
  
  public var horizontalAlignment: HorizontalAlignment = .centered
  public var verticalAlignment: VerticalAlignment = .centered
  public var fromTop: Bool = true
  public var height: CGFloat = 0
  public var width: CGFloat = 0
  public var roundedCorners: UIRectCorner = []
  public var roundedCornersRadius: CGFloat = 0
  public init() {
  }
}
