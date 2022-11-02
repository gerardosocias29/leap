import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:leap/utils/color_utils.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexStringToColor("#4E0189"),
      body: Center(
        child: SpinKitCircle(
          size: 80,
          itemBuilder: (context, index){
            final colors = [Colors.white];
            final color = colors[index % colors.length];
            return DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              )
            );
          },
        ),
      ),
    );
  }
}
