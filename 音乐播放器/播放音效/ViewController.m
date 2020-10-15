//
//  ViewController.m
//  播放音效
//
//  Created by kkkak on 2020/3/31.
//  Copyright © 2020 kkkak. All rights reserved.
//



#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPVolumeView.h>
#import "RootViewController.h"
#import "Playlist.h"
#import "CollectViewController.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kControlBarCenterX self.view.center.x
#define kControlBarCenterY (kScreenHeight - 150)

@interface ViewController ()<UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *bgimageView;
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,retain) UIImageView *myImageView;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) NSTimer *imgTimer;
@property (nonatomic,assign) BOOL isPlay ;
@property (nonatomic,assign) BOOL isCollect ;
@property (nonatomic, retain) UIButton *playButton;
@property (nonatomic, retain) UIButton *collectButton;
@property (nonatomic, retain) UILabel *musicNamelabel;
@property (nonatomic, retain) UISlider *slider;
@property (nonatomic, retain) UILabel *currentTimeLable;
@property (nonatomic, retain) UILabel *timeLable;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, strong) NSArray *musicArray;


@end
//接受播放歌曲的下标//
extern int passindex;
//接受播放列表的歌曲总数目//
extern int playcount;
//接受收藏列表的歌曲总数目//
extern int collectcount;
//接受歌曲路径//
extern NSString *musicPlay;
//接受歌名//
extern NSString *musicLabel;
//接受专辑封面//
extern NSString *musicIcon;
//设置一个全局变量来跟踪歌单
static NSInteger currentIndex;
//接受背景图片//
extern NSString *musicbgimage;
//接受判断来自哪个列表的歌曲//
extern BOOL iscollectplist;

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //保存要播放歌曲的下标//
    currentIndex = passindex;
    //用isPlay来判断播放暂停
    self.isPlay = NO;
    //用isCollect来判断是否收藏
    self.isCollect = NO;
    //初始化背景图片
    self.bgimageView.image = [UIImage imageNamed:musicbgimage];
    //1.加毛玻璃
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    //2.设置frame
    toolbar.frame = self.bgimageView.bounds;
    //3.设置样式和透明度
    toolbar.barStyle = UIBarStyleBlack;
    toolbar.alpha = 0.98;
    //4.加到背景图片上
    [self.bgimageView addSubview:toolbar];
    
    //创建一个播放器
    //musicPlay是tableViewCell点击时传进来的//
    NSString *path = [[NSBundle mainBundle]pathForResource:musicPlay ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
    self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    
    
    //创建ScrollView
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 250)];
    //contentSize代表滚动的范围（就是因为这个属性，才能让内容视图有超过自身大小范围的能力）
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds));
    
    //隐藏滚动进度条
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    
    //设置myImageView设置成圆形
    CGFloat size_width = CGRectGetWidth(self.view.bounds) -100;
    self.myImageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 100, size_width, size_width)];
    //设置圆的相关属性（半径，边框颜色，边框宽）
    self.myImageView.layer.cornerRadius = size_width / 2;
    self.myImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.myImageView.layer.borderWidth = 2;
    //裁剪多余的部分
    self.myImageView.layer.masksToBounds = YES;
    //musicIcon是tableViewCell点击时传进来的//
    self.myImageView.image = [UIImage imageNamed:musicIcon];
    [self.scrollView addSubview:self.myImageView];
    
    //设置声音slider
    UISlider *volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 100, 20)];
    volumeSlider.center = CGPointMake(kControlBarCenterX, kControlBarCenterY -20);
    volumeSlider.maximumValue = 1;
    volumeSlider.value = 0.3;
    volumeSlider.minimumTrackTintColor = [UIColor greenColor];
    [volumeSlider addTarget:self action:@selector(handleVolumeAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:volumeSlider];
    
    // 播放的button
    self.playButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.playButton.frame = CGRectMake(120,550,52,55);
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(playorpause:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton];
    
    //收藏的button
    self.collectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.collectButton.frame = CGRectMake(300, 550, 52, 55);
    [self.collectButton setBackgroundImage:[UIImage imageNamed:@"未收藏"] forState:UIControlStateNormal];
    [self.collectButton addTarget:self action:@selector(clickcollect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.collectButton];
    
    //加载list.plist里面的歌曲//
    NSArray *dictArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"list.plist" ofType:nil]];
    NSMutableArray *temp =[NSMutableArray array];
    for(NSDictionary *musicDict in dictArray){
        [temp addObject:[Playlist musicWithDict:musicDict]];
    }
    _musicArray = temp;
    
    //设置显示歌名的label
    self.musicNamelabel = [[UILabel alloc] init];
    self.musicNamelabel.frame = CGRectMake(119, 429, 127, 54);
    self.musicNamelabel.textColor = [UIColor greenColor];
    self.musicNamelabel.textAlignment = NSTextAlignmentCenter;
    self.musicNamelabel.font = [UIFont systemFontOfSize:22.0f];
    self.musicNamelabel.numberOfLines = 0;
    //musicLabel是tableViewCell点击时传进来的//
    self.musicNamelabel.text = musicLabel;
    [self.view addSubview:self.musicNamelabel];
    
    // 计时器 控制播放（作用于播放时间的改变和slider的跟随时间的滑动）
    //使用定时器方法：每间隔一秒响应playerAction方法（因为进度条时间是按每秒变化的）
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(playerAction) userInfo:nil repeats:YES];
    
    // 进度条
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 100, 20)];
    self.slider.center = CGPointMake(kControlBarCenterX, kControlBarCenterY + 10);
    self.slider.minimumTrackTintColor = [UIColor blueColor];
    self.slider.minimumValue = 0.0;
    self.slider.maximumValue = 1.0;
    //5.监听slider变化状态；（value值变化）（最主要的作用是：监听滑块的拖动）（与滑块自动滑不相关，因为value的值已经在定时器作用下会自动改变值）
    //5.1（UIControlEventValueChanged）这个事件的响应比价特殊，其实跟点击按钮效果一样，点击了就会响应
    [self.slider addTarget:self action:@selector(progressAction:) forControlEvents:UIControlEventValueChanged];
    //6.将滑动条加入到控制器上
    [self.view addSubview:self.slider];
    
    //当前播放时间label/总时间label
    //1.设置frame
    self.currentTimeLable = [[UILabel alloc] initWithFrame:CGRectMake(self.slider.frame.origin.x - 43, self.slider.frame.origin.y, 50, 20)];
    //2.文本内容
    self.currentTimeLable.text = @"00:00";
    //3.字体大小,颜色
    self.currentTimeLable.font = [UIFont systemFontOfSize:13];
    self.currentTimeLable.textColor = [UIColor greenColor];
    //4.加入到控制器中
    [self.view addSubview:self.currentTimeLable];
    //总时间label
    self.timeLable = [[UILabel alloc] initWithFrame:CGRectMake(self.slider.frame.origin.x + self.slider.frame.size.width, self.slider.frame.origin.y, 50, 20)];
    self.timeLable.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:self.timeLable];
    self.timeLable.text = @"10:00";
    self.timeLable.textColor = [UIColor greenColor];
    
    //界面初始化时先判断该歌曲是否被收藏
    //先判断该歌曲是来自收藏列表还是播放列表//
    if(iscollectplist){
        [self.collectButton setBackgroundImage:[UIImage imageNamed:@"已收藏"] forState:UIControlStateNormal];
        self.isCollect = YES;
    }else{
        //1。首先拿到正要播放的歌曲
        Playlist *model = self.musicArray[currentIndex];
        NSString *label = model.musiclabel;
        //2.拿到collect.plist文件里面的歌单
        NSString *collectpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
        NSString *filepath = [collectpath stringByAppendingPathComponent:@"collect.plist"];
        NSArray *collectArray = [[NSArray alloc] initWithContentsOfFile:filepath];
        //3.拿界面初始化的歌单跟收藏列表里面的歌对比，看是否已经被收藏
        for(NSDictionary *dict in collectArray){
            if([label isEqual: dict[@"musiclabel"]]){
                [self.collectButton setBackgroundImage:[UIImage imageNamed:@"已收藏"] forState:UIControlStateNormal];
                self.isCollect = YES;
                break;
            }else{
                continue;
            }
        }
    }
}
//如果离开播放界面时还在播歌，把player停了
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.player pause];
}

#pragma mark - 该变音量
-(void)handleVolumeAction:(UISlider *)sender {
    [self.player setVolume:sender.value];
}

#pragma mark - 切换歌曲到上一首
- (IBAction)playpremusic:(UIButton *)button {
    //歌曲名称
    NSString *musicName = nil;
    NSString *iconName = nil;
    NSString *bgName = nil;
    NSString *label = nil;
    UIImage *image = nil;
    //iscollectplist是用来判断歌曲来自哪个歌单的//
    if(iscollectplist){
        if(currentIndex == 0){
            currentIndex = collectcount -1;
        }else{
            currentIndex--;
        }
        //获取沙盒文件里面的collect.plist路径
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
        NSString *filepath = [path stringByAppendingPathComponent:@"collect.plist"];
        //获取collect.plist文件里面原有的数据
        NSMutableArray *dataArray = [[NSMutableArray alloc] initWithContentsOfFile:filepath];
        NSDictionary *model = dataArray[currentIndex];
        musicName = model[@"musicplay"];
        iconName = model[@"musicicon"];
        bgName = model[@"musicbgimage"];
        label = model[@"musiclabel"];
    }else{
            if(currentIndex == 0){
                currentIndex = playcount- 1;
            }
            else{
                currentIndex--;
            }
        //musicArray是播放列表的歌单已经在viewDidLoad里面初始过了//
        Playlist *model = self.musicArray[currentIndex];
        musicName =model.musicplay;
        iconName =model.musicicon;
        bgName = model.musicbgimage;
        label = model.musiclabel;
    }
    
    image = [UIImage imageNamed:iconName];
    self.musicNamelabel.text = label;
    self.myImageView.image = image;
    self.bgimageView.image= [UIImage imageNamed:bgName];
    NSURL *url = [[NSBundle mainBundle] URLForResource:musicName withExtension:nil];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    //重新改变收藏状态//
    //收藏列表和播放列表区分开//
    if(iscollectplist){
       [self.collectButton setBackgroundImage:[UIImage imageNamed:@"已收藏"] forState:UIControlStateNormal];
    }else{
        BOOL flag = [self collectChange];
        if(flag){
            [self.collectButton setBackgroundImage:[UIImage imageNamed:@"已收藏"] forState:UIControlStateNormal];
        }else{
            [self.collectButton setBackgroundImage:[UIImage imageNamed:@"未收藏"] forState:UIControlStateNormal];
        }
    }
}
#pragma mark - 切换歌曲到下一首
- (IBAction)playnextmusic:(UIButton *)button {
    NSString *musicName = nil;
    NSString *iconName = nil;
    NSString *bgName = nil;
    NSString *label = nil;
    UIImage *image = nil;
    //iscollectplist用来判断当前的歌单//
    if(iscollectplist){
        if(currentIndex == collectcount-1){
            currentIndex = 0;
        }else{
            currentIndex++;
        }
        //collect.plist是保存收藏列表的歌单//
        //获取沙盒文件里面的collect.plist路径
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
        NSString *filepath = [path stringByAppendingPathComponent:@"collect.plist"];
        //获取collect.plist文件里面原有的数据
        NSMutableArray *dataArray = [[NSMutableArray alloc] initWithContentsOfFile:filepath];
        NSDictionary *model = dataArray[currentIndex];
        musicName = model[@"musicplay"];
        iconName = model[@"musicicon"];
        bgName = model[@"musicbgimage"];
        label = model[@"musiclabel"];
    }else{
        if(currentIndex == playcount-1){
        currentIndex = 0;
        }else{
        currentIndex++;
        }
    //musicArray是保存播放列表的歌单，在viewDIdLoad的时候已经初始过//
    Playlist *model = self.musicArray[currentIndex];
    musicName =model.musicplay;
    iconName =model.musicicon;
    bgName = model.musicbgimage;
    label = model.musiclabel;
    }
    image = [UIImage imageNamed:iconName];
    self.bgimageView.image = [UIImage imageNamed:bgName];
    self.musicNamelabel.text = label;
    self.myImageView.image = image;
    NSURL *url = [[NSBundle mainBundle] URLForResource:musicName withExtension:nil];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    //重新改变收藏状态//
    //收藏列表和播放列表区分开//
    if(iscollectplist){
        [self.collectButton setBackgroundImage:[UIImage imageNamed:@"已收藏"] forState:UIControlStateNormal];
    }else{
        BOOL flag = [self collectChange];
        if(flag){
            [self.collectButton setBackgroundImage:[UIImage imageNamed:@"已收藏"] forState:UIControlStateNormal];
        }else{
            [self.collectButton setBackgroundImage:[UIImage imageNamed:@"未收藏"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - 播放或者暂停
- (void)playorpause:(UIButton *)button {
    self.isPlay = !self.isPlay;
    if(self.isPlay){
        [button setBackgroundImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
        [self.player play];
        //    控制转动图片
        self.imgTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(imgTransform) userInfo:nil repeats:YES];
    }
    else{
        [button setBackgroundImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
        [self.player pause];
        //停止转动
        [self.imgTimer setFireDate:[NSDate distantFuture]];
    }
}
#pragma mark - 添加歌曲到收藏列表
- (void)clickcollect:(UIButton *)button {
    self.isCollect = !self.isCollect;
    //获取沙盒文件里面的collect.plist路径
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
    NSString *filepath = [path stringByAppendingPathComponent:@"collect.plist"];
    NSMutableArray *dataArray = [NSMutableArray array];
    if ([NSMutableArray arrayWithContentsOfFile:filepath]==nil) {
        NSArray *kArr = [NSArray array];
        BOOL ret = [kArr writeToFile:filepath atomically:YES];
        if (ret) {
            //获取collect.plist文件里面原有的数据
            dataArray = [NSMutableArray arrayWithContentsOfFile:filepath];
        }
        else
        {
            NSLog(@"创建collect.plist失败了");
        }
        
    }
    else{
        //获取collect.plist文件里面原有的数据
        dataArray = [NSMutableArray arrayWithContentsOfFile:filepath];
    }
    if(self.isCollect){
        //拿到正在播放的歌曲
        Playlist *model = self.musicArray[currentIndex];
        NSString *musiclabel = model.musiclabel;
        NSString *musicicon = model.musicicon;
        NSString *musicplay = model.musicplay;
        NSString *musicbgimage = model.musicbgimage;
        //设置要加入列表的数据（把字典添加到数组里面)
        NSMutableArray *collectArray = [[NSMutableArray alloc] init];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:musiclabel forKey:@"musiclabel"];
        [dict setObject:musicicon forKey:@"musicicon"];
        [dict setObject:musicplay forKey:@"musicplay"];
        [dict setObject:musicbgimage forKey:@"musicbgimage"];
        [collectArray addObject:dict];
        //再把设置好的数组添加后带有plist原有数据的数组上
        [dataArray addObjectsFromArray:collectArray];
        //把数组重新写入文件
        BOOL flag =[dataArray writeToFile:filepath atomically:YES];
        if(flag){
            NSLog(@"收藏成功");
            [button setBackgroundImage:[UIImage imageNamed:@"已收藏.png"] forState:UIControlStateNormal];
        }
    }
    else{
        //取消收藏歌曲
        //1.删除collect.plist里面对应的字典
        //这里使用反向遍历，防止报错
        for(NSDictionary *dict in dataArray.reverseObjectEnumerator){
            if([dict[@"musiclabel"] isEqual:musicLabel]){
                [dataArray removeObject:dict];
            }
        }
        //3.再把更新后的dataArray写进collect.plist文件上
        BOOL flag =[dataArray writeToFile:filepath atomically:YES];
        if(flag){
            NSLog(@"取消成功");
            [button setBackgroundImage:[UIImage imageNamed:@"未收藏.png"] forState:UIControlStateNormal];
        }
    }
    }


#pragma mark - 计时器方法 - 图片转动
-(void)imgTransform{
    
    self.myImageView.transform = CGAffineTransformRotate(self.myImageView.transform, 0.01);
    
}

#pragma mark - 播放计时器方法
-(void)playerAction{
    //当前时间 / 总时间 赋值给slider.value.value改变，滑块滑动
    self.slider.value = CMTimeGetSeconds(self.player.currentItem.currentTime) / CMTimeGetSeconds(self.player.currentItem.duration);
    if(self.slider.value == 1.0){
        [self playnextmusic:nil];
        [self.player play];
    }
    //总时间
    NSInteger totalTime = CMTimeGetSeconds(self.player.currentItem.duration);
    NSInteger minTime = totalTime / 60;
    NSInteger secondTime = totalTime % 60;
    NSString *timeStr = [NSString stringWithFormat:@"%02ld:%02ld", (long)minTime,(long)secondTime];
    self.timeLable.text = timeStr;
    
    //当前播放时间
    NSInteger totalTime1 = CMTimeGetSeconds(self.player.currentItem.currentTime);
    
    NSInteger minTime1 = totalTime1 / 60;
    NSInteger secondTime1 = totalTime1 % 60;
    NSString *timeStr1 = [NSString stringWithFormat:@"%02ld:%02ld", (long)minTime1,(long)secondTime1];
    self.currentTimeLable.text = timeStr1;
}
    
#pragma mark - 手动拖动进度条的相应地变化
-(void)progressAction:(UISlider *)slider{
        //1.slider的value值发生变化时，currentTime也在发生变化（在playerAction中定义了value的公式）
        float current = slider.value;
        //2.获取最终的currentTime
        float nextCurrent = current * CMTimeGetSeconds(self.player.currentItem.duration);
        //3.拖动slider导致value的值改变时，player能够让正在进行的item追着时间走
        [self.player seekToTime:CMTimeMakeWithSeconds(nextCurrent, 1.0)];
        //6.使得计时器一直处于启动状态
        self.timer.fireDate =[NSDate distantPast];
}

#pragma mark - 收藏模式图标的改变
-(BOOL)collectChange{
    //重新改变收藏状态
    //1。首先拿到正要播放的歌曲
    Playlist *collectmodel = self.musicArray[currentIndex];
    NSString *label = collectmodel.musiclabel;
    //2.拿到collect.plist文件里面的歌单
    NSString *collectpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
    NSString *filepath = [collectpath stringByAppendingPathComponent:@"collect.plist"];
    NSArray *collectArray = [[NSArray alloc] initWithContentsOfFile:filepath];
    //3.拿界面初始化的歌单跟收藏列表里面的歌对比，看是否已经被收藏
    for(NSDictionary *dict in collectArray){
        if([label isEqual: dict[@"musiclabel"]]){
            self.isCollect = YES;
            return YES;
        }else{
            continue;
        }
    }
    return NO;
}

@end

