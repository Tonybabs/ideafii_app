import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/ideas/idea_blueprint.dart';
import 'profile_store.dart';

class AiService {
  static Future<IdeaBlueprint> generateBlueprint(
    String idea, {
    String? modifier,
    String? mode,
    bool allowAnonymous = false,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if ((user == null || user.email == null) &&
        !(allowAnonymous || kDebugMode)) {
      throw Exception('Sign in with email to generate a blueprint');
    }

    final profile = await ProfileStore.load();

    final response = await Supabase.instance.client.functions.invoke(
      'generate-blueprint',
      body: {
        'idea': idea,
        if (modifier != null && modifier.trim().isNotEmpty)
          'modifier': modifier.trim(),
        if (mode != null && mode.trim().isNotEmpty)
          'blueprint_mode': mode.trim(),
        'user_profile': profile?.toJson(),
      },
    );

    if (response.data == null) {
      throw Exception('AI returned empty response');
    }

    final data = response.data;
    final normalized = data is Map<String, dynamic>
        ? {...data, 'blueprintMode': mode ?? 'full'}
        : {'blueprintMode': mode ?? 'full'};
    final blueprint = IdeaBlueprint.fromJson(normalized);

    // ✅ Save to Supabase (only if signed in)
    if (user != null && user.email != null) {
      await Supabase.instance.client.from('blueprints').insert({
        'user_id': user.id,
        'idea': idea,
        'blueprint': blueprint.toJson(),
      });
    }

    return blueprint;
  }
}
