import 'package:boldo/widgets/loading.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class CustomFormButton extends StatelessWidget {
  final bool loading;
  final String text;
  final void Function() actionCallback;
  const CustomFormButton(
      {Key? key, this.text = "Confirmar", required this.loading, required this.actionCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Constants.primaryColor500,
        ),
        onPressed: loading ? null : actionCallback,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              Row(
                children: [
                  SizedBox(
                    height: 16,
                    width: 16,
                    child: loadingStatus(),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            Text(text),
          ],
        ),
      ),
    );
  }
}
