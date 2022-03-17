import 'package:boldo/constants.dart';
import 'package:flutter/material.dart';

class DataFetchErrorWidget extends StatelessWidget {
  final Function() retryCallback;
  const DataFetchErrorWidget({Key? key, required this.retryCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Ocurrió un error",
            style: TextStyle(
                color: Constants.otherColor100,
                fontSize: 18,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 17),
          Container(
            child: const Text(
              "Algo salió mal mientras cargaba tus datos",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Constants.extraColor300,
                  fontWeight: FontWeight.w400,
                  fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: retryCallback,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text("Reintentar"),
            ),
          )
        ],
      ),
    );
  }
}
