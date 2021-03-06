// Copyright 2012 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  AccessibleObject.m
//  JreEmulation
//
//  Created by Tom Ball on 6/18/12.
//

#import "J2ObjC_source.h"
#import "java/lang/AssertionError.h"
#import "java/lang/annotation/Annotation.h"
#import "java/lang/reflect/AccessibleObject.h"
#import "java/lang/reflect/Method.h"
#import "java/lang/reflect/Modifier.h"

@implementation JavaLangReflectAccessibleObject

- (instancetype)init {
  JavaLangReflectAccessibleObject_init(self);
  return self;
}

void JavaLangReflectAccessibleObject_init(JavaLangReflectAccessibleObject *self) {
  NSObject_init(self);
  self->accessible_ = false;
}

- (jboolean)isAccessible {
  return accessible_;
}

- (void)setAccessibleWithBoolean:(jboolean)b {
  accessible_ = b;
}

+ (void)setAccessibleWithJavaLangReflectAccessibleObjectArray:(IOSObjectArray *)objects
                                                  withBoolean:(jboolean)b {
  JavaLangReflectAccessibleObject_setAccessibleWithJavaLangReflectAccessibleObjectArray_withBoolean_(
    objects, b);
}

- (id)getAnnotationWithIOSClass:(IOSClass *)annotationType {
  nil_chk(annotationType);
  IOSObjectArray *annotations = [self getAnnotations];
  jint n = annotations->size_;
  for (jint i = 0; i < n; i++) {
    id annotation = annotations->buffer_[i];
    if ([annotationType isInstance:annotation]) {
      return annotation;
    }
  }
  return nil;
}

- (IOSObjectArray *)getDeclaredAnnotations {
  // can't call an abstract method
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (IOSObjectArray *)getAnnotations {
  // Overridden by ExecutableMember to also return inherited members.
  return [self getDeclaredAnnotations];
}

- (jboolean)isAnnotationPresentWithIOSClass:(IOSClass *)annotationType {
  return [self getAnnotationWithIOSClass:annotationType] != nil;
}

- (IOSObjectArray *)getAnnotationsFromAccessor:(JavaLangReflectMethod *)method {
  if (method) {
    IOSObjectArray *noArgs = [IOSObjectArray arrayWithLength:0 type:NSObject_class_()];
    return (IOSObjectArray *) [method invokeWithId:nil withNSObjectArray:noArgs];
  } else {
    return [IOSObjectArray arrayWithLength:0 type:JavaLangAnnotationAnnotation_class_()];
  }
}

- (NSString *)toGenericString {
  // can't call an abstract method
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

+ (const J2ObjcClassInfo *)__metadata {
  static const J2ObjcMethodInfo methods[] = {
    { "isAccessible", "Z", 0x1, -1, -1, -1, -1, -1, -1 },
    { "setAccessibleWithBoolean:", "V", 0x1, 0, 1, -1, -1, -1, -1 },
    { "setAccessibleWithJavaLangReflectAccessibleObjectArray:withBoolean:", "V", 0x9, 0, 2, -1, -1,
      -1, -1 },
    { "getAnnotationWithIOSClass:", "LJavaLangAnnotationAnnotation;", 0x1, 3, 4, -1, 5, -1, -1 },
    { "isAnnotationPresentWithIOSClass:", "Z", 0x1, 6, 4, -1, 7, -1, -1 },
    { "getAnnotations", "[LJavaLangAnnotationAnnotation;", 0x1, -1, -1, -1, -1, -1, -1 },
    { "getDeclaredAnnotations", "[LJavaLangAnnotationAnnotation;", 0x1, -1, -1, -1, -1, -1, -1 },
    { "init", NULL, 0x1, -1, -1, -1, -1, -1, -1 },
  };
  static const void *ptrTable[] = {
    "setAccessible", "Z", "[LJavaLangReflectAccessibleObject;Z", "getAnnotation", "LIOSClass;",
    "<T::Ljava/lang/annotation/Annotation;>(Ljava/lang/Class<TT;>;)TT;", "isAnnotationPresent",
    "(Ljava/lang/Class<+Ljava/lang/annotation/Annotation;>;)Z" };
  static const J2ObjcClassInfo _JavaLangReflectAccessibleObject = {
    "AccessibleObject", "java.lang.reflect", ptrTable, methods, NULL, 7, 0x1, 8, 0, -1, -1, -1, -1,
    -1 };
  return &_JavaLangReflectAccessibleObject;
}

@end

void JavaLangReflectAccessibleObject_setAccessibleWithJavaLangReflectAccessibleObjectArray_withBoolean_(
    IOSObjectArray *objects, jboolean b) {
  for (JavaLangReflectAccessibleObject *o in objects) {
    [o setAccessibleWithBoolean:b];
  }
}

// TODO(tball): is there a reasonable way to make these methods table-driven?

// Return a Obj-C type encoding as a Java type or wrapper type.
IOSClass *decodeTypeEncoding(const char *type) {
  if (strlen(type) > 3 && type[0] == '@') {
    // Format is either '@"type-name"' for classes, or '@"<type-name>"' for protocols.
    char *typeNameAsC = type[2] == '<'
        ? strndup(type + 3, strlen(type) - 5) : strndup(type + 2, strlen(type) - 3);
    NSString *typeName = [NSString stringWithUTF8String:typeNameAsC];
    free(typeNameAsC);
    return [IOSClass forName:typeName];
  }
  switch (type[0]) {
    case '@':
      return NSObject_class_();
    case '#':
      return IOSClass_class_();
    case 'c':
      return [IOSClass byteClass];
    case 'S':
      return [IOSClass charClass];
    case 's':
      return [IOSClass shortClass];
    case 'i':
      return [IOSClass intClass];
    case 'l':
    case 'L':
    case 'q':
    case 'Q':
      return [IOSClass longClass];
    case 'f':
      return [IOSClass floatClass];
    case 'd':
      return [IOSClass doubleClass];
    case 'B':
      return [IOSClass booleanClass];
    case 'v':
      return [IOSClass voidClass];
  }
  NSString *errorMsg =
  [NSString stringWithFormat:@"unknown Java type encoding: '%s'", type];
  @throw AUTORELEASE([[JavaLangAssertionError alloc] initWithId:errorMsg]);
}

// Return a description of an Obj-C type encoding.
NSString *describeTypeEncoding(NSString *type) {
  if ([type length] == 1) {
    unichar typeChar = [type characterAtIndex:0];
    switch (typeChar) {
      case '@':
        return @"Object";
      case '#':
        return @"Class";
      case 'c':
        return @"byte";
      case 'S':
        // A Java character is an unsigned two-byte int; in other words,
        // an unsigned short with an encoding of 'S'.
        return @"char";
      case 's':
        return @"short";
      case 'i':
        return @"int";
      case 'q':
      case 'Q':
        return @"long";
      case 'f':
        return @"float";
      case 'd':
        return @"double";
      case 'B':
        return @"jbooleanean";
      case 'v':
        return @"void";
    }
  }
  return [NSString stringWithFormat:@"unknown type encoding: %@", type];
}

J2OBJC_CLASS_TYPE_LITERAL_SOURCE(JavaLangReflectAccessibleObject)
