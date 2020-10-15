//
//  Playlist.h
//  播放音效
//
//  Created by kkkak on 2020/4/13.
//  Copyright © 2020 kkkak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Playlist : NSObject

/**音乐名字**/
@property (nonatomic,copy) NSString *musiclabel;

/**播放路径**/
@property (nonatomic,copy) NSString *musicplay;

/**专辑封面**/
@property (nonatomic,copy) NSString *musicicon;

/**背景图片**/
@property (nonatomic,copy) NSString *musicbgimage;

/**快速创建**/
+ (instancetype)musicWithDict:(NSDictionary *)dict;

@end
