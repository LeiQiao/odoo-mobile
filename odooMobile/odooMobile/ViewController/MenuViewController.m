//
//  MenuViewController.m
//

#import "MenuViewController.h"
#import "Preferences.h"
#import "SlideNavigationController.h"
#import "GlobalModels.h"
#import "HUD.h"

@implementation MenuViewController {
    NSDictionary* _parentMenu;      /*!< 父菜单 */
    NSArray* _subMenus;             /*!< 子菜单 */
}

#pragma mark
#pragma mark init & dealloc

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 使用父菜单初始化
 *  @param parentMenu 父菜单
 *  @return 本类的实例化对象
 */
-(instancetype) initWithParentMenu:(NSDictionary*)parentMenu
{
    if( self = [super init] )
    {
        _parentMenu = parentMenu;
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    if( _parentMenu )
    {
        self.title = [_parentMenu objectForKey:@"name"];
    }
    else
    {
        self.title = @"菜单";
    }
    
    if( _parentMenu )
    {
        popWaiting();
        ADDOBSERVER(MenuModel, (id<MenuModelObserver>)self);
        [GETMODEL(MenuModel) updateSubMenuByMenu:_parentMenu];
    }
}

-(void) dealloc
{
    REMOVEOBSERVER(MenuModel, (id<MenuModelObserver>)self);
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 如果是顶级菜单并且尚未初始化
    if( (!_parentMenu) && (_subMenus == nil) )
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
    
    NSDictionary* menu = [_subMenus objectAtIndex:indexPath.row];
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
            [GETMODEL(WindowModel) updateWindowByID:@([[act objectAtIndex:1] integerValue])];
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
        MenuViewController* menu = [[MenuViewController alloc] initWithParentMenu:currentMenu];
        [[SlideNavigationController sharedInstance] pushViewController:menu animated:YES];
    }
}

#pragma mark
#pragma mark MenuModelObserver

-(void) menuModel:(MenuModel*)menuModel updateSubMenuByMenu:(ReturnParam*)params
{
    NSDictionary* parentMenu = params[@"ParentMenu"];
    if( parentMenu != _parentMenu ) return;
    
    dismissWaiting();
    if( !params.success )
    {
        popError(params.failedReason);
        return;
    }
    
    NSArray* subMenus = params[@"SubMenus"];
    _subMenus = subMenus;
    [self.tableView reloadData];
}

@end
