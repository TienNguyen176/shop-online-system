import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiUrl => dotenv.env["API_URL"]!;
  static String get googleServerClientId =>
      dotenv.env["GOOGLE_SERVER_CLIENT_ID"]!;
}
