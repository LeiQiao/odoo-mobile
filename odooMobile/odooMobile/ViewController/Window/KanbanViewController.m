//
//  KanbanViewController.m
//

#import "KanbanViewController.h"
#import "KanbanRender.h"
#import "GlobalModels.h"
#import "HUD.h"

#define TAG_CELL_IMAGEVIEW      (0x1)

@implementation KanbanViewController {
    KanbanRender* _kanbanRender;
    NSMutableArray* _recordImages;
}

#pragma mark
#pragma mark helper

-(void) reloadData
{
    [_recordImages removeAllObjects];
    ViewModeData* viewMode = [_window viewModeForName:kKanbanViewModeName];
    for( NSUInteger i=0; i<viewMode.records.count; i++ )
    {
        [_recordImages addObject:[NSNull null]];
        [KanbanRender renderViewMode:viewMode forRecordIndex:i withWidth:self.tableView.frame.size.width-20 callback:^(UIImage* image) {
            _recordImages[i] = image;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
        break;
    }
}

#pragma mark
#pragma mark init & dealloc

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    _recordImages = [NSMutableArray new];
    
    ADDOBSERVER(RecordModel, (id<RecordModelObserver>)self);
    
    ViewModeData* viewMode = [_window viewModeForName:kKanbanViewModeName];
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
    return _recordImages.count;
}

-(CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UIImage* recordImage = _recordImages[indexPath.row];
    if( [recordImage isKindOfClass:[NSNull class]] ) return self.tableView.rowHeight;
    
    CGSize imageSize = recordImage.size;
    return imageSize.height/2;
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
    }
    else
    {
        for( UIView* view in cell.contentView.subviews )
        {
            if( view.tag == TAG_CELL_IMAGEVIEW )
            {
                [view removeFromSuperview];
            }
        }
    }
    
    UIImage* image = _recordImages[indexPath.row];
    if( [image isKindOfClass:[NSNull class]] ) return cell;
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, image.size.width/2, image.size.height/2);
    imageView.tag = TAG_CELL_IMAGEVIEW;
    [cell.contentView addSubview:imageView];
    return cell;
}

@end
