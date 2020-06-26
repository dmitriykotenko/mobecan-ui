//  Copyright © 2019 Mobecan. All rights reserved.


public class NameFormatter: StringFormatter {
  
  public init() {}
  
  public func format(_ string: String) -> String {
    return string.trimmingCharacters(in: .whitespaces)
  }
}


public class PhoneNumberFormatter: StringFormatter {
  
  public init() {}

  public func format(_ string: String) -> String {
    return
      string.prefix(2) + " "
      + string.dropFirst(2).prefix(3) + " "
      + string.dropFirst(5).prefix(3) + "-"
      + string.dropFirst(8).prefix(2) + "-"
      + string.dropFirst(10)
  }
}


public extension StringFormatter {

  static func name() -> StringFormatter {
    return NameFormatter()
  }

  static func phoneNumber() -> StringFormatter {
    return PhoneNumberFormatter()
  }
}
