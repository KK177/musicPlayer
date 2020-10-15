//
//  Playlist.m
//  播放音效
//
//  Created by kkkak on 2020/4/13.
//  Copyright © 2020 kkkak. All rights reserved.
//

#import "Playlist.h"

@implementation Playlist
+ (instancetype)musicWithDict:(NSDictionary *)dict
{
    Playlist *music = [[self alloc] init];
    [music setValuesForKeysWithDictionary:dict];
    return music;
}
@end
