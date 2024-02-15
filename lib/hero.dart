import 'package:flutter/material.dart';

Widget getHero(int index, String url) {
  return Hero(
    tag: "image-$index",
    flightShuttleBuilder: (
      BuildContext flightContext,
      Animation<double> animation,
      HeroFlightDirection flightDirection,
      BuildContext fromHeroContext,
      BuildContext toHeroContext,
    ) {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          return Material(
            type: MaterialType.transparency,
            child: SizedBox(
              height: 75,
              width: 75,
              child: Image.network(
                url,
                // height: 75,
                // width: 75,
              ),
            ),
          );
        },
      );
    },
    child: Material(
      color: Colors.transparent,
      child: SizedBox(
        height: 75,
        width: 75,
        child: Image.network(
          url,
          // height: 75,
          // width: 75,
        ),
      ),
    ),
  );
}
