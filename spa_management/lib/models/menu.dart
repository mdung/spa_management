import 'package:flutter/src/widgets/icon_data.dart';

class Menu {
  final int id;
  final String name;
  final String icon;
  final String? link;
  final int? parentId;
  final int? roleId;
  final int? permissionId;
  final List<Menu>? subMenuItems;

  Menu({
    required this.id,
    required this.name,
    required this.icon,
    this.link,
    this.parentId,
    this.roleId,
    this.permissionId,
    this.subMenuItems,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    List<dynamic> subMenuItemsJson = json['sub_menu_items'];
    List<Menu> subMenuItems = subMenuItemsJson.map((json) => Menu.fromJson(json)).toList();

    return Menu(
      id: json['id'],
      name: json['name'],
      link: json['link'],
      parentId: json['parent_id'],
      roleId: json['role_id'],
      permissionId: json['permission_id'],
      subMenuItems: subMenuItems, icon: '',
    );
  }

}
