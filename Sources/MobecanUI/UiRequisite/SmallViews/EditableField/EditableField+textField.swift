//  Copyright © 2020 Mobecan. All rights reserved.

import RxCocoa
import RxSwift
import UIKit


public extension EditableField where RawValue == String?, ValidatedValue == String? {
  
  convenience init(textField: UITextField,
                   backgroundView: EditableFieldBackground,
                   initSubviews: @escaping (UIView, EditableFieldBackground) -> EditableFieldSubviews,
                   layout: EditableFieldLayout,
                   validator: ((RawValue) -> Result<ValidatedValue, ValidationError>)? = nil) {
    
    let sampleValidator = { (rawValue: RawValue) -> Result<ValidatedValue, ValidationError> in
      print("Sample validator for text field.")
      return .success(rawValue)
    }
    
    self.init(
      subviews: initSubviews(textField, backgroundView),
      layout: layout,
      rawValueGetter: textField.rx.text.asObservable(),
      rawValueSetter: textField.rx.text.asObserver(),
      validator: validator ?? sampleValidator
    )
  }
}


public extension EditableField where RawValue == String? {
  
  convenience init(textField: UITextField,
                   backgroundView: EditableFieldBackground,
                   initSubviews: @escaping (UIView, EditableFieldBackground) -> EditableFieldSubviews,
                   layout: EditableFieldLayout,
                   validator: @escaping (RawValue) -> Result<ValidatedValue, ValidationError>) {
    
    self.init(
      subviews: initSubviews(textField, backgroundView),
      layout: layout,
      rawValueGetter: textField.rx.text.asObservable(),
      rawValueSetter: textField.rx.text.asObserver(),
      validator: validator
    )
  }
}