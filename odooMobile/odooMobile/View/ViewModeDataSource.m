//
//  ViewModeDataSource.m
//

#import "ViewModeDataSource.h"
#import "GlobalModels.h"
#import "HUD.h"

@implementation ViewModeDataSource

-(instancetype) initWithWindow:(WindowData*)window
{
    if( self = [self init] )
    {
        _window = window;
        _viewMode = nil;
        
        ADDOBSERVER(RecordModel, (id<RecordModelObserver>)self);
    }
    return self;
}

-(void) dealloc
{
    REMOVEOBSERVER(RecordModel, (id<RecordModelObserver>)self);
}

-(void) updateHeightWithWidth:(CGFloat)width updatedTarget:(id)target andAction:(SEL)action
{
    _updateWidth = width;
    _updatedTarget = target;
    _updatedAtion = action;
}

-(void) requestMoreRecords
{
    popWaiting();
    [GETMODEL(RecordModel) requestMoreRecord:_window viewMode:_viewMode];
}

-(void) cleanRecord
{
    [_viewMode.records removeAllObjects];
}

-(NSInteger) numberOfRecords
{
    return _viewMode.records.count;
}

-(CGFloat) heightOfRecord:(NSInteger)index
{
    NSAssert(NO, @"subclass must override \"heightOfRecord\".");
    return 0;
}

-(UITableViewCell*) cellOfRecord:(NSInteger)index inTableView:(UITableView*)tableView
{
    NSAssert(NO, @"subclass must override \"cellOfRecordInTableView\".");
    return nil;
}

-(void) callUpdate:(NSNumber*)index
{
    if( _updatedTarget && [_updatedTarget respondsToSelector:_updatedAtion] )
    {
        [_updatedTarget performSelector:_updatedAtion withObject:index];
    }
}

-(void) recordModel:(RecordModel*)recordModel requestMoreRecord:(ReturnParam*)params
{
    if( (params[@"Window"] != _window) ||
       (params[@"ViewMode"] != _viewMode) ) return;
    
    dismissWaiting();
    if( !params.success )
    {
        popError(params.failedReason);
    }
    
    [self callUpdate:nil];
}

@end
