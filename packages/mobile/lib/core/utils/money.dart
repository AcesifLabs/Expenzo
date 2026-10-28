double roundMoney(double amount) {
  final rounded = (amount * 100).roundToDouble() / 100;

  return rounded == 0 ? 0.0 : rounded;
}
