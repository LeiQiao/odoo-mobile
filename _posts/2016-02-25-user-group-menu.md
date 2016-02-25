---
layout: post
title: Odoo 9 用户和用户的权限
---

本文从数据库出发，分析用户及用户权限的管理，主要涉及5张表，及3张关系对应表。 <br/>

## res_users 用户表
{% highlight sql %}
CREATE TABLE "public"."res_users" (
	"id" int4 NOT NULL DEFAULT nextval('res_users_id_seq'::regclass),
	"active" bool DEFAULT true,
	"login" varchar(64) NOT NULL COLLATE "default",
	"password" varchar COLLATE "default",
	"company_id" int4 NOT NULL,
	"partner_id" int4 NOT NULL,
	"create_date" timestamp(6) NULL,
	"create_uid" int4,
	"share" bool,
	"write_uid" int4,
	"write_date" timestamp(6) NULL,
	"signature" text COLLATE "default",
	"action_id" int4,
	"password_crypt" varchar COLLATE "default",
	"alias_id" int4 NOT NULL,
	"chatter_needaction_auto" bool,
	"sale_team_id" int4
)
{% endhighlight %}
这张表里最重要的两个地方一个是`id`另一个就是`login`了，这里列出只是供下文做个参考。<br/>
这里顺带一提的是，xml-rpc登陆后返回用户的`id`，用此`id`来进行后续业务的操作。<br/>
<br/>

## res_groups 用户组表
{% highlight sql %}
CREATE TABLE "public"."res_groups" (
	"id" int4 NOT NULL DEFAULT nextval('res_groups_id_seq'::regclass),
	"comment" text COLLATE "default",
	"create_uid" int4,
	"create_date" timestamp(6) NULL,
	"name" varchar NOT NULL COLLATE "default",
	"color" int4,
	"share" bool,
	"write_uid" int4,
	"write_date" timestamp(6) NULL,
	"category_id" int4,
	"is_portal" bool
)
{% endhighlight %}
这里最重要的也是两个地方`id`和`name`。没啥好讲的，纯粹凑篇幅～<br/>
<br/>

## res_groups_users_rel 用户－用户组关系表
{% highlight sql %}
CREATE TABLE "public"."res_groups_users_rel" (
	"gid" int4 NOT NULL,
	"uid" int4 NOT NULL
)
{% endhighlight %}
这里只有两个字段，一个是组id，另一个就是用户id，某一用户所在的组id全在这张表里存放。<br/>
<br/>

## res_groups_implied_rel 用户组继承关系表
{% highlight sql %}
CREATE TABLE "public"."res_groups_implied_rel" (
	"gid" int4 NOT NULL,
	"hid" int4 NOT NULL
)
{% endhighlight %}
这里只有两个字段，`gid`表示用户组id，`hid`表示继承的用户组id。<br/>
<br/>

## ir_ui_menu 菜单表
{% highlight sql %}
CREATE TABLE "public"."ir_ui_menu" (
	"id" int4 NOT NULL DEFAULT nextval('ir_ui_menu_id_seq'::regclass),
	"parent_left" int4,
	"parent_right" int4,
	"create_date" timestamp(6) NULL,
	"name" varchar NOT NULL COLLATE "default",
	"web_icon" varchar COLLATE "default",
	"sequence" int4,
	"write_uid" int4,
	"parent_id" int4,
	"write_date" timestamp(6) NULL,
	"action" varchar COLLATE "default",
	"create_uid" int4
)
{% endhighlight %}
这张表里包括 Odoo 界面中所有顶部菜单和侧边栏中的所有菜单的定义。<br/>
<br/>
`name` 菜单显示名称。<br/>
`parent_id` 父级菜单的id。<br/>
`action` 点击的动作。如下图：<br/>
<br/>
![ir_ur_menu表]({{ site.baseurl }}/images/user-group-menu/01.png)<br/>
<br/>
`ir_actions_window` 表示打开一个窗口，逗号后面表示ir_actions_window表中的id值。<br/>
`[Null]` 表示该项为父菜单。点击后没有任何动作<br/>

## ir_ui_menu_group_sel 菜单－用户组对照表
{% highlight sql %}
CREATE TABLE "public"."ir_ui_menu_group_rel" (
	"menu_id" int4 NOT NULL,
	"gid" int4 NOT NULL
)
{% endhighlight %}
这里只有两个字段，`gid`表示用户组id，`menu_id`表示菜单表id。<br/>

## ir_ui_view_group_rel 视图－用户组对照表
{% highlight sql %}
CREATE TABLE "public"."ir_ui_view_group_rel" (
	"view_id" int4 NOT NULL,
	"group_id" int4 NOT NULL
)
{% endhighlight %}
这里只有两个字段，`view_id`表示ir_ui_view表中的id，`group_id`表示用户组id。<br/>
但是这里的纪录并没有想象的那么多，而且这个表在哪里用现在还未知。<br/>

## ir_model_access 用户组访问权限表
{% highlight sql %}
CREATE TABLE "public"."ir_model_access" (
	"id" int4 NOT NULL DEFAULT nextval('ir_model_access_id_seq'::regclass),
	"model_id" int4 NOT NULL,
	"perm_read" bool,
	"name" varchar NOT NULL COLLATE "default",
	"create_uid" int4,
	"write_uid" int4,
	"active" bool,
	"write_date" timestamp(6) NULL,
	"perm_unlink" bool,
	"perm_write" bool,
	"create_date" timestamp(6) NULL,
	"perm_create" bool,
	"group_id" int4
)
{% endhighlight %}
`model_id` 模型表ir_model中的id。表示对改模型的访问权限<br/>
`group_id` 用户组表id。<br/>
`perm_read` 读权限。<br/>
`perm_write` 写权限。<br/>
`perm_create` 创建权限。<br/>
`perm_unlink` 删除权限。<br/>
<br/>
这里提到的权限控制基本可以覆盖“设置”->“组”中的所有配置项。<br/>

## ir_act_window 窗口动作表
{% highlight sql %}
CREATE TABLE "public"."ir_act_window" (
	"id" int4 NOT NULL DEFAULT nextval('ir_actions_id_seq'::regclass),
	"create_uid" int4,
	"create_date" timestamp(6) NULL,
	"help" text COLLATE "default",
	"write_uid" int4,
	"write_date" timestamp(6) NULL,
	"usage" varchar COLLATE "default",
	"type" varchar NOT NULL COLLATE "default",
	"name" varchar NOT NULL COLLATE "default",
	"domain" varchar COLLATE "default",
	"res_model" varchar NOT NULL COLLATE "default",
	"search_view_id" int4,
	"view_type" varchar NOT NULL COLLATE "default",
	"src_model" varchar COLLATE "default",
	"view_id" int4,
	"auto_refresh" int4,
	"view_mode" varchar NOT NULL COLLATE "default",
	"target" varchar COLLATE "default",
	"multi" bool,
	"auto_search" bool,
	"res_id" int4,
	"filter" bool,
	"limit" int4,
	"context" varchar NOT NULL COLLATE "default"
)
{% endhighlight %}
最后再说一下窗口动作表，上面说到ir_ui_menu的菜单项动作有时是ir_act_window类型，其中类型后面逗号的id就是这个表中的id。<br/>
<br/>
![ir_act_window表]({{ site.baseurl }}/images/user-group-menu/02.png)<br/>
<br/>
`res_model` 视图对应的模型。<br/>
`view_mode` 显示样式，有tree(列表)、form(详细页)、kanban(缩略图)等等显示样式。<br/>
`target` 目标窗口，current(当前窗口)、new(新窗口)等等。<br/>
`context` 纪录的筛选条件。<br/>
<br/>
但有一点尚不明白的是窗口动作是如何跟ir_ui_view中的窗口显示联系在一起的。
