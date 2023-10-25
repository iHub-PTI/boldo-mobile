import 'package:flutter/material.dart';

class AppNavigatorObserver extends NavigatorObserver {

  static List<Route> _routeStack = [];

  static bool containRoute({required String routeName}){
    return _routeStack.any((element) => element.settings.name == routeName);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _routeStack.add(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _routeStack.remove(route);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    _routeStack.remove(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if(oldRoute!= null && newRoute!= null) {
      final index = _routeStack.indexOf(oldRoute);
      _routeStack[index] = newRoute;
    }
  }
}