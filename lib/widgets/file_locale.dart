import 'dart:io';

import 'package:boldo/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;

class FileLocaleCard extends StatelessWidget {

  final File file;
  final Function? deleteAction;
  final String? errorMessage;

  FileLocaleCard({
    required this.file,
    this.deleteAction,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {

    String? error = errorMessage;

    return InkWell(
      onTap: () => OpenFilex.open(file.path),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: ConstantsV2.lightest,
          boxShadow: [
            shadowAttachStudy,
          ],
          border: error != null? Border.all(
            color: ConstantsV2.systemFail,
            width: 1,
          ): null,
        ),
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    child: SvgPicture.asset(p.extension(file.path).toLowerCase() == '.pdf'
                        ? 'assets/icon/picture-as-pdf.svg'
                        : 'assets/icon/crop-original.svg',
                      height: 24,
                      width: 24,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                p.basename(
                                  file.path,
                                ),
                                style: boldoCorpMediumBlackTextStyle.copyWith(
                                    color: ConstantsV2.activeText,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            SvgPicture.asset('assets/icon/chevron-right.svg'),
                          ],
                        ),
                        if(error != null)
                          const SizedBox(
                            height: 2,
                          ),
                        if(error != null)
                          Text(
                            error,
                            style: boldoBodySBlackTextStyle.copyWith(
                              color: ConstantsV2.blueDark,
                            ),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      deleteAction?.call();
                    },
                    child:Container(
                      padding: const EdgeInsets.all(10),
                      child: SvgPicture.asset(
                        'assets/icon/trash.svg',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }



}