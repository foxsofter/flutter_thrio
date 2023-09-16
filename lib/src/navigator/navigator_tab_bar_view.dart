import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'navigator_page_view.dart';

/// A page view that displays the widget which corresponds to the currently
/// selected tab.
///
/// This widget is typically used in conjunction with a [TabBar].
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=POtoEH-5l40}
///
/// If a [TabController] is not provided, then there must be a [DefaultTabController]
/// ancestor.
///
/// The tab controller's [TabController.length] must equal the length of the
/// [children] list and the length of the [TabBar.tabs] list.
///
/// To see a sample implementation, visit the [TabController] documentation.
class NavigatorTabBarView extends StatefulWidget {
  /// Creates a page view with one child per tab.
  ///
  /// The length of [children] must be the same as the [controller]'s length.
  const NavigatorTabBarView({
    super.key,
    required this.routeSettings,
    this.keepIndex = false,
    this.childBuilder,
    this.controller,
    this.physics,
    this.dragStartBehavior = DragStartBehavior.start,
    this.viewportFraction = 1.0,
    this.clipBehavior = Clip.hardEdge,
  });

  /// This widget's selection and animation state.
  ///
  /// If [TabController] is not provided, then the value of [DefaultTabController.of]
  /// will be used.
  final TabController? controller;

  /// One RouteSettings per tab.
  ///
  /// Its length must match the length of the [TabBar.tabs]
  /// list, as well as the [controller]'s [TabController.length].
  final List<RouteSettings> routeSettings;

  final bool keepIndex;

  final Widget Function(
    BuildContext context,
    RouteSettings settings,
    Widget child,
  )? childBuilder;

  /// How the page view should respond to user input.
  ///
  /// For example, determines how the page view continues to animate after the
  /// user stops dragging the page view.
  ///
  /// The physics are modified to snap to page boundaries using
  /// [PageScrollPhysics] prior to being used.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics? physics;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// {@macro flutter.widgets.pageview.viewportFraction}
  final double viewportFraction;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  @override
  State<NavigatorTabBarView> createState() => _NavigatorTabBarViewState();
}

class _NavigatorTabBarViewState extends State<NavigatorTabBarView> {
  TabController? _controller;
  late PageController _pageController;
  int? _currentIndex;
  int _warpUnderwayCount = 0;
  bool _debugHasScheduledValidChildrenCountCheck = false;

  // If the TabBarView is rebuilt with a new tab controller, the caller should
  // dispose the old one. In that case the old controller's animation will be
  // null and should not be accessed.
  bool get _controllerIsValid => _controller?.animation != null;

  void _updateTabController() {
    final newController = widget.controller ?? DefaultTabController.of(context);
    assert(() {
      // ignore: unnecessary_null_comparison
      if (newController == null) {
        throw FlutterError(
          'No TabController for ${widget.runtimeType}.\n'
          'When creating a ${widget.runtimeType}, you must either provide an explicit '
          'TabController using the "controller" property, or you must ensure that there '
          'is a DefaultTabController above the ${widget.runtimeType}.\n'
          'In this case, there was neither an explicit controller nor a default controller.',
        );
      }
      return true;
    }());

    if (newController == _controller) {
      return;
    }

    if (_controllerIsValid) {
      _controller!.animation!.removeListener(_handleTabControllerAnimationTick);
    }
    _controller = newController;
    if (_controller != null) {
      _controller!.animation!.addListener(_handleTabControllerAnimationTick);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTabController();
    _currentIndex = _controller!.index;
    _pageController = PageController(
      initialPage: _currentIndex!,
      viewportFraction: widget.viewportFraction,
    );
  }

  @override
  void didUpdateWidget(NavigatorTabBarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _updateTabController();
      _currentIndex = _controller!.index;
      _warpUnderwayCount += 1;
      _pageController.jumpToPage(_currentIndex!);
      _warpUnderwayCount -= 1;
    }
  }

  @override
  void dispose() {
    if (_controllerIsValid) {
      _controller!.animation!.removeListener(_handleTabControllerAnimationTick);
    }
    _controller = null;
    // We don't own the _controller Animation, so it's not disposed here.
    super.dispose();
  }

  void _handleTabControllerAnimationTick() {
    if (_warpUnderwayCount > 0 || !_controller!.indexIsChanging) {
      return;
    } // This widget is driving the controller's animation.

    if (_controller!.index != _currentIndex) {
      _currentIndex = _controller!.index;
      _warpToCurrentIndex();
    }
  }

  Future<void> _warpToCurrentIndex() async {
    if (!mounted) {
      return Future<void>.value();
    }

    if (_pageController.page == _currentIndex!.toDouble()) {
      return Future<void>.value();
    }

    final duration = _controller!.animationDuration;
    final previousIndex = _controller!.previousIndex;

    if ((_currentIndex! - previousIndex).abs() == 1) {
      if (duration == Duration.zero) {
        _pageController.jumpToPage(_currentIndex!);
        return Future<void>.value();
      }
      _warpUnderwayCount += 1;
      await _pageController.animateToPage(_currentIndex!,
          duration: duration, curve: Curves.ease);
      _warpUnderwayCount -= 1;
      return Future<void>.value();
    }

    assert((_currentIndex! - previousIndex).abs() > 1);
    final initialPage = _currentIndex! > previousIndex
        ? _currentIndex! - 1
        : _currentIndex! + 1;
    setState(() {
      _warpUnderwayCount += 1;
    });
    _pageController.jumpToPage(initialPage);

    if (duration == Duration.zero) {
      _pageController.jumpToPage(_currentIndex!);
      return Future<void>.value();
    }

    await _pageController.animateToPage(_currentIndex!,
        duration: duration, curve: Curves.ease);
    if (!mounted) {
      return Future<void>.value();
    }
    setState(() {
      _warpUnderwayCount -= 1;
    });
  }

  // Called when the PageView scrolls
  bool _handleScrollNotification(ScrollNotification notification) {
    if (_warpUnderwayCount > 0) {
      return false;
    }

    if (notification.depth != 0) {
      return false;
    }

    _warpUnderwayCount += 1;
    if (notification is ScrollUpdateNotification &&
        !_controller!.indexIsChanging) {
      if ((_pageController.page! - _controller!.index).abs() > 1.0) {
        _controller!.index = _pageController.page!.round();
        _currentIndex = _controller!.index;
      }
      _controller!.offset =
          clampDouble(_pageController.page! - _controller!.index, -1.0, 1.0);
    } else if (notification is ScrollEndNotification) {
      _controller!.index = _pageController.page!.round();
      _currentIndex = _controller!.index;
      if (!_controller!.indexIsChanging) {
        _controller!.offset =
            clampDouble(_pageController.page! - _controller!.index, -1.0, 1.0);
      }
    }
    _warpUnderwayCount -= 1;

    return false;
  }

  bool _debugScheduleCheckHasValidChildrenCount() {
    if (_debugHasScheduledValidChildrenCountCheck) {
      return true;
    }
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      _debugHasScheduledValidChildrenCountCheck = false;
      if (!mounted) {
        return;
      }
      assert(() {
        if (_controller!.length != widget.routeSettings.length) {
          throw FlutterError(
            "Controller's length property (${_controller!.length}) does not match the "
            "number of children (${widget.routeSettings.length}) present in TabBarView's children property.",
          );
        }
        return true;
      }());
    });
    _debugHasScheduledValidChildrenCountCheck = true;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    assert(_debugScheduleCheckHasValidChildrenCount());

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: NavigatorPageView(
        dragStartBehavior: widget.dragStartBehavior,
        clipBehavior: widget.clipBehavior,
        controller: _pageController,
        physics: widget.physics == null
            ? const PageScrollPhysics().applyTo(const ClampingScrollPhysics())
            : const PageScrollPhysics().applyTo(widget.physics),
        routeSettings: widget.routeSettings,
        keepIndex: widget.keepIndex,
        childBuilder: widget.childBuilder,
      ),
    );
  }
}
