//
//  BaseWindowStyle.m
//

#import "BaseWindowStyle.h"
#import "GDataXMLNode.h"

/*!
 *  @author LeiQiao, 16-04-18
 *  @brief 窗口的字段描述
 */
@implementation WindowField
@end

/*!
 *  @author LeiQiao, 16-04-18
 *  @brief 窗口布局，可以为字段进行布局，也可以包含子布局，当两个值同时有值时先布局字段
 */
@implementation WindowLayout
@end

/*!
 *  @author LeiQiao, 16-04-18
 *  @brief 窗口基础样式表
 */
@implementation BaseWindowStyle

#pragma mark
#pragma mark helper

-(void) parseXMLDocument:(GDataXMLDocument*)document
{
}


#pragma mark
#pragma mark class methods

/*!
 *  @author LeiQiao, 16-04-18
 *  @brief 解析窗口布局样式
 *  @param windowData 窗口布局数据
 *  @return 窗口样式表
 */
+(BaseWindowStyle*) windowFromWindowData:(NSString*)windowData
{
    // 构建XML树
    NSError* error = nil;
    GDataXMLDocument* xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:windowData
                                                                   options:0
                                                                     error:&error];
    if( error ) return nil;
    
    // 创建窗口样式表
    BaseWindowStyle* windowStyle = [BaseWindowStyle new];
    [windowStyle parseXMLDocument:xmlDoc];
    return windowStyle;
}

@end
