/// Brings all the features of modal route with ease.
/// Create dynamic modal route with state/stateless widgets

library backdrop_modal_route;

import 'package:boldo/constants.dart';
import 'package:flutter/material.dart';

const DEFAULT_BACKDROP_TOP_PADDING = 56.0;

typedef Widget OverlayContentBuilder(BuildContext context);
typedef Widget BuildBlockModalTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child);

/// abstract base, extend from this to create custom modal route
abstract class BackdropModalRouteBase<T> extends ModalRoute<T> {
  BackdropModalRouteBase({
    this.backgroundColor,
    this.topPadding,
    this.barrierOpacity,
    this.transitionDurationVal,
    this.isOpaque,
    this.canBarrierDismiss,
    this.barrierColorVal,
    this.barrierLabelVal,
    this.shouldMaintainState,
    this.backdropShape,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.maintainBottomViewPadding,
    this.buildBlockModalTransitions,
    this.isSlideTransitionDefault,
    this.hasHandle = true,
    this.handleColor = ConstantsV2.gray
  }) {
    backgroundColor ??= Colors.white;
    topPadding ??= DEFAULT_BACKDROP_TOP_PADDING;
    barrierOpacity ??= 0.5;
    transitionDurationVal ??= const Duration(milliseconds: 500);
    isOpaque ??= false;
    canBarrierDismiss ??= true;
    barrierColorVal ??= Colors.black.withOpacity(barrierOpacity!);
    shouldMaintainState ??= true;
    backdropShape ??= const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      ),
    );
    left ??= true;
    top ??= true;
    right ??= true;
    bottom ??= true;
    maintainBottomViewPadding ??= false;
    isSlideTransitionDefault ??= true;
  }

  Color? backgroundColor;
  double? topPadding;
  double? barrierOpacity;
  Duration? transitionDurationVal;
  bool? isOpaque;
  bool? canBarrierDismiss;
  Color? barrierColorVal;
  String? barrierLabelVal;
  bool? shouldMaintainState;
  ShapeBorder? backdropShape;
  bool hasHandle;
  Color handleColor;

  // provide this to give custom transition to block modal
  BuildBlockModalTransitions? buildBlockModalTransitions;

  bool? isSlideTransitionDefault;

  /// Whether to avoid system intrusions on the left.
  bool? left;

  /// Whether to avoid system intrusions at the top of the screen, typically the
  /// system status bar.
  bool? top;

  /// Whether to avoid system intrusions on the right.
  bool? right;

  /// Whether to avoid system intrusions on the bottom side of the screen.
  bool? bottom;

  /// Specifies whether the [SafeArea] should maintain the
  /// [MediaQueryData.viewPadding] instead of the [MediaQueryData.padding] when
  /// consumed by the [MediaQueryData.viewInsets] of the current context's
  /// [MediaQuery], defaults to false.
  ///
  /// For example, if there is an onscreen keyboard displayed above the
  /// SafeArea, the padding can be maintained below the obstruction rather than
  /// being consumed. This can be helpful in cases where your layout contains
  /// flexible widgets, which could visibly move when opening a software
  /// keyboard due to the change in the padding value. Setting this to true will
  /// avoid the UI shift.
  bool? maintainBottomViewPadding;

  @override
  Duration get transitionDuration => transitionDurationVal!;

  @override
  bool get opaque => isOpaque!;

  @override
  bool get barrierDismissible => canBarrierDismiss!;

  @override
  Color? get barrierColor => barrierColorVal;

  @override
  String? get barrierLabel => barrierLabelVal;

  @override
  bool get maintainState => shouldMaintainState!;

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    // This makes sure that text and other content follows the material style
    return Align(
      child: SafeArea(
        top: top!,
        bottom: bottom!,
        left: left!,
        right: right!,
        maintainBottomViewPadding: maintainBottomViewPadding!,
        child: Material(
          type: MaterialType.canvas,
          elevation: 1.0,
          color: backgroundColor,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: backdropShape,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasHandle) Icon(
                Icons.remove_rounded,
                color: handleColor,
                size: 60,
              ),
              buildOverlayContent(context),
            ],
          ),
        ),
      ),
      alignment: Alignment.bottomCenter,
    );
  }

  Widget buildOverlayContent(BuildContext context);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (buildBlockModalTransitions != null) {
      return buildBlockModalTransitions!(
          context, animation, secondaryAnimation, child);
    }

    if (isSlideTransitionDefault!) {
      // Create transition from bottom to top, like bottom sheet
      return SlideTransition(
        position: CurvedAnimation(
          parent: animation,
          curve: Curves.fastLinearToSlowEaseIn,
        ).drive(
          Tween<Offset>(
            begin: const Offset(0.0, 10.0),
            end: const Offset(0.0, 0.0),
          ),
        ),
        child: child,
      );
    }

    // Create fade transition effect
    return FadeTransition(opacity: animation, child: child);
  }
}

/// default backdrop modal
class BackdropModalRoute<T> extends BackdropModalRouteBase<T> {
  BackdropModalRoute({
    required this.overlayContentBuilder,
    Color? backgroundColor,
    double? topPadding,
    double? barrierOpacity,
    Duration? transitionDurationVal,
    bool? isOpaque,
    bool? canBarrierDismiss,
    Color? barrierColorVal,
    String? barrierLabelVal,
    bool? shouldMaintainState,
    ShapeBorder? backdropShape,
    bool? safeAreaLeft,
    bool? safeAreaTop,
    bool? safeAreaRight,
    bool? safeAreaBottom,
    EdgeInsets? safeAreaMinimumPadding,
    bool? safeAreaMaintainBottomViewPadding,
    bool isSlideTransitionDefault = true,
    BuildBlockModalTransitions? customBuildBlockModalTransitions,
  }) : super(
    backgroundColor: backgroundColor,
    topPadding: topPadding,
    barrierOpacity: barrierOpacity,
    transitionDurationVal: transitionDurationVal,
    isOpaque: isOpaque,
    canBarrierDismiss: canBarrierDismiss,
    barrierColorVal: barrierColorVal,
    barrierLabelVal: barrierLabelVal,
    shouldMaintainState: shouldMaintainState,
    backdropShape: backdropShape,
    left: safeAreaLeft,
    top: safeAreaTop,
    right: safeAreaRight,
    bottom: safeAreaBottom,
    maintainBottomViewPadding: safeAreaMaintainBottomViewPadding,
    isSlideTransitionDefault: isSlideTransitionDefault,
    buildBlockModalTransitions: customBuildBlockModalTransitions,
  );

  final OverlayContentBuilder overlayContentBuilder;

  @override
  Widget buildOverlayContent(BuildContext context) {
    return overlayContentBuilder(context);
  }
}
