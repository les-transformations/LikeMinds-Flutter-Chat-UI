import 'package:flutter/material.dart';

class LMLoader extends StatelessWidget {
  final Color? primary;

  const LMLoader({super.key, this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      width: 64,
      child: Center(
        child: CircularProgressIndicator(
          color: primary ?? Colors.blue,
        ),
      ),
    );
  }
}
