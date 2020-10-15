//
//  RootViewController.m
//  播放音效
//
//  Created by kkkak on 2020/4/10.
//  Copyright © 2020 kkkak. All rights reserved.
//

#import "RootViewController.h"
#import "ViewController.h"
#import "Playlist.h"
#import "CollectViewController.h"

@interface RootViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSMutableArray *dataArray;
//创建一个数组存放所有的音乐资源//
@property (nonatomic,strong)NSArray *musicArray;
@end
//设置一个外部变量用来传递index//
int passindex;
//设置一个外部变量来传递歌曲数目
int playcount;
//设置一个外部变量来传递歌曲路径//
NSString *musicPlay;
//设置一个外部变量来传递歌名//
NSString *musicLabel;
//设置一个外部变量来传递专辑封面//
NSString *musicIcon;
//设置一个变量来传背景图片
NSString *musicbgimage;
//接受iscollectplist来判断歌曲来自哪个列表
extern BOOL iscollectplist;
//设置一个外部变量来判断是否是搜索的数据
int isinlist;
@implementation RootViewController

//懒加载musicArray//
-(NSArray *)musicArray
{
  
    if(!_musicArray){
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"list.plist" ofType:nil]];
        NSMutableArray *temp =[NSMutableArray array];
        for(NSDictionary *musicDict in dictArray){
            [temp addObject:[Playlist musicWithDict:musicDict]];
        }
        _musicArray = temp;
    }
    return _musicArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource =self;
    self.tableView.sectionHeaderHeight = 80;
    self.tableView.rowHeight = 60;
    self.navigationItem.title = @"播放列表";
    self.tableView.delegate = self;
    //playcount 用来保存歌曲的总数目
    playcount = (int)self.musicArray.count;
    UIImage *image = [UIImage imageNamed:@"收藏列表"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:0 target:self action:@selector(collectplist)];
    //添加搜索栏
    CGRect mainViewBounds = self.view.bounds;
    UISearchBar *customSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(mainViewBounds.size.width/2-((mainViewBounds.size.width-120)/2)+30, CGRectGetMinY(mainViewBounds)+86, CGRectGetWidth(mainViewBounds)-120, 40)];
    customSearchBar.delegate = self;
    customSearchBar.showsCancelButton = YES;
    //搜索框样式
    customSearchBar.searchBarStyle = UISearchBarStyleMinimal;
    [self.view addSubview: customSearchBar];
    }


#pragma mark - UITableViewDataSource
//1.设置组数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//2.设置每组有多少行
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //if(isinlist) 用来判断是否用搜索栏搜索出对应的歌曲
    if(isinlist){
        return self.dataArray.count;
    }else{
        return self.musicArray.count;
    }
}

//3.显示每一行的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //取出indexPath对应的模型//
    //if(isinliat)用来判断是否用搜索栏搜索出对应的歌曲
    if(isinlist){
        NSDictionary *dict = self.dataArray[indexPath.row];
        cell.textLabel.text = dict[@"musiclabel"];
    }else{
        Playlist *music = self.musicArray[indexPath.row];
        cell.textLabel.text = music.musiclabel;
    }
    return cell;
}
//4.设置头部标题
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return @"播放列表";
    }else{
        return 0;
    }
}
//5.添加UITableViewCell的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //iscollectplist = NO 表示歌曲来自播放列表而不是收藏列表
    iscollectplist = NO;
    ViewController* vcplayer = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"player"];
    //if(isinlist)用来判断cell显示的内容是播放列表的还是用UISearchBar搜索出来的结果
    if(isinlist){
        NSDictionary *dict = self.dataArray[indexPath.row];
        NSString *label = dict[@"musiclabel"];
        //拿到播放列表的歌曲并拿到这首歌在播放列表中的下标
        NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"list.plist" ofType:nil]];
        for(NSDictionary *search in array){
            static int i = 0;
            if([search[@"musiclabel"] isEqual:label]){
                passindex = i;
                break;
            }else{
                i++;
            }
        }
      
    }else{
        passindex = (int)indexPath.row;
    }
    Playlist *model = self.musicArray[passindex];
    musicPlay = model.musicplay;
    musicLabel = model.musiclabel;
    musicIcon = model.musicicon;
    musicbgimage = model.musicbgimage;
    [self.navigationController pushViewController:vcplayer animated:YES];
}

//6.跳转到收藏列表
-(void)collectplist
{
    CollectViewController *collect = [[CollectViewController alloc] init];
    [self.navigationController pushViewController:collect animated:YES];
}

#pragma mark - 搜索栏对应的代理方法
//8.点击search时实现的方法
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSMutableArray *search=[[NSMutableArray alloc] init];
    //先拿到当前列表的数据
    NSArray *list = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"list.plist" ofType:nil]];
    //拿到搜索框里面的内容跟列表的歌进行比对
    for(NSDictionary *dict in list){
        if([dict[@"musiclabel"] rangeOfString:searchBar.text].location != NSNotFound){
            //表明tableViewCell展示的内容是搜索的数据
            //如果搜索的数据在列表里面，那么tableView就更新数据
            //1.把对应的数据放到一个数组里面，然后刷新tableView
            NSMutableDictionary *collect = [[NSMutableDictionary alloc] init];
            [collect setObject:dict[@"musiclabel"] forKey:@"musiclabel"];
            [search addObject:collect];
        }
    }
    //dataArray数组已经拿到搜索的数据
    self.dataArray = search;
    //判断dataArray数组是否为空
    if(_dataArray != nil && ![_dataArray isKindOfClass:[NSNull class]] && _dataArray.count !=0)
    {
        isinlist = 1;
    }else{
        isinlist = 0;
    }
    //刷新列表，更新显示的数据
    [self.tableView reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    isinlist = 0;
    [self.tableView reloadData];
    //退出键盘
    [self.view endEditing:YES];
}

@end
