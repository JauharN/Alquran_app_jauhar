import 'package:flutter/material.dart';

class MenuItemModel {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final String? route;

  const MenuItemModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    this.route,
  });

  MenuItemModel copyWith({
    String? id,
    String? title,
    IconData? icon,
    Color? color,
    String? route,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      route: route ?? this.route,
    );
  }
}
