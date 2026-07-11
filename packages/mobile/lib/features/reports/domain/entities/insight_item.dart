import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class InsightItem extends Equatable {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  @override
  List<Object?> get props => [icon, iconColor, title, description];

  const InsightItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });
}
