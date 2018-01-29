import Foundation

public struct DimOverlayConfiguration {
  public static func defaultConfig() -> DimOverlayConfiguration {
    return DimOverlayConfiguration(
      showBackgroundDimView: true,
      dismissDimViewOnTap: true,
      dimAnimationDuration: 0.5
    )
  }
  
  public let showBackgroundDimView: Bool
  public let dismissDimViewOnTap: Bool
  public let dimAnimationDuration: CGFloat
  
  public init(
    showBackgroundDimView: Bool,
    dismissDimViewOnTap: Bool,
    dimAnimationDuration: CGFloat
    ) {
    self.showBackgroundDimView = showBackgroundDimView
    self.dismissDimViewOnTap = dismissDimViewOnTap
    self.dimAnimationDuration = dimAnimationDuration
  }
}

public struct MovesConfiguration {
  public static func defaultConfig() -> MovesConfiguration {
    return MovesConfiguration(
      showBackgroundDimView: true,
      dismissDimViewOnTap: true,
      pannable: false
    )
  }
  
  public var showBackgroundDimView: Bool
  public var dismissDimViewOnTap: Bool
  public var pannable: Bool
  public var unwindContextualViewsOnDismiss: Bool
  
  public init(
    showBackgroundDimView: Bool,
    dismissDimViewOnTap: Bool,
    pannable: Bool,
    unwindContextualViewsOnDismiss: Bool = true
    ) {
    self.showBackgroundDimView = showBackgroundDimView
    self.dismissDimViewOnTap = dismissDimViewOnTap
    self.pannable = pannable
    self.unwindContextualViewsOnDismiss = unwindContextualViewsOnDismiss
  }
}
