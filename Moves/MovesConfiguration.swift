import Foundation

public struct MovesConfiguration {
  public static func defaultConfig() -> MovesConfiguration {
    return MovesConfiguration(
      showBackgroundDimView: true,
      dismissDimViewOnTap: true,
      presentedVCIsPannable: true,
      panOptions: PannableMoveOptions.defaultOptions()
    )
  }
  
  public let showBackgroundDimView: Bool
  public let dismissDimViewOnTap: Bool
  public let presentedVCIsPannable: Bool
  public let panOptions: PannableMoveOptions
  public let unwindContextualViewsOnDismiss: Bool
  
  public init(
    showBackgroundDimView: Bool,
    dismissDimViewOnTap: Bool,
    presentedVCIsPannable: Bool,
    panOptions: PannableMoveOptions,
    unwindContextualViewsOnDismiss: Bool = true
    ) {
    self.showBackgroundDimView = showBackgroundDimView
    self.dismissDimViewOnTap = dismissDimViewOnTap
    self.presentedVCIsPannable = presentedVCIsPannable
    self.panOptions = panOptions
    self.unwindContextualViewsOnDismiss = unwindContextualViewsOnDismiss
  }
}
