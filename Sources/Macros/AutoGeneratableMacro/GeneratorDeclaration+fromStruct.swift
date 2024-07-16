// Copyright © 2024 Mobecan. All rights reserved.

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


extension GeneratorDeclaration {

  static func from(someStruct: Struct) -> Self {
    someStruct.storedProperties.isEmpty ?
      from(emptyStruct: someStruct) :
      from(
        product: someStruct.asProductType,
        className: "BuiltinGenerator",
        parentClassName: "MobecanGenerator",
        genericArgumentsCondition:
          someStruct.genericArgumentsConformanceRequirement(protocolName: "AutoGeneratable")
      )
  }

  private static func from(emptyStruct: Struct) -> Self {
    .init(
      className: "BuiltinGenerator",
      inheritedClassName: "MobecanGenerator",
      valueType: emptyStruct.name,
      genericArgumentsCondition:
        emptyStruct.genericArgumentsConformanceRequirement(protocolName: "AutoGeneratable"),
      initializerParameters: nil,
      bodyOfGenerateMethod: ".just(.success(\(emptyStruct.name)()))"
    )
  }
}
