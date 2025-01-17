//
//  UIColor+Utility.h
//  QunariPhone
//
//  Created by Neo on 11/12/12.
//  Copyright (c) 2012 姜琢. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 * UIColor扩展类
 */
@interface UIColor (Utility)
// 十六进制数据转换为颜色
+ (UIColor *)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHexString:(NSString *)color;

//从十六进制字符串获取颜色，
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;
@end
