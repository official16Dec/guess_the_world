import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const GuessTheWorldApp());

class GuessTheWorldApp extends StatelessWidget {
  const GuessTheWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guess the World',
      debugShowCheckedModeBanner: false,

      // Light Theme
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF426B5A),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F2),
        fontFamily: 'Roboto',
      ),

      // Dark Theme
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF426B5A),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121A17),
        fontFamily: 'Roboto',
      ),

      // Follow the device's theme setting
      themeMode: ThemeMode.system,

      home: const GamePage(),
    );
  }
}

enum Difficulty { easy, medium, hard }

class QuizItem {
  final String answer;
  final String category;
  final String imageAsset;

  const QuizItem({
    required this.answer,
    required this.category,
    required this.imageAsset,
  });
}

const List<QuizItem> questions = [
  QuizItem(
    answer: 'Eiffel Tower',
    category: 'Famous places',
    imageAsset:
    'assets/images/eiffel_tower.jpg',
  ),
  QuizItem(
    answer: 'Lion',
    category: 'Animals',
    imageAsset:
    'assets/images/lion.jpg',
  ),
  QuizItem(
    answer: 'Banana',
    category: 'Fruits',
    imageAsset:
    'assets/images/banana.jpg',
  ),
  QuizItem(
    answer: 'Broccoli',
    category: 'Vegetables',
    imageAsset:
    'assets/images/broccoli.jpg',
  ),
  QuizItem(
    answer: 'Apple',
    category: 'Fruits',
    imageAsset:
    'assets/images/apple.jpg',
  ),
  QuizItem(
    answer: 'Elephant',
    category: 'Animals',
    imageAsset:
    'assets/images/elephant.jpg',
  ),
  QuizItem(
    answer: 'Taj Mahal',
    category: 'Famous places',
    imageAsset:
    'assets/images/taj_mahal.jpg',
  ),
  QuizItem(
    answer: 'Carrot',
    category: 'Vegetables',
    imageAsset:
    'assets/images/carrot.jpg',
  ),
  QuizItem(
    answer: 'Guitar',
    category: 'Everyday things',
    imageAsset:
    'assets/images/guitar.jpg',
  ),
  QuizItem(
    answer: 'Giraffe',
    category: 'Animals',
    imageAsset:
    'assets/images/giraffe.jpeg',
  ),
  QuizItem(
    answer: 'Strawberry',
    category: 'Fruits',
    imageAsset:
    'assets/images/strawberry.jpg',
  ),
  QuizItem(
    answer: 'Pyramid',
    category: 'Famous places',
    imageAsset:
    'assets/images/pyramid.jpg',
  ),
];

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final Random _random = Random();
  final TextEditingController _answerController = TextEditingController();

  Difficulty _difficulty = Difficulty.easy;
  int _questionIndex = 0;
  int _score = 0;
  bool? _isCorrect;
  bool _answered = false;
  late List<QuizItem> _round;
  late List<String> _options;

  QuizItem get _current => _round[_questionIndex];
  int get _total => _round.length;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _startGame() {
    final pool = List<QuizItem>.from(questions)..shuffle(_random);
    _round = pool.take(min(10, pool.length)).toList();
    _questionIndex = 0;
    _score = 0;
    _answered = false;
    _isCorrect = null;
    _answerController.clear();
    _makeOptions();
    setState(() {});
  }

  void _makeOptions() {
    final numberOfOptions = switch (_difficulty) {
      Difficulty.easy => 4,
      Difficulty.medium => 2,
      Difficulty.hard => 0,
    };

    if (numberOfOptions == 0) {
      _options = [];
      return;
    }

    final wrongAnswers = questions
        .where((item) => item.answer != _current.answer)
        .map((item) => item.answer)
        .toList()
      ..shuffle(_random);

    _options = [
      _current.answer,
      ...wrongAnswers.take(numberOfOptions - 1),
    ]..shuffle(_random);
  }

  void _checkAnswer(String value) {
    if (_answered) return;
    final correct = value.trim().toLowerCase() == _current.answer.toLowerCase();
    setState(() {
      _answered = true;
      _isCorrect = correct;
      if (correct) _score++;
    });
  }

  void _submitTypedAnswer() {
    _checkAnswer(_answerController.text);
  }

  void _nextQuestion() {
    if (_questionIndex >= _total - 1) {
      _showResults();
      return;
    }
    setState(() {
      _questionIndex++;
      _answered = false;
      _isCorrect = null;
      _answerController.clear();
      _makeOptions();
    });
  }

  void _showResults() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Round complete! 🎉'),
        content: Text('You scored $_score out of $_total.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startGame();
            },
            child: const Text('Play again'),
          ),
        ],
      ),
    );
  }

  String get _difficultyLabel => switch (_difficulty) {
    Difficulty.easy => 'Easy',
    Difficulty.medium => 'Medium',
    Difficulty.hard => 'Hard',
  };

  String get _difficultyHint => switch (_difficulty) {
    Difficulty.easy => 'Choose the correct answer from 4 options',
    Difficulty.medium => 'Choose the correct answer from 2 options',
    Difficulty.hard => 'Type the answer in English',
  };

  @override
  Widget build(BuildContext context) {
    final progress = (_questionIndex + 1) / _total;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guess the World',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Center(
              child: Chip(
                avatar: const Icon(Icons.stars_rounded, size: 18),
                label: Text('$_score points'),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Question ${_questionIndex + 1} of $_total',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    DropdownButton<Difficulty>(
                      value: _difficulty,
                      underline: const SizedBox.shrink(),
                      borderRadius: BorderRadius.circular(14),
                      items: Difficulty.values
                          .map(
                            (level) => DropdownMenuItem(
                          value: level,
                          child: Text(switch (level) {
                            Difficulty.easy => 'Easy',
                            Difficulty.medium => 'Medium',
                            Difficulty.hard => 'Hard',
                          }),
                        ),
                      )
                          .toList(),
                      onChanged: (level) {
                        if (level == null) return;
                        setState(() {
                          _difficulty = level;
                          _answered = false;
                          _isCorrect = null;
                          _answerController.clear();
                          _makeOptions();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                /*ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFE1E8E0),
                  ),
                ),
                const SizedBox(height: 12),*/
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Image.asset(
                          _current.imageAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.image_not_supported)
                            );
                          }
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _current.category.toUpperCase(),
                              style: const TextStyle(
                                letterSpacing: 1.4,
                                color: Color(0xFF557565),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'What is this?',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _difficultyHint,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.black54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (_difficulty != Difficulty.hard)
                  ..._options.asMap().entries.map((entry) {
                    final option = entry.value;
                    final isAnswer = option == _current.answer;
                    Color? background;
                    Color? foreground;
                    if (_answered && isAnswer) {
                      background = const Color(0xFFDDF3E3);
                      foreground = const Color(0xFF175D35);
                    } else if (_answered && _isCorrect == false && !isAnswer) {
                      background = Colors.white;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            backgroundColor: background,
                            foregroundColor: foreground,
                            side: BorderSide(
                              color: _answered && isAnswer
                                  ? const Color(0xFF5AA776)
                                  : const Color(0xFFDCE3DA),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed:
                          _answered ? null : () => _checkAnswer(option),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF0E8),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Text(
                                  String.fromCharCode(65 + entry.key),
                                  style: const TextStyle(
                                    color: Color(0xFF426B5A),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  option,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (_answered && isAnswer)
                                const Icon(Icons.check_circle_rounded),
                            ],
                          ),
                        ),
                      ),
                    );
                  })
                else
                  Column(
                    children: [
                      TextField(
                        controller: _answerController,
                        enabled: !_answered,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submitTypedAnswer(),
                        decoration: InputDecoration(
                          hintText: 'Type the name in English...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                            const BorderSide(color: Color(0xFFDCE3DA)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                            const BorderSide(color: Color(0xFFDCE3DA)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _answered ? null : _submitTypedAnswer,
                          child: const Text('Check answer'),
                        ),
                      ),
                    ],
                  ),
                if (_answered) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _isCorrect == true
                          ? const Color(0xFFDDF3E3)
                          : const Color(0xFFFFE8E3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _isCorrect == true
                              ? Icons.check_circle_rounded
                              : Icons.info_rounded,
                          color: _isCorrect == true
                              ? const Color(0xFF217346)
                              : const Color(0xFFB3442F),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _isCorrect == true
                                ? 'Correct! Great job.'
                                : 'Not quite. The answer is ${_current.answer}.',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: _nextQuestion,
                      icon: Icon(
                        _questionIndex == _total - 1
                            ? Icons.emoji_events_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                      label: Text(
                        _questionIndex == _total - 1
                            ? 'See results'
                            : 'Next question',
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _startGame,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Restart round'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
