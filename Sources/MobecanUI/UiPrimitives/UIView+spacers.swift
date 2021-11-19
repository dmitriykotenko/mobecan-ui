//  Copyright © 2020 Mobecan. All rights reserved.

import LayoutKit
import SnapKit
import UIKit
import SwiftUI


public extension UIView {
  
  static func zeroHeightView(layoutPriority: ConstraintPriority = .required) -> LayoutableView {
    LayoutableView(
      layout: SizeLayout(height: 0)
    )
  }

  static func spacer(width: CGFloat? = nil,
                     height: CGFloat? = nil,
                     layoutPriority: ConstraintPriority = .required) -> LayoutableView {
    LayoutableView(
      layout: SizeLayout(
        minWidth: width,
        maxWidth: width,
        minHeight: height,
        maxHeight: height
      )
    )
  }

  static func stretchableHorizontalSpacer(minimumWidth: CGFloat = 0,
                                          minimumHeight: CGFloat = 0) -> LayoutableView {
    .init(
      layout: StretchableSpacerLayout(
        minimumWidth: minimumWidth,
        minimumHeight: minimumHeight,
        stretchableAxis: [.horizontal]
      )
    )
  }

  static func stretchableVerticalSpacer(minimumWidth: CGFloat = 0,
                                        minimumHeight: CGFloat = 0) -> LayoutableView {
    .init(
      layout: StretchableSpacerLayout(
        minimumWidth: minimumWidth,
        minimumHeight: minimumHeight,
        stretchableAxis: [.vertical]
      )
    )
  }

  static func stretchableSpacer(minimumWidth: CGFloat = 0,
                                minimumHeight: CGFloat = 0) -> LayoutableView {
    .init(
      layout: StretchableSpacerLayout(
        minimumWidth: minimumWidth,
        minimumHeight: minimumHeight,
        stretchableAxis: [.horizontal, .vertical]
      )
    )
  }

  static func rxHorizontalSpacer(_ targetView: UIView,
                                 insets: UIEdgeInsets = .zero) -> UIView {
    ReactiveSpacerView(
      targetView: targetView,
      axis: [.horizontal],
      insets: insets
    )
  }
  
  static func rxVerticalSpacer(_ targetView: UIView,
                               insets: UIEdgeInsets = .zero) -> UIView {
    ReactiveSpacerView(
      targetView: targetView,
      axis: [.vertical],
      insets: insets
    )
  }
  
  static func rxSpacer(_ targetView: UIView,
                       insets: UIEdgeInsets = .zero) -> UIView {
    ReactiveSpacerView(
      targetView: targetView,
      axis: [.horizontal, .vertical],
      insets: insets
    )
  }
}


private class StretchableSpacerLayout: BaseLayout<UIView>, Layout {

  let minimumWidth: CGFloat
  let minimumHeight: CGFloat
  let stretchableAxis: [LayoutKit.Axis]

  init(minimumWidth: CGFloat = 0,
       minimumHeight: CGFloat = 0,
       stretchableAxis: [LayoutKit.Axis]) {
    self.minimumWidth = minimumWidth
    self.minimumHeight = minimumHeight
    self.stretchableAxis = stretchableAxis

    super.init(
      alignment: .fill,
      flexibility: .flexible,
      config: nil
    )
  }

  func configure(baseTypeView: UIView) {}

  func measurement(within maxSize: CGSize) -> LayoutMeasurement {
    .init(
      layout: self,
      size: sizeThatFits(maxSize),
      maxSize: maxSize,
      sublayouts: []
    )
  }

  func arrangement(within rect: CGRect,
                   measurement: LayoutMeasurement) -> LayoutArrangement {
    .init(
      layout: self,
      frame: .init(
        origin: rect.origin,
        size: measurement.size
      ),
      sublayouts: []
    )
  }

  private func sizeThatFits(_ maxSize: CGSize) -> CGSize {
    .init(
      width: stretchableAxis.contains(.horizontal) ? max(maxSize.width, minimumWidth) : 0,
      height: stretchableAxis.contains(.vertical) ? max(maxSize.height, minimumHeight) : 0
    )
  }
}
