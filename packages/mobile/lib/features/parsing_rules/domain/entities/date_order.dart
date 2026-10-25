/// How a parsing rule reads an all-numeric date (CONTEXT.md Date Order,
/// ADR 0015). Stored by [name].
enum DateOrder {
  /// 05/10/2026 is 5 October: banks in Bangladesh and India.
  dmy,

  /// 05/10/2026 is 10 May.
  mdy;

  // Stored and synced rows may have no date order.
  // ignore: unnecessary-nullable
  /// [name] as a [DateOrder]; anything else reads as [dmy].
  static DateOrder fromName(String? name) => name == mdy.name ? mdy : dmy;
}
