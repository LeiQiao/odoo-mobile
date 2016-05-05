//
//  ViewModeDataSource.m
//

#import "ViewModeDataSource.h"
#import "GlobalModels.h"
#import "HUD.h"

@implementation ViewModeDataSource

-(instancetype) initWithWindow:(WindowData*)window
{
    if( self = [super init] )
    {
        _window = window;
        _viewMode = nil;
        _recordHeights = [NSMutableArray new];
        
        ADDOBSERVER(RecordModel, (id<RecordModelObserver>)self);
    }
    return self;
}

-(void) dealloc
{
    REMOVEOBSERVER(RecordModel, (id<RecordModelObserver>)self);
}

-(void) requestMoreRecords:(void(^)(BOOL success))callback
{
    _callback = callback;
    popWaiting();
    [GETMODEL(RecordModel) requestMoreRecord:_window viewMode:_viewMode];
}

-(void) cleanRecord
{
    [_viewMode.records removeAllObjects];
    [_recordHeights removeAllObjects];
}

-(NSInteger) numberOfRecords
{
    return _viewMode.records.count;
}

-(CGFloat) heightOfRecord:(NSInteger)index
{
    return [_recordHeights[index] floatValue];
}

-(UITableViewCell*) cellOfRecord:(NSInteger)index
{
    NSAssert(NO, @"subclass must override \"cellOfRecord\".");
    return nil;
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
    
    if( _callback )
    {
        _callback(params.success);
        _callback = nil;
    }
}

@end
