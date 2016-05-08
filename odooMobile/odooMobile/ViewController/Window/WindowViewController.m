//
//  WindowViewController.m
//

#import "WindowViewController.h"
#import "GlobalModels.h"
#import "HUD.h"
#import "UIViewController+CustomUI.h"
#import "KanbanDataSource.h"
#import "Preferences.h"

/*!
 *  @author LeiQiao, 16-04-27
 *  @brief 窗口菜单视图
 */
@implementation WindowViewController {
    WindowData* _window;                /*!< 窗口数据 */
    ViewModeDataSource* _recordSource;  /*!< UITableView的数据源 */
}

#pragma mark
#pragma mark init & dealloc

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    // 隐藏导航栏的Segment和按钮
    self.viewModeSegment.hidden = YES;
    self.navigationItem.rightBarButtonItem = nil;
    
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
    ViewModeData* viewMode = [_window.viewModes objectAtIndex:self.viewModeSegment.selectedSegmentIndex];
    
    if( [viewMode.name isEqualToString:@"kanban"] ||
       [viewMode.name isEqualToString:@"list"] )
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"＋"
                                                                                  style:UIBarButtonItemStyleDone
                                                                                 target:self
                                                                                 action:@selector(addButtonClicked:)];
        
        if( [viewMode.name isEqualToString:@"kanban"] )
        {
            _recordSource = [[KanbanDataSource alloc] initWithWindow:_window];
            [_recordSource updateHeightWithWidth:self.tableView.frame.size.width
                                   updatedTarget:self andAction:@selector(cellHeightDidUpdated:)];
        }
        if( viewMode.records.count == 0 )
        {
            [_recordSource requestMoreRecords];
        }
    }
}

-(void) addButtonClicked:(id)sender
{
}

-(void) cellHeightDidUpdated:(NSNumber*)index
{
    if( index )
    {
//        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[index integerValue]
//                                                                    inSection:0]]
//                              withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        [self.tableView reloadData];
    }
}

#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [_recordSource numberOfRecords];
    return count;
}

-(CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    CGFloat height = [_recordSource heightOfRecord:indexPath.row];
    return height;
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [_recordSource cellOfRecord:indexPath.row inTableView:tableView];
    return cell;
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
    
    [self.viewModeSegment removeAllSegments];
    
    for( NSUInteger i=0; i<_window.viewModes.count; i++ )
    {
        ViewModeData* viewMode = [_window.viewModes objectAtIndex:i];
        
        // search和form不单独显示视图模式，这两种显示模式集成在其他页面
        if( (![viewMode.name isEqualToString:@"search"]) &&
           (![viewMode.name isEqualToString:@"form"]) )
        {
            [self.viewModeSegment insertSegmentWithTitle:viewMode.displayName atIndex:i animated:NO];
        }
    }
    self.viewModeSegment.hidden = NO;
    
    // 默认选中第一个,直接调用按钮事件，下面一句不会触发事件
    self.viewModeSegment.selectedSegmentIndex = 0;
    [self viewModeChanged:self.viewModeSegment];
}

@end
