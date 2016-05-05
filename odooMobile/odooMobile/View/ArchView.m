//
//  ArchView.m
//

#import "ArchView.h"

/*!
 *  @author LeiQiao, 16/05/01
 *  @brief XML文件转换成View
 */
@implementation ArchView

#pragma mark
#pragma mark class functions

/*!
 *  @author LeiQiao, 16/05/01
 *  @brief 使用XML的字符串创建View
 *  @param archString XML字串
 *  @return 返回创建的View
 */
+(instancetype) viewWithArchString:(NSString*)archString
{
    GDataXMLDocument* xmlData = [[GDataXMLDocument alloc] initWithXMLString:archString options:0 error:nil];
    GDataXMLElement* element = xmlData.rootElement;
    
    ArchView* rootView = [ArchView parseElement:element];
    return rootView;
}

/*!
 *  @author LeiQiao, 16/05/01
 *  @brief 根据不同的TAG生成对应的View
 *  @param element XML标签
 *  @return XML样式的View
 */
+(ArchView*) parseElement:(GDataXMLElement*)element
{
    // 错误，没有XML项目
    if( !element )
    {
        UILabel* errorLabel = [[UILabel alloc] init];
        errorLabel.text = @"error archDB";
        errorLabel.textAlignment = NSTextAlignmentCenter;
        
        ArchView* view = [[ArchView alloc] init];
        view->_view = errorLabel;
        return view;
    }
    
    // 标签类型
    ArchView* view = nil;
    NSString* tagName = [element.name lowercaseString];
    // common
    if( [tagName isEqualToString:@"div"] )
    {
        view = [[ArchView_Div alloc] init];
    }
    else if( [tagName isEqualToString:@"span"] )
    {
        view = [[ArchView_Span alloc] init];
    }
    else if( [tagName isEqualToString:@"strong"] )
    {
        view = [[ArchView_Strong alloc] init];
    }
    else if( [tagName isEqualToString:@"ul"] )
    {
        view = [[ArchView_UL alloc] init];
    }
    else if( [tagName isEqualToString:@"li"] )
    {
        view = [[ArchView_LI alloc] init];
    }
    else if( [tagName isEqualToString:@"img"] )
    {
        view = [[ArchView_Img alloc] init];
    }
    else if( [tagName isEqualToString:@"text"] )
    {
        view = [[ArchView_Text alloc] init];
    }
    // Odoo extends
    else if( [tagName isEqualToString:@"kanban"] )
    {
        view = [[ArchView_Kanban alloc] init];
    }
    else if( [tagName isEqualToString:@"templates"] )
    {
        view = [[ArchView_Templates alloc] init];
    }
    else if( [tagName isEqualToString:@"t"] )
    {
        view = [[ArchView_T alloc] init];
    }
    else if( [tagName isEqualToString:@"field"] )
    {
        view = [[ArchView_Field alloc] init];
    }
    else
    {
        UILabel* errorLabel = [[UILabel alloc] init];
        errorLabel.text = [NSString stringWithFormat:@"tag (%@) can NOT be parsed", tagName];
        errorLabel.textAlignment = NSTextAlignmentCenter;
        
        ArchView* view = [[ArchView alloc] init];
        view->_view = errorLabel;
        return view;
    }
    
    // 解析XML标签内容
    [view parseElement:element];
    return view;
}

#pragma mark
#pragma mark member functions

/*!
 *  @author LeiQiao, 16/05/01
 *  @brief 解析XML标签内容
 *  @param element XML标签
 */
-(void) parseElement:(GDataXMLElement*)element
{
    // 标签名
    _tagName = [element.name lowercaseString];
    
    // 样式
    _styleNames = @"";
    if( element.kind == GDataXMLElementKind )
    {
        _styleNames = [[element attributeForName:@"class"] stringValue];
    }
    
    // 子控件
    _children = [NSMutableArray new];
    for( GDataXMLElement* childElement in [element children] )
    {
        ArchView* childView = [ArchView parseElement:childElement];
        [_view addSubview:childView.view];
        [_children addObject:childView];
    }
}

#pragma mark
#pragma mark override

-(void) setFrame:(CGRect)newFrame
{
    _view.frame = newFrame;
}

@end

@implementation ArchView_Div
@end

@implementation ArchView_Span
@end

@implementation ArchView_Strong
@end

@implementation ArchView_UL
@end

@implementation ArchView_LI
@end

@implementation ArchView_Img
@end

@implementation ArchView_Text
@end

@implementation ArchView_Kanban
@end

@implementation ArchView_Templates
@end

@implementation ArchView_T
@end

@implementation ArchView_Field
@end












