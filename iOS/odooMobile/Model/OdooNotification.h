//
//  OdooNotification.h
//

#import <Foundation/Foundation.h>

@class NetworkResponse;

/*!
 *  @author LeiQiao, 16/04/03
 *  @brief 发送通知消息
 *  @param notificationName 消息名
 *  @param object           消息参数
 */
extern void OdooPostNotification(NSString* notificationName, id object);

/*!
 *  @author LeiQiao, 16-04-09
 *  @brief 登录通知，用户开始登录
 */
extern NSString* const kWillLoginNotification;

/**
 *  @author LeiQiao, 16/04/03
 *  @brief 登录结果通知
 *  @return Native - NetworkResponse类
 *          React-Native - success 登录是否成功
 *                         failedReason 登录失败的原因
 */
extern NSString* const kDidLoginNotification;

/*!
 *  @author LeiQiao, 16-04-09
 *  @brief 显示公司信息通知
 */
extern NSString* const kShowCompanyInfoNotification;

/*!
 *  @author LeiQiao, 16-04-09
 *  @brief 显示用户信息通知
 */
extern NSString* const kShowPersonalInfoNotification;

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 获取子菜单通知，开始获取子菜单
 */
extern NSString* const kWillLoadSubmenuNotification;

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 获取子菜单结果通知
 */
extern NSString* const kDidLoadSubmenuNotification;








