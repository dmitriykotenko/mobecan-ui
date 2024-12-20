// Copyright © 2020 Mobecan. All rights reserved.


import LayoutKit
import UIKit


public extension UIView {
  
  static func hstack<Subviews: Sequence>(alignment: UIStackView.Alignment = .fill,
                                         distribution: UIStackView.Distribution? = nil,
                                         spacing: CGFloat? = nil,
                                         _ subviews: Subviews,
                                         insets: UIEdgeInsets = .zero) -> UIView where Subviews.Element == UIView {
    fastStackView(
      axis: .horizontal,
      alignment: alignment,
      distribution: distribution,
      spacing: spacing,
      subviews: subviews,
      insets: insets
    )
  }
  
  /// Горизонтальный стэк,
  /// у которого `bulletView` вертикально выравнен по первой строке текста лэйбла.
  static func hstack(distribution: UIStackView.Distribution? = nil,
                     alignment: BulletToTextAlignment = .xHeight,
                     spacing: CGFloat? = nil,
                     bulletView: UIView,
                     label: UILabel,
                     insets: UIEdgeInsets = .zero) -> UIView {
    
    let labelHeight = alignment.height(font: label.font)

    let bulletHeight = bulletView.sizeThatFits(CGSize.greatestFinite).height

    let bulletTopOffset = (labelHeight - bulletHeight) / 2

    return .hstack(
      alignment: .top,
      distribution: distribution,
      spacing: spacing,
      [
        bulletView.withInsets(.top(bulletTopOffset)),
        label
      ],
      insets: insets
    )
  }
  
  static func vstack<Subviews: Sequence>(alignment: UIStackView.Alignment = .fill,
                                         distribution: UIStackView.Distribution? = nil,
                                         spacing: CGFloat? = nil,
                                         _ subviews: Subviews,
                                         insets: UIEdgeInsets = .zero) -> UIView where Subviews.Element == UIView {
    fastStackView(
      axis: .vertical,
      alignment: alignment,
      distribution: distribution,
      spacing: spacing,
      subviews: subviews,
      insets: insets
    )
  }
  
  private static func stackView<Subviews: Sequence>(axis: NSLayoutConstraint.Axis,
                                                    alignment: UIStackView.Alignment = .fill,
                                                    distribution: UIStackView.Distribution? = nil,
                                                    spacing: CGFloat? = nil,
                                                    subviews: Subviews,
                                                    insets: UIEdgeInsets = .zero)
    -> UIStackView where Subviews.Element == UIView {
      
      let stack = UIStackView(arrangedSubviews: Array(subviews))

      stack.axis = axis
      stack.alignment = alignment
      distribution.map { stack.distribution = $0 }
      spacing.map { stack.spacing = $0 }
      
      stack.isLayoutMarginsRelativeArrangement = true
      stack.insetsLayoutMarginsFromSafeArea = false
      stack.layoutMargins = insets
      
      return stack
  }

  private static func fastStackView<Subviews: Sequence>(axis: NSLayoutConstraint.Axis,
                                                        alignment: UIStackView.Alignment = .fill,
                                                        distribution: UIStackView.Distribution? = nil,
                                                        spacing: CGFloat? = nil,
                                                        subviews: Subviews,
                                                        intrinsicWidth: CGFloat? = nil,
                                                        intrinsicHeight: CGFloat? = nil,
                                                        insets: UIEdgeInsets = .zero)
  -> StackView where Subviews.Element == UIView {

    let stack = StackView(
      axis: axis.asLayoutKitAxis,
      spacing: spacing ?? 0,
      distribution: distribution?.asLayoutKitDistribution ?? .fillFlexing,
      contentInsets: insets,
      childrenAlignment: alignment.asLayoutKitAlignment(axis: axis.opposite),
      intrinsicWidth: intrinsicWidth,
      intrinsicHeight: intrinsicHeight
    )

    stack.addArrangedSubviews(Array(subviews))

    return stack
  }
}


private extension NSLayoutConstraint.Axis {

  var opposite: NSLayoutConstraint.Axis {
    switch self {
    case .horizontal:
      return .vertical
    case .vertical:
      return .horizontal
    @unknown default:
      fatalError("NSLayoutConstraint.Axis \(self) is not yet supported")
    }
  }
}
