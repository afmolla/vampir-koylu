/// Varsayilan misafir / kullanici avatarlari (DiceBear).
class UserDefaults {
  static const _base =
      'https://api.dicebear.com/7.x/avataaars/png?seed=';

  static String avatarForNick(String nick) =>
      '$_base${Uri.encodeComponent(nick.trim().isEmpty ? 'guest' : nick)}';
}
