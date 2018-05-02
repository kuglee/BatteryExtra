//
//  Swizzle.swift
//  Swizzle
//
//  Created by Yasuhiro Inami on 2014/09/14.
//  Copyright (c) 2014年 Yasuhiro Inami. All rights reserved.
//

import ObjectiveC

enum SwizzleError: Error {
  case methodNotFound(errorMessage: String)
  case classNotFound(errorMessage: String)
}

private func _swizzleMethod(of class_: AnyClass, from selector1: Selector, to selector2: Selector, isClassMethod: Bool) throws {
  let c: AnyClass
  if isClassMethod {
    c = object_getClass(class_)!
  }
  else {
    c = class_
  }

  guard let method1: Method = class_getInstanceMethod(c, selector1) else {
    throw SwizzleError.methodNotFound(errorMessage: "Could not swizzle method \"\(selector2.description)\" in class \"\(class_.description())\"! The swizzling method \"\(selector1.description)\" could not be found!")
  }
  guard let method2: Method = class_getInstanceMethod(c, selector2) else {
    throw SwizzleError.methodNotFound(errorMessage: "Could not swizzle method \"\(selector2.description)\" in class \"\(class_.description())\"! The swizzled method \"\(selector2.description)\" could not be found!")
  }

  if class_addMethod(c, selector1, method_getImplementation(method2), method_getTypeEncoding(method2)) {
    class_replaceMethod(c, selector2, method_getImplementation(method1), method_getTypeEncoding(method1))
  }
  else {
    method_exchangeImplementations(method1, method2)
  }
}

/// Instance-method swizzling.
public func swizzleInstanceMethod(of class_: AnyClass, from sel1: Selector, to sel2: Selector) throws {
  try _swizzleMethod(of: class_, from: sel1, to: sel2, isClassMethod: false)
}

/// Instance-method swizzling for unsafe raw-string.
/// - Note: This is useful for non-`#selector`able methods e.g. `dealloc`, private ObjC methods.
public func swizzleInstanceMethodString(of class_: AnyClass, from sel1: String, to sel2: String) throws {
  try swizzleInstanceMethod(of: class_, from: Selector(sel1), to: Selector(sel2))
}

public func swizzleInstanceMethodObjcString(of class_: AnyClass, from sel1: Selector, to sel2: String) throws {
  try _swizzleMethod(of: class_, from: sel1, to: Selector(sel2), isClassMethod: false)
}

/// Class-method swizzling.
public func swizzleClassMethod(of class_: AnyClass, from sel1: Selector, to sel2: Selector) throws {
  try _swizzleMethod(of: class_, from: sel1, to: sel2, isClassMethod: true)
}

/// Class-method swizzling for unsafe raw-string.
public func swizzleClassMethodString(of class_: AnyClass, from sel1: String, to sel2: String) throws {
  try swizzleClassMethod(of: class_, from: Selector(sel1), to: Selector(sel2))
}

public func swizzleClassMethodOjbcString(of class_: AnyClass, from sel1: Selector, to sel2: String) throws {
  try swizzleClassMethod(of: class_, from: sel1, to: Selector(sel2))
}
