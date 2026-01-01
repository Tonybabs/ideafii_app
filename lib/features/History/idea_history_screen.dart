import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ideas/idea_blueprint.dart';
import '../ideas/idea_blueprint_screen.dart';

class IdeaHistoryScreen extends StatelessWidget {
  const IdeaHistoryScreen({super.key});

  Future<List<Map<String, dynamic>>> _loadIdeas() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;

    final response = await Supabase.instance.client
        .from('ideas')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const _SavedIdeasTitle(),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadIdeas(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final ideas = snapshot.data!;
          if (ideas.isEmpty) {
            return const Center(
              child: Text(
                'No ideas yet',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            itemCount: ideas.length,
            itemBuilder: (context, index) {
              final item = ideas[index];
              final blueprint =
                  IdeaBlueprint.fromJson(item['blueprint']);
              final ideaInput = (item['idea_input'] ?? '').toString();

              return ListTile(
                title: Text(
                  item['idea_input'],
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  blueprint.summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          IdeaBlueprintScreen(
                            blueprint: blueprint,
                            ideaInput: ideaInput,
                            ideaTitle: ideaInput,
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _SavedIdeasTitle extends StatelessWidget {
  const _SavedIdeasTitle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Saved Ideas 📌'),
        SizedBox(height: 2),
        Text(
          'Your curated collection of business ideas',
          style: TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}
