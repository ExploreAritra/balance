import 'dart:math';

import 'package:balance/src/models/balance_model.dart';
import 'package:balance/src/services/database_service.dart';
import 'package:balance/src/widgets/blue_box.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {

  TextEditingController leftTextController = TextEditingController();
  TextEditingController rightTextController = TextEditingController();

  late AnimationController _rotateController;
  late AnimationController _slideController;
  bool isResetting = false;
  double verticalShift = 0.0;

  @override
  void initState() {
    DatabaseService.updateBalance(BalanceModel(leftCounter: 0, rightCounter: 0));
    _rotateController = AnimationController(
      lowerBound: -1.0,
      upperBound: 1.0,
      value: 0.0,
      vsync: this,
    );

    _slideController = AnimationController(
      lowerBound: 0.0,
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
    DatabaseService.getBalanceData().listen((event) {
      verticalShift += 0.0009 * ((event.rightCounter - event.leftCounter).abs() > 0 ? (event.rightCounter - event.leftCounter).abs() : 1) + ((event.rightCounter + event.leftCounter) * 0.001);
      if(event.rightCounter == 0 && event.leftCounter == 0){
        verticalShift = 0;
      }
      _rotateController.animateTo((event.rightCounter - event.leftCounter).sign * pow((event.rightCounter - event.leftCounter).abs(), 1.4) * 0.001, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
      _slideController.animateTo(verticalShift, duration: const Duration(milliseconds: 100), curve: Curves.linear);
    });

    _rotateController.addListener(() async {
      setState(() {});
      if(_rotateController.value.abs() > 0.125 || _slideController.value == 1.0){
        isResetting = true;
        verticalShift = 0;
        _rotateController.animateBack(0, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut).whenComplete(() {
          _slideController.animateBack(0, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut).whenComplete(() {
            rightTextController.clear();
            leftTextController.clear();
            isResetting = false;
          });
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
              height: size.height*0.2,
              child: Row(
                children: [
                  Expanded(child: textContainer(leftTextController)),
                  Expanded(child: textContainer(rightTextController)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: SlideTransition(
                position: Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, 4.0)).animate(CurvedAnimation(
                  parent: _slideController,
                  curve: Curves.linear,
                )),
                child: RotationTransition(
                  turns: Tween(begin: -1.0, end: 1.0).animate(_rotateController),
                  alignment: (rightTextController.text.length - leftTextController.text.length) < 0 ? Alignment.centerRight : Alignment.centerLeft,
                  child: const BlueBox(),
                ),
              ),
            ),
            const SizedBox(height: 300,),
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
