
class BalanceModel {
  BalanceModel({
    required this.leftCounter,
    required this.rightCounter,
  });

  final int leftCounter;
  final int rightCounter;

  factory BalanceModel.fromJson(Map<String, dynamic> json) => BalanceModel(
    leftCounter: json["left_counter"],
    rightCounter: json["right_counter"],
  );

  Map<String, dynamic> toJson() => {
    "left_counter": leftCounter,
    "right_counter": rightCounter,
  };
}
