import 'package:flutter/cupertino.dart';

class SpacedRow extends StatelessWidget {
  final Widget a;
  final Widget b;

  SpacedRow(this.a, this.b);

  @override
  Widget build( context) {
    // TODO: implement build
    return Row(children: [
      SizedBox(width: 10),
      a,
      Expanded(child: SizedBox()),
      b,
      SizedBox(width: 10)
    ]);
  }

}