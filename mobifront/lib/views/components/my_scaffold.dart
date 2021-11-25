import 'package:flutter/material.dart';
import 'package:mobifront/utils/utl.dart';

class MyScaffold extends StatefulWidget {
  final Widget child;
  final String? title;
  final bool showNavBar;
  final Future<void> Function()? onRefresh;
  final Widget? actionWidget;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const MyScaffold({
    Key? key,
    required this.child,
    this.title,
    this.onRefresh,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.showNavBar = true,
    this.actionWidget,
  }) : super(key: key);

  @override
  State<MyScaffold> createState() => _MyScaffoldState();
}

class _MyScaffoldState extends State<MyScaffold> {
  late ScrollController _scrollController;

  bool lastStatus = true;

  _scrollListener() {
    if (isShrink != lastStatus) {
      setState(() {
        lastStatus = isShrink;
        //Utl.log("encolhido", this.isShrink);
      });
    }
  }

  bool get isShrink {
    return _scrollController.hasClients &&
        _scrollController.offset > (100 - kToolbarHeight);
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  double getHeight() {
    Utl.log("offset", _scrollController.offset);
    double height = 100 - _scrollController.offset;
    if (height > 60) return 60;
    if (height < 30) return 30;
    return height;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      backgroundColor: Colors.white, //Color.fromARGB(255, 249, 251, 253),
      body: RefreshIndicator(
        onRefresh: widget.onRefresh ?? () async {},
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: NestedScrollView(
              body: ListView(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                children: [
                  widget.child,
                ],
              ),
              controller: _scrollController,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                      pinned: true,
                      automaticallyImplyLeading: false,
                      snap: false,
                      floating: true,
                      centerTitle: true,
                      expandedHeight: 150,
                      bottom: PreferredSize(
                          preferredSize:
                              Size(MediaQuery.of(context).size.width, 52),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 2.0, left: 8, right: 8, top: 2),
                            child: Stack(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: 48,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 48,
                                        child: Center(
                                          child: (widget.title != null)
                                              ? Text(widget.title!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline6!
                                                      .apply(
                                                          color: isShrink
                                                              ? Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                              : Colors.white))
                                              : Container(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: 48,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        (Navigator.canPop(context))
                                            ? IconButton(
                                                icon: Icon(
                                                  Icons.arrow_back_ios,
                                                  color: isShrink
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Colors.white,
                                                ),
                                                onPressed: () {
                                                  Future.delayed(Duration.zero,
                                                      () {
                                                    if (Navigator.canPop(
                                                        context)) {
                                                      try {
                                                        Navigator.pop(context);
                                                      } catch (e) {
                                                        Utl.log(
                                                            "Erro ao voltar",
                                                            e.toString());
                                                      }
                                                    } else {
                                                      Navigator.pushNamed(
                                                          context, '/home');
                                                    }
                                                  });
                                                },
                                              )
                                            : Container(),
                                        widget.actionWidget ?? Container()
                                      ]),
                                ),
                              ],
                            ),
                          )),
                      flexibleSpace: AnimatedContainer(
                        color: isShrink
                            ? Colors.white
                            : Theme.of(context).primaryColor,
                        duration: const Duration(seconds: 1),
                        child: Opacity(
                          opacity: isShrink ? 0.0 : 1,
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 70),
                              child: widget.actionWidget != null && isShrink
                                  ? Container()
                                  : Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16.0),
                                      child: Image.asset(
                                        'assets/images/logomobilus-182w.png',
                                        fit: BoxFit.fitHeight,
                                        //height: ,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      )),
                ];
              }),
        ),
      ),
    ));
  }
}
