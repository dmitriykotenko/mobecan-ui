//  Copyright © 2021 Mobecan. All rights reserved.

import LayoutKit
import UIKit


/// Wraps a UIView so that it conforms to Layout protocol.
public struct BoilerplateLayout: ConfigurableLayout {

  public let alignment: Alignment
  public let needsView = true
  public let view: UIView
  public let viewReuseId: String? = nil

  public init(_ view: UIView,
              alignment: Alignment = .center) {
    self.view = view
    self.alignment = alignment
  }

  public func measurement(within maxSize: CGSize) -> LayoutMeasurement {
    .init(
      layout: self,
      size: view.sizeThatFits(maxSize),
      maxSize: maxSize,
      sublayouts: []
    )
  }

  public func arrangement(within rect: CGRect,
                          measurement: LayoutMeasurement) -> LayoutArrangement {
    let actualSize = view.sizeThatFits(rect.size)

    return LayoutArrangement(
      layout: self,
      frame: alignment.position(size: actualSize, in: rect),
      sublayouts: []
    )
  }

  public func makeView() -> UIView { view }

  public func configure(view: UIView) {}

  public var flexibility: Flexibility {
    Flexibility(
      horizontal: flexForAxis(.horizontal),
      vertical: flexForAxis(.vertical)
    )
  }

  private func flexForAxis(_ axis: NSLayoutConstraint.Axis) -> Flexibility.Flex {
    switch view.contentHuggingPriority(for: axis) {
    case .required:
      return nil
    case let priority:
      return -Int32(priority.rawValue)
    }
  }
}


public extension Layout where Self == BoilerplateLayout {

  static func fromView(_ view: UIView,
                       alignment: Alignment = .center) -> BoilerplateLayout {
    BoilerplateLayout(view, alignment: alignment)
  }
}


public extension UIView {

  var asLayout: Layout { .fromView(self) }

  func withAlignment(_ alignment: Alignment) -> Layout {
    .fromView(self, alignment: alignment)
  }
}
