import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/main_drawer.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';

class BodyWidget extends StatefulWidget {
  final Widget body;
  final AppBarWidget appBar;
  final double topMargin;
  final Widget? drawer;
  const BodyWidget({
    super.key,
    required this.body,
    required this.appBar,
    this.topMargin = 10,
    this.drawer,
  });

  @override
  State<BodyWidget> createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<BodyWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      drawer: MainDrawer(),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: Dimensions.webMaxWidth,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: widget.body,
            ),
          ),
        ],
      ),
    );
  }
}
