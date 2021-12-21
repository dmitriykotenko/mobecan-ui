//  Copyright © 2020 Mobecan. All rights reserved.

import RxCocoa
import RxSwift
import SnapKit
import SwiftDateTime
import UIKit


open class ActionsViewSwiper<
  ContentView: DataView & EventfulView,
    SideAction: Hashable
>: ActionsViewIngredientMixer {

  public typealias State = [SideAction]
  public typealias Event = (SideAction, ContentView.Value)
  
  private let possibleButtonsAndActions: [SideAction: UIButton]
  private let buttons: [UIButton]
  private let trailingView: UIView

  private let spacing: CGFloat
  private let animationDuration: Duration

  public init(possibleButtonsAndActions: [SideAction: UIButton],
              trailingView: ([UIButton]) -> UIView,
              spacing: CGFloat = 0,
              animationDuration: Duration) {
    self.possibleButtonsAndActions = possibleButtonsAndActions

    self.buttons = Array(possibleButtonsAndActions.values)
    self.trailingView = trailingView(buttons)
    self.trailingView.setNeedsLayout()
    self.trailingView.layoutIfNeeded()

    self.spacing = spacing
    self.animationDuration = animationDuration
  }

  open func setup(contentView: ContentView,
                  containerView: UIView) -> ActionsViewStructs.Ingredient<ContentView.Value, State, Event> {
    
    let newContainerView = SwipableView(
      contentView: containerView,
      trailingView: trailingView,
      spacing: spacing,
      trailingViewWidth: trailingView.frame.width,
      animationDuration: animationDuration
    )
    .cornerRadius(contentView.layer.cornerRadius)
    .clipsToBounds(true)
    
    let valueSetter = BehaviorSubject<Value?>(value: nil)
    
    let events = Observable.merge(
        possibleButtonsAndActions.map { action, button in button.rx.tap.map { action } }
      )
      .withLatestFrom(valueSetter.filterNil()) { ($0, $1) }
    
    return .init(
      containerView: newContainerView,
      value: valueSetter.asObserver(),
      state: .onNext { [possibleButtonsAndActions, trailingView] actions in
        possibleButtonsAndActions.forEach { action, button in
          button.isVisible = actions.contains(action)
        }

        trailingView.setNeedsLayout()
        trailingView.layoutIfNeeded()

        newContainerView.trailingViewWidth.onNext(trailingView.frame.width)
      },
      events: events
    )
  }
}


private class SwipableView: UIView {

  @RxUiInput(0) var trailingViewWidth: AnyObserver<CGFloat>
  
  private var mainSubviewTrailing: Constraint?
  private var bouncer: Bouncer?
  
  private let disposeBag = DisposeBag()
  
  required init?(coder: NSCoder) { interfaceBuilderNotSupportedError() }

  init(contentView: UIView,
       trailingView: UIView,
       spacing: CGFloat,
       trailingViewWidth: CGFloat,
       animationDuration: Duration) {
    super.init(frame: .zero)

    let mainSubview = TranslationView(
      // trailingView should not overlap contentView if spacing is negative
      .hstackWithReversedZorder(spacing: spacing, [contentView, trailingView])
    )

    addSubview(mainSubview)
    
    mainSubview.snp.makeConstraints {
      $0.top.bottom.leading.equalToSuperview()
      mainSubviewTrailing = $0.trailing.equalToSuperview().inset(trailingViewWidth + spacing).constraint
    }
    
    contentView.snp.makeConstraints {
      $0.width.equalTo(self)
    }

    let bouncer = HorizontalBouncer(
      panContainer: self,
      pan: rx.exclusiveHorizontalPan(),
      animationDuration: animationDuration,
      attractors: [0, trailingViewWidth + spacing]
    )

    Observable
      .combineLatest(bouncer.offset, _trailingViewWidth) { offset, trailingWidth in
        CGPoint(x: offset - trailingWidth - spacing, y: 0)
      }
      .bind(to: mainSubview.translation)
      .disposed(by: disposeBag)
    
    self.bouncer = bouncer
    
    disposeBag {
      _trailingViewWidth
        .map { $0 == 0 ? [0] : [0, $0 + spacing] }
        ==> bouncer.attractors

      _trailingViewWidth
        .map { $0 == 0 ? 0 : $0 + spacing }
        ==> bouncer.attractor
    }

    mainSubviewTrailing.map {
      _trailingViewWidth
        .map { -($0 + spacing) }
        .bind(to: $0.rx.inset)
        .disposed(by: disposeBag)
    }
    
    self.trailingViewWidth.onNext(trailingViewWidth)
  }
}


private extension UIView {

  static func hstackWithReversedZorder(spacing: CGFloat? = nil,
                                       _ subviews: [UIView]) -> UIView {
    let stack = UIStackView(arrangedSubviews: subviews)

    stack.axis = .horizontal
    spacing.map { stack.spacing = $0 }

    stack.isLayoutMarginsRelativeArrangement = true
    stack.insetsLayoutMarginsFromSafeArea = false

    // Reverse Z-order of subviews.
    stack.arrangedSubviews.forEach {
      stack.sendSubviewToBack($0)
    }

    return stack
  }
}
