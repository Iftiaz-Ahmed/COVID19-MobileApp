import 'package:mysql1/mysql1.dart';

class Mysql {
  static String host = '10.0.2.2',
                user = 'root',
                db = 'covid19';
  static int port = 3306;

  Mysql();

  Future<MySqlConnection> getConnection() async {
    var settings = new ConnectionSettings(
      host: host,
      port: port,
      user: user,
      db: db
    );
    return await MySqlConnection.connect(settings);
  }
}