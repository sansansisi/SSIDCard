//
//  UIView+SS.h
//  SSIDCard
//
//  Created by 张家铭 on 2018/5/3.
//

#import <UIKit/UIKit.h>

@interface UIView (SS)

@property (nonatomic) CGFloat ss_left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat ss_top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat ss_right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat ss_bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat ss_width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat ss_height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGFloat ss_centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat ss_centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint ss_origin;      ///< Shortcut for frame.origin.
@property (nonatomic) CGSize  ss_size;        ///< Shortcut for frame.size.

@end
