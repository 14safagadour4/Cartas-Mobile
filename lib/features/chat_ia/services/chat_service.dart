import 'package:cartas/core/services/api_service.dart';

class ChatService {
  static Future<String> getTawhidaResponse(String message) async {
    try {
      // Direct raw string body expected by the backend controller
      final response = await ApiService.post('/tawhida/chat', {'message': message});
      
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return "Désolée y'a benti, famma mochkla sghira fel connexion. 🌿";
      }
    } catch (e) {
      return "Désolée mon enfant, je ne parviens pas à me connecter pour le moment. Réessayons plus tard.";
    }
  }
}
