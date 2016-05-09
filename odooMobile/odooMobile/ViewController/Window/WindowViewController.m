//
//  WindowViewController.m
//

#import "WindowViewController.h"
#import "GlobalModels.h"
#import "HUD.h"
#import "UIViewController+CustomUI.h"
#import "Preferences.h"
#import "KanbanViewController.h"

/*!
 *  @author LeiQiao, 16-04-27
 *  @brief 窗口菜单视图
 */
@implementation WindowViewController {
    WindowData* _window;                /*!< 窗口数据 */
}

#pragma mark
#pragma mark init & dealloc

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    // 使用空白的VC代替正在加载时的页面
    UIViewController* blankVC = [[UIViewController alloc] init];
    blankVC.view.backgroundColor = [UIColor whiteColor];
    self.viewControllers = @[blankVC];
    
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithTitle:@"＋"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(addButtonDidClicked:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    ADDOBSERVER(WindowModel, (id<WindowModelObserver>)self);
    
    // 获取窗口信息
    popWaiting();
    [GETMODEL(WindowModel) updateWindowByID:_windowID];
}

-(void) dealloc
{
    REMOVEOBSERVER(WindowModel, (id<WindowModelObserver>)self);
}

#pragma mark
#pragma mark button events

-(IBAction) viewModeChanged:(id)sender
{
//    ViewModeData* viewMode = [_window.viewModes objectAtIndex:self.viewModeSegment.selectedSegmentIndex];
//    
//    if( [viewMode.name isEqualToString:@"kanban"] ||
//       [viewMode.name isEqualToString:@"list"] )
//    {
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"＋"
//                                                                                  style:UIBarButtonItemStyleDone
//                                                                                 target:self
//                                                                                 action:@selector(addButtonClicked:)];
//        
//        if( [viewMode.name isEqualToString:@"kanban"] )
//        {
//            _recordSource = [[KanbanDataSource alloc] initWithWindow:_window];
//            [_recordSource updateHeightWithWidth:self.tableView.frame.size.width
//                                   updatedTarget:self andAction:@selector(cellHeightDidUpdated:)];
//        }
//        if( viewMode.records.count == 0 )
//        {
//            [_recordSource requestMoreRecords];
//        }
//    }
}

//-(void) cellHeightDidUpdated:(NSNumber*)index
//{
//    if( index )
//    {
////        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[index integerValue]
////                                                                    inSection:0]]
////                              withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
//    else
//    {
//        [self.tableView reloadData];
//    }
//}

-(void) tabBarController:(UITabBarController*)tabBarController didSelectViewController:(UIViewController*)viewController
{
}

#pragma mark
#pragma mark WindowModelObserver

-(void) windowModel:(WindowModel*)windowModel updateWindowByID:(ReturnParam*)params
{
    NSNumber* windowID = params[@"WindowID"];
    if( ![windowID isEqual:_windowID] ) return;
    
    dismissWaiting();
    if( !params.success )
    {
        popError(params.failedReason);
        return;
    }
    
    _window = params[@"Window"];
    
    self.title = _window.displayName;
    
    NSMutableArray* viewControllers = [NSMutableArray new];
    
    ViewModeData* kanbanViewMode = [_window viewModeForName:kKanbanViewModeName];
    ViewModeData* listViewMode = [_window viewModeForName:kListViewModeName];
    if( kanbanViewMode )
    {
        KanbanViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"KanbanViewController"];
        viewController.window = _window;
        [viewControllers addObject:viewController];
    }
    
    // prevent TableView position massed up
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self setViewControllers:viewControllers animated:YES];
    });
    
    if( viewControllers.count == 1 )
    {
        self.tabBar.hidden = YES;
    }
}

@end
