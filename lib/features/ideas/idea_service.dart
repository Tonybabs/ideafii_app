import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/ai_service.dart';
import '../../services/entitlements_service.dart';
import 'idea_blueprint.dart';

class IdeaService {
  static final _client = Supabase.instance.client;

  static Future<IdeaBlueprint> saveIdea({
    required String ideaInput,
    String mode = 'lite',
    bool allowAnonymous = false,
  }) async {
    final user = _client.auth.currentUser;
    if ((user == null || user.email == null) &&
        !(allowAnonymous || kDebugMode)) {
      throw Exception('Sign in with email to generate a blueprint');
    }

    // 1️⃣ Generate blueprint
    final blueprint = await AiService.generateBlueprint(
      ideaInput,
      mode: mode,
      allowAnonymous: allowAnonymous || kDebugMode,
    );

    // 2️⃣ Save to Supabase (only if signed in)
    if (user != null && user.email != null) {
      await _client.from('ideas').insert({
        'user_id': user.id,
        'title': ideaInput.length > 40 ? ideaInput.substring(0, 40) : ideaInput,
        'idea_input': ideaInput,
        'blueprint': blueprint.toJson(),
      });
    }

    await EntitlementsService.recordBlueprintGeneration(mode);

    // 3️⃣ Return blueprint for UI
    return blueprint;
  }
}
