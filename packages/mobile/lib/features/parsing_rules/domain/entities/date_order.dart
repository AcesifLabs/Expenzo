enum DateOrder {
  dmy,

  mdy;

  static DateOrder fromName(String? name) => name == mdy.name ? mdy : dmy;
}
