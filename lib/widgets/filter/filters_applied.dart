import 'package:boldo/models/filters/Filter.dart';
import 'package:boldo/widgets/filter/filter_applied_card.dart';
import 'package:flutter/material.dart';

class FiltersApplied<T extends Filter> extends StatelessWidget{

  final bool wrapContent;
  final T filter;
  final Function(T filter)? filterCallback;

  FiltersApplied({
    super.key,
    required this.filter,
    this.wrapContent = false,
    this.filterCallback,
  });

  @override
  Widget build(BuildContext context) {

    Widget separator = const SizedBox(
      width: 4,
      height: 4,
    );

    if(filter.filters.isNotEmpty) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: Row(
          children: filter.filters.entries
              .toList()
              .asMap()
              .entries
              .map((entry) {
            Widget child = FilterAppliedCard(
              text: entry.value.key,
              removeFilter: (){
                entry.value.value.call();
                filterCallback?.call(filter);
              },
            );

            Widget? result;

            if (entry.key != 0) {
              result = Row(
                children: [
                  separator,
                  child,
                ],
              );
            } else {
              result = child;
            }

            return result;
          }).toList(),
        ),
      );
    }else{
      return Container();
    }
  }

}