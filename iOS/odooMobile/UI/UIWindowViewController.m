//
//  UIWindowViewController.m
//

#import "UIWindowViewController.h"
#import "BaseWindowStyle.h"

/*!
 窗体视图,使用TableView列表方式展示
 */
@implementation UIWindowViewController {
    UITableView* _tableView;        /*!< 列表视图 */
    BaseWindowStyle* _windowStyle;  /*!< 窗体样式表 */
}

#pragma mark
#pragma mark init & dealloc

/*!
 *  @author LeiQiao, 16-04-19
 *  @brief 使用窗体信息重新加载窗体视图
 *  @param windowData 窗体视图
 */
-(void) updateWindowWithWindowData:(NSString*)windowData
{
    // 重新创建窗体样式表
    _windowStyle = [BaseWindowStyle windowFromWindowData:windowData];
    
    // 列表视图样式
    UITableViewStyle tableViewStyle = UITableViewStylePlain;
    UITableViewCellSeparatorStyle sepStyle = UITableViewCellSeparatorStyleNone;
    if( _windowStyle.style == WindowStyleForm )
    {
        tableViewStyle = UITableViewStyleGrouped;
        sepStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    _tableView.separatorStyle = sepStyle;
    
    // 重新加载列表视图
    [_tableView reloadData];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    // 创建列表视图
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = (id<UITableViewDelegate>)self;
    _tableView.dataSource = (id<UITableViewDataSource>)self;
    [self.view addSubview:_tableView];
}

#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return 0;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return nil;
}

@end
