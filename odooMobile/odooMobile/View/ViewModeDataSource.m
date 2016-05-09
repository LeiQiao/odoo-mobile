//
//  ViewModeDataSource.m
//

#import "ViewModeDataSource.h"
#import "HUD.h"

@implementation ViewModeDataSource

-(instancetype) initWithWindow:(WindowData*)window
{
    if( self = [self init] )
    {
        _window = window;
        _viewMode = nil;
        
    }
    return self;
}

-(void) dealloc
{
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

@end
