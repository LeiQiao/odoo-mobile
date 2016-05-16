//
//  KanbanViewController.m
//

#import "KanbanViewController.h"
#import "KanbanRender.h"
#import "GlobalModels.h"
#import "HUD.h"

@implementation KanbanViewController {
    KanbanRender* _kanbanRender;
}

#pragma mark
#pragma mark helper

-(void) reloadData
{
    popWaiting();
    [_kanbanRender updateWithWidth:self.tableView.frame.size.width-35 callback:^() {
        dismissWaiting();
        [self.tableView reloadData];
    }];
}

#pragma mark
#pragma mark init & dealloc

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    ViewModeData* viewMode = [_window viewModeForName:kKanbanViewModeName];
    _kanbanRender = [[KanbanRender alloc] initWithViewMode:viewMode];
    
    ADDOBSERVER(RecordModel, (id<RecordModelObserver>)self);
    
    if( viewMode.records.count == 0 )
    {
        popWaiting();
        [GETMODEL(RecordModel) requestMoreRecord:_window viewMode:viewMode];
    }
    else
    {
        [self reloadData];
    }
}

-(void) dealloc
{
    REMOVEOBSERVER(RecordModel, (id<RecordModelObserver>)self);
}

#pragma mark
#pragma mark RecordModelObserver

-(void) recordModel:(RecordModel*)recordModel requestMoreRecord:(ReturnParam*)params
{
    if( (params[@"Window"] != _window) ||
       (params[@"ViewMode"] != [_window viewModeForName:kKanbanViewModeName]) ) return;
    
    dismissWaiting();
    if( !params.success )
    {
        popError(params.failedReason);
    }
    
    [self reloadData];
}

#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_kanbanRender recordCount];
}

-(CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [_kanbanRender recordHeight:indexPath.row];
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if( !cell )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        for( UIView* view in cell.contentView.subviews )
        {
            if( [view isKindOfClass:[WKWebView class]] )
            {
                [view removeFromSuperview];
            }
        }
    }
    
    WKWebView* webView = [_kanbanRender recordWebView:indexPath.row];
    if( [webView isKindOfClass:[NSNull class]] ) return cell;
    
    CGRect newFrame = webView.frame;
    newFrame.origin = CGPointZero;
    newFrame.size.height = webView.scrollView.contentSize.height;
    webView.frame = newFrame;
    [cell.contentView addSubview:webView];
    
    return cell;
}

@end
