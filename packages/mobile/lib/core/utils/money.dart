/// [amount] rounded to 2 decimals, the precision every stored amount keeps
/// (ADR 0014). `-0.0` comes back as `0.0`.
double roundMoney(double amount) {
  final rounded = (amount * 100).roundToDouble() / 100;

  return rounded == 0 ? 0.0 : rounded;
}
