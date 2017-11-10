import UIKit

public class ModalConfiguration {
  public var verticalOffset: CGFloat = 0
  public var horizontalAlignment: HorizontalAlignment = .centered
  public var verticalAlignment: VerticalAlignment = .centered
  public var fromTop: Bool = true
  public var height: CGFloat = 0
  public var sideOffset: CGFloat = 20
  public var roundedCorners: UIRectCorner = []
  public var roundedCornersRadius: CGFloat = 0
  public init() {
  }
}
