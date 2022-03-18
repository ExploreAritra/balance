import 'dart:convert';

import 'package:balance/src/models/balance_model.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {

  static DatabaseReference ref = FirebaseDatabase.instance.ref("users");

  static Future<void> updateBalance(BalanceModel balance) async {
    await ref.child("balance").set(balance.toJson()).catchError((error) {
      print(error.toString());
    });
  }

  static Stream<BalanceModel> getBalance() {
    Stream<DatabaseEvent> balanceData = ref.onValue;
    return balanceData.map((event) {
      String json = jsonEncode(event.snapshot.value);
      Map<String, dynamic> data = jsonDecode(json);
      BalanceModel balance = BalanceModel.fromJson(data["balance"]);
      return balance;
    });
  }

}