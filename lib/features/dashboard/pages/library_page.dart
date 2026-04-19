import 'package:flutter/material.dart';
import '../../../core/constants/brand_colors.dart';
import '../../../core/constants/theme.dart';
import '../../../shared/widgets/thingual_widgets.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final _searchController = TextEditingController();
  List<_VocabularyWord> _filteredWords = _sampleVocabulary;

  void _filterWords(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredWords = _sampleVocabulary;
      } else {
        _filteredWords = _sampleVocabulary
            .where((word) =>
                word.word.toLowerCase().contains(query.toLowerCase()) ||
                word.meaning.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.all(isMobile ? ThingualSpacing.lg : ThingualSpacing.xl),
        children: [
        // Header
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vocabulary Library',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: ThingualSpacing.sm),
            Text(
              'Master ${_sampleVocabulary.length} essential words',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: ThingualSpacing.xl),

        // Search Bar
        TextField(
          controller: _searchController,
          onChanged: _filterWords,
          decoration: InputDecoration(
            hintText: 'Search words...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ThingualRadius.md),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ThingualRadius.md),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ThingualRadius.md),
              borderSide: const BorderSide(
                color: ThingualColors.deepIndigo,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: ThingualSpacing.xl),

        // Word Count
        Text(
          '${_filteredWords.length} word${_filteredWords.length == 1 ? '' : 's'}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: ThingualSpacing.lg),

        // Vocabulary Cards
        if (isMobile)
          Column(
            children: List.generate(
              _filteredWords.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: ThingualSpacing.lg),
                child: _VocabularyCard(word: _filteredWords[index]),
              ),
            ),
          )
        else
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: ThingualSpacing.lg,
              mainAxisSpacing: ThingualSpacing.lg,
              childAspectRatio: 1.0,
            ),
            itemCount: _filteredWords.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) =>
                _VocabularyCard(word: _filteredWords[index]),
          ),
        const SizedBox(height: ThingualSpacing.xxxl),
        ],
      ),
    );
  }
}

class _VocabularyCard extends StatelessWidget {
  final _VocabularyWord word;

  const _VocabularyCard({required this.word});

  @override
  Widget build(BuildContext context) {
    return ThingualCard(
      padding: const EdgeInsets.all(ThingualSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  word.word,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ThingualBadge(
                label: word.level,
                backgroundColor: _getLevelColor(word.level).withValues(alpha: 0.1),
                textColor: _getLevelColor(word.level),
              ),
            ],
          ),
          const SizedBox(height: ThingualSpacing.md),
          Text(
            word.meaning,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: ThingualSpacing.md),
          Text(
            '"${word.example}"',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: ThingualSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mastery',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: ThingualSpacing.xs),
                    ThingualProgressBar(
                      progress: word.mastery / 100,
                      height: 4,
                      color: _getMasteryColor(word.mastery),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ThingualSpacing.md),
              Text(
                'Due in ${word.dueInDays}d',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'A1':
        return ThingualColors.amber;
      case 'A2':
        return Colors.orange;
      case 'B1':
        return ThingualColors.vivdCyan;
      default:
        return ThingualColors.deepIndigo;
    }
  }

  Color _getMasteryColor(int mastery) {
    if (mastery >= 80) return Colors.green;
    if (mastery >= 60) return ThingualColors.amber;
    if (mastery >= 40) return Colors.orange;
    return Colors.red;
  }
}

class _VocabularyWord {
  final String word;
  final String meaning;
  final String example;
  final String level;
  final int mastery;
  final int dueInDays;

  _VocabularyWord({
    required this.word,
    required this.meaning,
    required this.example,
    required this.level,
    required this.mastery,
    required this.dueInDays,
  });
}

final _sampleVocabulary = [
  _VocabularyWord(
    word: 'Serendipity',
    meaning: 'Finding something good by chance',
    example: 'It was pure serendipity that I found this amazing café.',
    level: 'B1',
    mastery: 75,
    dueInDays: 2,
  ),
  _VocabularyWord(
    word: 'Ephemeral',
    meaning: 'Lasting for a very short time',
    example: 'The beauty of cherry blossoms is ephemeral, lasting only weeks.',
    level: 'B2',
    mastery: 45,
    dueInDays: 1,
  ),
  _VocabularyWord(
    word: 'Eloquent',
    meaning: 'Fluent and persuasive in speaking',
    example: 'Her eloquent speech moved the entire audience.',
    level: 'B1',
    mastery: 82,
    dueInDays: 3,
  ),
  _VocabularyWord(
    word: 'Benevolent',
    meaning: 'Kind and generous; showing goodwill',
    example: 'The benevolent donation helped many families in need.',
    level: 'B2',
    mastery: 60,
    dueInDays: 1,
  ),
  _VocabularyWord(
    word: 'Meticulous',
    meaning: 'Very careful and precise',
    example: 'She was meticulous in her work, never missing any details.',
    level: 'B1',
    mastery: 88,
    dueInDays: 4,
  ),
  _VocabularyWord(
    word: 'Ambiguous',
    meaning: 'Having more than one possible meaning',
    example: 'The instructions were ambiguous, causing confusion.',
    level: 'B1',
    mastery: 70,
    dueInDays: 2,
  ),
  _VocabularyWord(
    word: 'Pragmatic',
    meaning: 'Dealing with things in a practical, realistic way',
    example: 'He took a pragmatic approach to solve the business problem.',
    level: 'B2',
    mastery: 55,
    dueInDays: 1,
  ),
  _VocabularyWord(
    word: 'Ubiquitous',
    meaning: 'Present everywhere; constantly encountered',
    example: 'Smartphones have become ubiquitous in modern society.',
    level: 'B2',
    mastery: 40,
    dueInDays: 0,
  ),
];
