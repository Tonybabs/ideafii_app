import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'idea_blueprint.dart';
import 'idea_blueprint_screen.dart';
import '../ui/ideafii_ui.dart';
import '../ui/idea_card_utils.dart';
import '../ui/idea_showcase_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool loading = true;
  List<Map<String, dynamic>> ideas = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null || user.email == null) {
      setState(() {
        ideas = [];
        loading = false;
      });
      return;
    }

    final res = await client
        .from('ideas')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    if (!mounted) return;

    setState(() {
      ideas = List<Map<String, dynamic>>.from(res);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IdeafiiColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Saved'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ideas.isEmpty
              ? const Center(child: Text('No saved ideas yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: ideas.length,
                  itemBuilder: (context, i) {
                    final row = ideas[i];
                    final ideaText = (row['idea_input'] ?? '').toString();
                    final blueprintJson = row['blueprint'];
                    final blueprint = IdeaBlueprint.fromJson(blueprintJson);
                    final info = deriveIdeaCardInfo(
                      ideaText: ideaText,
                      blueprint: blueprint,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: IdeaShowcaseCard(
                        title: ideaText.isNotEmpty
                            ? ideaText
                            : 'Saved idea',
                        description: _shorten(ideaText, 140),
                        chipLabel: info.chipLabel,
                        chipColor: info.chipColor,
                        emoji: info.emoji,
                        meta: info.meta,
                        onTap: () {
                          final ideaInput = (row['idea_input'] ?? '').toString();

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => IdeaBlueprintScreen(
                                blueprint: blueprint,
                                ideaInput: ideaInput,
                                ideaTitle: ideaInput,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

String _shorten(String s, int max) {
  final t = s.trim();
  if (t.length <= max) return t;
  return '${t.substring(0, max)}…';
}
