import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants.dart';

class ItemMenu extends StatelessWidget {
  final String image;
  final String title;
  final Widget? page;
  final String? route;
  final bool? showRightIcon;
  final void Function(BuildContext)? onTap;

  const ItemMenu({
    Key? key,
    required this.image,
    required this.title,
    this.page,
    this.route,
    this.showRightIcon = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _getCallback(context: context),
      child: Container(
        alignment: Alignment.center,
        constraints:
            const BoxConstraints(minWidth: 136, minHeight: 20, maxHeight: 38),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  image,
                  color: ConstantsV2.activeText,
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(title,
                    style: boldoTitleBlackTextStyle.copyWith(fontSize: 16))
              ],
            ),
            if (showRightIcon == true) const Icon(Icons.chevron_right)
          ],
        )
        /* TextButton.icon(
          onPressed: page == null && route == null
              ? () {}
              : route == null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => page!),
                      );
                    }
                  : () {
                      Navigator.pushNamed(context, route!);
                    },
          icon: SvgPicture.asset(
            image,
            color: ConstantsV2.activeText,
          ),
          label:
              Text(title, style: boldoTitleBlackTextStyle.copyWith(fontSize: 16)),
        ) */
        ,
      ),
    );
  }

  Function() _getCallback({required BuildContext context}) {
    switch ([route != null, page != null, onTap != null]) {
      case [true, _, _]:
        return () => Navigator.pushNamed(context, route!);
      case [false, true, _]:
        return () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page!),
            );
      case [false, false, true]:
        return () => onTap?.call(context);
      default:
        return () {};
    }
  }
}
