import 'package:balance/src/models/balance_model.dart';
import 'package:balance/src/services/database_service.dart';
import 'package:balance/src/widgets/blue_box.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {

  TextEditingController leftTextController = TextEditingController();
  TextEditingController rightTextController = TextEditingController();

  late AnimationController _rotateController;
  bool isResetting = false;

  @override
  void initState() {
    DatabaseService.updateBalance(BalanceModel(leftCounter: 0, rightCounter: 0));
    _rotateController = AnimationController(
      lowerBound: -1.0,
      upperBound: 1.0,
      value: 0.0,
      vsync: this,
    );

    // Updating firebase database with the text count
    leftTextController.addListener(() {
      if(!isResetting) {
        DatabaseService.updateBalance(BalanceModel(leftCounter: leftTextController.text.length, rightCounter: rightTextController.text.length));
      }
    });

    // Updating firebase database with the text count
    rightTextController.addListener(() {
      if(!isResetting) {
        DatabaseService.updateBalance(BalanceModel(leftCounter: leftTextController.text.length, rightCounter: rightTextController.text.length));
      }
    });

    // Rotating box based on data received back from firebase database
    DatabaseService.getBalance().listen((event) {
      _rotateController.animateTo((event.rightCounter - event.leftCounter) * 0.001, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });

    _rotateController.addListener(() async {
      setState(() {});
      if(_rotateController.value.abs() >= 0.125){
        isResetting = true;
        _rotateController.animateBack(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut).whenComplete(() {
          isResetting = false;
          rightTextController.clear();
          leftTextController.clear();
        });
        DatabaseService.updateBalance(BalanceModel(leftCounter: 0, rightCounter: 0));
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Balance"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height*0.3,
              child: Row(
                children: [
                  Expanded(child: textContainer(leftTextController)),
                  Expanded(child: textContainer(rightTextController)),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: (rightTextController.text.length - leftTextController.text.length) < 0 ? RotationTransition(
                turns: Tween(begin: -1.0, end: 1.0).animate(_rotateController),
                alignment: Alignment.centerRight,
                child: const BlueBox(),
              ) : RotationTransition(
                turns: Tween(begin: -1.0, end: 1.0).animate(_rotateController),
                alignment: Alignment.centerLeft,
                child: const BlueBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget textContainer(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black)
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.done,
        style: const TextStyle(color: Colors.black),
        expands: true,
        maxLines: null,
        decoration: const InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          hintText: 'TYPE HERE...',
          hintStyle: TextStyle(fontSize: 14, color: Colors.black54),
          contentPadding: EdgeInsets.all(10),
        ),
      ),
    );
  }
}
