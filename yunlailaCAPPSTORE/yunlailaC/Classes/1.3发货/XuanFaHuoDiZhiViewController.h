//
//  XuanFaHuoDiZhiViewController.h
//  yunlailaC
//
//  Created by admin on 17/1/17.
//  Copyright © 2017年 com.yunlaila. All rights reserved.
//

#import "YLLBaseViewController.h"
@protocol XuanFaHuoDiZhiViewControllerDelegate <NSObject>
@optional
- (void)sendformattedAddress:(NSString *)formattedAddress AndCoordinate:(CLLocationCoordinate2D)coordinate;
@end

@interface XuanFaHuoDiZhiViewController : YLLBaseViewController
@property (nonatomic, assign) id<XuanFaHuoDiZhiViewControllerDelegate> mydelegate;
@end
