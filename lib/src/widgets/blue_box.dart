import 'package:balance/src/models/balance_model.dart';
import 'package:balance/src/services/database_service.dart';
import 'package:flutter/material.dart';

class BlueBox extends StatelessWidget {
  const BlueBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: StreamBuilder<BalanceModel>(
        stream: DatabaseService.getBalance(),
        initialData: BalanceModel(leftCounter: 0, rightCounter: 0),
        builder: (context, snapshot) {
          return Row(
            children: [
              counterBox(snapshot.data?.leftCounter??0),
              const Spacer(),
              counterBox(snapshot.data?.rightCounter??0),
            ],
          );
        }
      ),
    );
  }

  Widget counterBox(int count) {
    return Container(
      color: Colors.white,
      height: 40,
      constraints: const BoxConstraints(
        minWidth: 60,
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.all(5),
      child: Text(count.toString()),
    );
  }
}
