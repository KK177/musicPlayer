//
//  CollectViewController.m
//  播放音效
//
//  Created by kkkak on 2020/4/15.
//  Copyright © 2020 kkkak. All rights reserved.
//

#import "CollectViewController.h"
#import "Playlist.h"
#import "ViewController.h"

@interface CollectViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//创建一个数组存放所有收藏的音乐资源//
@property (nonatomic,strong)NSArray *collectArray;
@end

//传递播放列表的index//
extern int passindex;
//设置一个外部变量来传递歌曲路径//
extern NSString *musicPlay;
//设置一个外部变量来传递歌名//
extern NSString *musicLabel;
//设置一个外部变量来传递专辑封面//
extern NSString *musicIcon;
//传递背景图片//
extern NSString *musicbgimage;
//设置一个外部变量来让播放器判断歌曲来自播放列表还是收藏列表//
BOOL iscollectplist;
//传递列表的歌曲数目//
int collectcount;

@implementation CollectViewController


//懒加载collectArray//
-(NSArray *)collectArray
{
    if(!_collectArray){
        
    }
        //这里加载的collect文件是存储在沙盒里面的
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
         NSString *filepath = [path stringByAppendingPathComponent:@"collect.plist"];
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:filepath];
        NSMutableArray *temp =[NSMutableArray array];
        for(NSDictionary *musicDict in dictArray){
            [temp addObject:[Playlist musicWithDict:musicDict]];
        }
        _collectArray = temp;
    
    return _collectArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"收藏列表";
    self.tableView.dataSource = self;
    self.tableView.sectionHeaderHeight = 80;
    self.tableView.rowHeight = 60;
    self.tableView.delegate = self;
    iscollectplist = 0;
    collectcount = (int)self.collectArray.count;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

//1.设置组数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//2.设置每组有多少行
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.collectArray.count;
}
//3.设置头部标题
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return @"收藏列表";
    }else{
        return 0;
    }
}

//4.显示每一行的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //取出indexPath对应的模型//
    Playlist *collectmusic = self.collectArray[indexPath.row];
    //设置数据//
    cell.textLabel.text = collectmusic.musiclabel;
    return cell;

}
//5.添加UITableViewCell的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    iscollectplist = YES;
    ViewController* vcplayer = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"player"];
    //取出indexPath对应的模型//
    Playlist *collectmusic = self.collectArray[indexPath.row];
    //取出正在播放的歌曲label//
    passindex = indexPath.row;
    musicPlay = collectmusic.musicplay;
    musicLabel = collectmusic.musiclabel;
    musicIcon = collectmusic.musicicon;
    musicbgimage = collectmusic.musicbgimage;
    [self.navigationController pushViewController:vcplayer animated:YES];
}


@end
