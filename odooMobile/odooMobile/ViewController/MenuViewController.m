//
//  MenuViewController.m
//

#import "MenuViewController.h"
#import "Preferences.h"
#import "SlideNavigationController.h"
#import "GlobalModels.h"
#import "HUD.h"
#import "WindowViewController.h"

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 菜单界面视图
 */
@implementation MenuViewController {
    NSArray* _subMenus;             /*!< 子菜单 */
}

#pragma mark
#pragma mark init & dealloc

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // 设置菜单标题
    if( self.parentMenu )
    {
        self.title = [self.parentMenu objectForKey:@"name"];
    }
    else
    {
        self.title = @"菜单";
    }
    
    // 如果是二级及以下菜单则子菜单需要从网络获取
    if( self.parentMenu )
    {
        popWaiting();
        ADDOBSERVER(MenuModel, (id<MenuModelObserver>)self);
        [GETMODEL(MenuModel) updateSubMenuByMenu:self.parentMenu];
    }
}

-(void) dealloc
{
    REMOVEOBSERVER(MenuModel, (id<MenuModelObserver>)self);
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 如果是顶级菜单并且尚未初始化，需要从缓存的菜单列表中筛选
    if( (!self.parentMenu) && (_subMenus == nil) )
    {
        NSMutableArray* subMenus = [NSMutableArray new];
        for( NSDictionary* menu in gPreferences.Menus )
        {
            // 子菜单的父菜单ID
            if( [[menu objectForKey:@"parent_id"] isEqual:@(0)] )
            {
                [subMenus addObject:menu];
            }
        }
        // 保存父菜单及所有子菜单
        _subMenus = subMenus;
        [self.tableView reloadData];
        
        // 如果该页面是侧滑页面需要调整TableView的宽度
        SlideNavigationController* nav = [SlideNavigationController sharedInstance];
        if( self.navigationController == nav.leftMenu )
        {
            CGRect newFrame = self.tableView.frame;
            newFrame.size.width -= nav.portraitSlideOffset;
            self.tableView.frame = newFrame;
        }
    }
}

#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return _subMenus.count;
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // 获取子菜单项
    NSDictionary* menu = [_subMenus objectAtIndex:indexPath.row];
    
    // 显示子菜单项
    cell.textLabel.text = [menu objectForKey:@"name"];
    
    return cell;
}

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* currentMenu = [_subMenus objectAtIndex:indexPath.row];
    NSString* action = [currentMenu objectForKey:@"action"];
    
    // 如果当前菜单项是一个动作，则运行该动作
    if( [action isKindOfClass:[NSString class]] )
    {
        NSArray* act = [action componentsSeparatedByString:@","];
        if( [[act objectAtIndex:0] isEqualToString:@"ir.actions.act_window"] )
        {
            
            UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                         style:UIBarButtonItemStyleDone
                                                                        target:nil action:nil];
            self.navigationItem.backBarButtonItem = backItem;
            WindowViewController* window = [self.storyboard instantiateViewControllerWithIdentifier:@"WindowViewController"];
            window.windowID = @([[act objectAtIndex:1] integerValue]);
            [[SlideNavigationController sharedInstance] pushViewController:window animated:YES];
        }
        else
        {
            UIAlertView* av = [[UIAlertView alloc] initWithTitle:action
                                                         message:nil
                                                        delegate:self
                                               cancelButtonTitle:@"确定"
                                               otherButtonTitles:nil];
            [av show];
        }
    }
    // 进入展示子菜单动作
    else
    {
        MenuViewController* menu = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
        menu.parentMenu = currentMenu;
        [[SlideNavigationController sharedInstance] pushViewController:menu animated:YES];
    }
}

#pragma mark
#pragma mark MenuModelObserver

-(void) menuModel:(MenuModel*)menuModel updateSubMenuByMenu:(ReturnParam*)params
{
    // 是否为当前Menu
    NSDictionary* parentMenu = params[@"ParentMenu"];
    if( parentMenu != self.parentMenu ) return;
    
    // 请求失败
    dismissWaiting();
    if( !params.success )
    {
        popError(params.failedReason);
        return;
    }
    
    // 刷新子菜单
    NSArray* subMenus = params[@"SubMenus"];
    _subMenus = subMenus;
    [self.tableView reloadData];
}

@end
