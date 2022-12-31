import 'dart:core';
import 'package:flutter/material.dart';

extension NotNulls on List {
  ///Returns items that are not null, for UI Widgets/PopupMenuItems etc.
  notNulls() {
    if (this is List<Widget?>) {
      return where((e) => e != null).toList().cast<Widget>();
    }

    return this;
  }
}
