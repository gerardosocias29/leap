import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../app_theme.dart';
import '../main.dart';

class GridList extends StatefulWidget {
  const GridList({Key? key, this.callBack, this.chapters}) : super(key: key);

  final callBack;
  // ignore: prefer_typing_uninitialized_variables
  final chapters;
  @override
  State<GridList> createState() => _GridListState();
}

class _GridListState extends State<GridList> with TickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: GridView(
        padding: const EdgeInsets.all(8),
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 32.0,
          crossAxisSpacing: 32.0,
          childAspectRatio: 0.8,
        ),
        children: List<Widget>.generate(
          widget.chapters.length,
              (int index) {
            final int count = widget.chapters.length;
            final Animation<double> animation =
            Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animationController!,
                curve: Interval((1 / count) * index, 1.0,
                    curve: Curves.fastOutSlowIn),
              ),
            );
            animationController?.forward();
            return CategoryView(
              category: widget.chapters[index],
              animation: animation,
              animationController: animationController,
              callback: widget.callBack,
            );
          },
        ),
      ),
    );
  }
}

class CategoryView extends StatelessWidget {
  const CategoryView(
      {Key? key,
        required this.category,
        this.animationController,
        this.animation,
        this.callback})
      : super(key: key);

  final callback;
  final category;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                100 * (1.0 - animation!.value), 0.0, 0.0),
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: () => callback(category), // Updated line
              child: SizedBox(
                width: 280,
                child: Stack(
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 48,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: HexColor('#F8FAFB'),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(16.0)),
                              ),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 48 + 24.0,
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(top: 16),
                                            child: Text(
                                              '${category['chapter_name']}',
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 20,
                                                letterSpacing: 1,
                                                color: AppTheme.darkerText,
                                              ),
                                            ),
                                          ),
                                          const Expanded(
                                            child: SizedBox(),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16, bottom: 8),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  '${category['lesson_count']} lesson${(category['lesson_count']) > 1 ? 's' : ''}',
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w200,
                                                    fontSize: 12,
                                                    letterSpacing: 0.27,
                                                    color: AppTheme.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 16, right: 16),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: <Widget>[
                                                const Text(
                                                  '',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 18,
                                                    letterSpacing: 0.27,
                                                    color: AppTheme.nearlyBlue,
                                                  ),
                                                ),
                                                Container(
                                                  decoration: const BoxDecoration(
                                                    color: AppTheme.nearlyBlue,
                                                    borderRadius:
                                                    BorderRadius.all(
                                                        Radius.circular(
                                                            8.0)),
                                                  ),
                                                  child: const Padding(
                                                    padding:
                                                    EdgeInsets.all(
                                                        4.0),
                                                    child: Icon(
                                                      Icons.chevron_right,
                                                      color: AppTheme.nearlyWhite,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 24, bottom: 24, left: 16),
                        child: Row(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: Image.asset(category['photo_url']),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}