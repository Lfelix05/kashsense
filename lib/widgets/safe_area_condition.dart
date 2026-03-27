import 'package:flutter/widgets.dart';

double getBottomSafePadding(BuildContext context, {double basePadding = 16}) {
  final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
  return bottomInset > 0 ? bottomInset + basePadding : basePadding;
}
