# Assessment API Reference

## Quick API Usage Guide

### AssessmentController

**Purpose:** Manages the overall assessment workflow and collects results from both test sections.

```dart
// Create controller
final controller = AssessmentController();

// Add grammar question result
controller.addGrammarResult(
  AssessmentQuestionResult(
    questionId: 1,
    sectionType: 'grammar',
    difficulty: 'easy',
    selectedAnswer: 'goes',
    correctAnswer: 'goes',
    isCorrect: true,
    responseTime: 5.234,
  ),
);

// Add sentence completion result
controller.addSentenceResult(
  AssessmentQuestionResult(
    questionId: 2,
    sectionType: 'sentence_completion',
    difficulty: 'medium',
    selectedAnswer: 'He doesn\'t like apples.',
    correctAnswer: 'He doesn\'t like apples.',
    isCorrect: true,
    responseTime: 7.456,
  ),
);

// Get final results (only after both sections complete)
final result = controller.getFinalResult();
if (result != null) {
  print('Grammar Score: ${result.grammarScore}%');
  print('Sentence Score: ${result.sentenceCompletionScore}%');
  print('Overall Score: ${result.overallScore}%');
}

// Reset for new assessment
controller.reset();
```

---

## GrammarTestService

**Purpose:** Manages grammar questions - loading from JSON, filtering by difficulty, and random selection.

### Singleton Access

```dart
final service = GrammarTestService();
// Only one instance per app lifetime
```

### Load All Questions

```dart
final allQuestions = await service.loadAllQuestions();
// Returns: List<GrammarQuestion>
// Result is cached for efficiency
```

### Get Random Assessment Questions

```dart
final questions = await service.getRandomQuestionsForAssessment();
// Returns: List<GrammarQuestion> with 3 questions
// - 1 random easy question
// - 1 random medium question
// - 1 random hard question
// - Shuffled in random order
```

### Filter by Difficulty

```dart
final allQuestions = await service.loadAllQuestions();
final easyQuestions = service.getQuestionsByDifficulty(allQuestions, 'easy');
// Returns: List<GrammarQuestion> filtered to difficulty level

// Valid difficulty values:
// - 'easy'
// - 'medium'
// - 'hard'
```

### Clear Cache

```dart
service.clearCache();
// Useful for testing or forcing reload from file
// Next access will reload from JSON file
```

---

## SentenceTestService

**Purpose:** Manages sentence completion questions - identical API to GrammarTestService but for different dataset.

### Singleton Access

```dart
final service = SentenceTestService();
// Only one instance per app lifetime
```

### Load All Questions

```dart
final allQuestions = await service.loadAllQuestions();
// Returns: List<SentenceCompletionQuestion>
// Loads from assets/datasets/sentence_dataset.json
```

### Get Random Assessment Questions

```dart
final questions = await service.getRandomQuestionsForAssessment();
// Returns: List<SentenceCompletionQuestion> with 3 questions
// - 1 random easy question
// - 1 random medium question
// - 1 random hard question
// - Shuffled in random order
```

### Filter by Difficulty

```dart
final allQuestions = await service.loadAllQuestions();
final mediumQuestions = service.getQuestionsByDifficulty(allQuestions, 'medium');
// Returns: List<SentenceCompletionQuestion> at medium difficulty
```

---

## GrammarQuestion Model

**Purpose:** Represents a single grammar question with metadata and validation.

### Properties

```dart
final int id;                          // Unique identifier
final String question;                 // Question text
final String optionA, optionB,
      optionC, optionD;                // Answer choices
final String correctAnswer;            // Correct option text
final String difficulty;               // 'easy', 'medium', or 'hard'
```

### Methods

#### Get All Options

```dart
final question = GrammarQuestion(...);
final options = question.options;
// Returns: ['option a text', 'option b text', 'option c text', 'option d text']
```

#### Get Option Map

```dart
final optionMap = question.optionMap;
// Returns: {'A': 'option a text', 'B': 'option b text', ...}
```

#### Check Answer Correctness

```dart
final isCorrect = question.isAnswerCorrect('goes');
// Returns: bool - true if answer matches correctAnswer
```

#### Create from JSON

```dart
final question = GrammarQuestion.fromJson({
  'id': 1,
  'question': 'She ___ to the library.',
  'option_a': 'go',
  'option_b': 'goes',
  'option_c': 'going',
  'option_d': 'gone',
  'correct_answer': 'goes',
  'difficulty': 'easy',
});
```

---

## SentenceCompletionQuestion Model

**Purpose:** Represents a single sentence completion question - identical structure to GrammarQuestion.

### Properties

```dart
final int id;                          // Unique identifier
final String question;                 // Sentence to complete
final String optionA, optionB,
      optionC, optionD;                // Correction options
final String correctAnswer;            // Correct option text
final String difficulty;               // 'easy', 'medium', or 'hard'
```

### Methods

```dart
// Identical to GrammarQuestion
final options = question.options;
final optionMap = question.optionMap;
final isCorrect = question.isAnswerCorrect(selectedText);
final question = SentenceCompletionQuestion.fromJson(json);
```

---

## AssessmentQuestionResult Model

**Purpose:** Records the result of a single question answer.

### Properties

```dart
final int questionId;                  // ID of the question
final String sectionType;              // 'grammar' or 'sentence_completion'
final String difficulty;               // 'easy', 'medium', 'hard'
final String selectedAnswer;           // User's selected answer
final String correctAnswer;            // Correct answer
final bool isCorrect;                  // Whether answer was correct
final double responseTime;             // Time taken in seconds
```

### Methods

#### Convert to Map (for JSON/API)

```dart
final result = AssessmentQuestionResult(...);
final map = result.toMap();
// Returns: {
//   'questionId': 1,
//   'sectionType': 'grammar',
//   'difficulty': 'easy',
//   'selectedAnswer': 'goes',
//   'correctAnswer': 'goes',
//   'isCorrect': true,
//   'responseTime': 5.234,
// }
```

---

## AssessmentResult Model

**Purpose:** Contains overall assessment results with scoring and analytics.

### Properties

```dart
final List<AssessmentQuestionResult> grammarResults;
final List<AssessmentQuestionResult> sentenceCompletionResults;
final DateTime completedAt;
```

### Computed Properties (Getters)

#### Grammar Score

```dart
final result = assessmentController.getFinalResult();
final score = result!.grammarScore;  // Returns: 0-100
// Calculation: (correct_count / 3) * 100
```

#### Sentence Completion Score

```dart
final score = result!.sentenceCompletionScore;  // Returns: 0-100
// Calculation: (correct_count / 3) * 100
```

#### Overall Score

```dart
final score = result!.overallScore;  // Returns: 0-100
// Calculation: (grammarScore + sentenceCompletionScore) / 2
```

#### Grammar Average Response Time

```dart
final avgTime = result!.grammarAverageResponseTime;  // Returns: seconds
// Calculation: sum(all response times) / question_count
```

#### Sentence Average Response Time

```dart
final avgTime = result!.sentenceCompletionAverageResponseTime;  // Returns: seconds
```

### Methods

#### Convert to Map (for API/Storage)

```dart
final map = result!.toMap();
// Returns complete map with all scores and timing data
// Useful for sending to backend API
```

---

## Screen Components

### GrammarTestScreen

**Constructor:**

```dart
GrammarTestScreen(
  required AssessmentController assessmentController,
  required VoidCallback onCompleted,
)
```

**Parameters:**

- `assessmentController` - Controller to store results
- `onCompleted` - Callback when all questions are answered

**Behavior:**

- Loads 3 random grammar questions
- Displays one question at a time
- Tracks response time with stopwatch
- Records results on Next button
- Calls `onCompleted` when all questions answered

**Example Usage:**

```dart
GrammarTestScreen(
  assessmentController: myController,
  onCompleted: () {
    print('Grammar test complete!');
    // Navigate to next screen
    Navigator.push(context, MaterialPageRoute(...));
  },
)
```

---

### SentenceCompletionTestScreen

**Constructor:**

```dart
SentenceCompletionTestScreen(
  required AssessmentController assessmentController,
  required VoidCallback onCompleted,
)
```

**Parameters:**

- `assessmentController` - Controller to store results
- `onCompleted` - Callback when all questions are answered

**Behavior:**

- Loads 3 random sentence completion questions
- Displays one question at a time
- Tracks response time with stopwatch
- Records results on Next button
- Calls `onCompleted` when all questions answered

**Example Usage:**

```dart
SentenceCompletionTestScreen(
  assessmentController: myController,
  onCompleted: () {
    print('Sentence test complete!');
    // Get final results
    final results = myController.getFinalResult();
  },
)
```

---

## Complete Workflow Example

```dart
import 'package:flutter/material.dart';
import 'path/to/assessment_controller.dart';
import 'path/to/grammar_test_screen.dart';
import 'path/to/sentence_test_screen.dart';

class AssessmentFlow extends StatefulWidget {
  @override
  State<AssessmentFlow> createState() => _AssessmentFlowState();
}

class _AssessmentFlowState extends State<AssessmentFlow> {
  late AssessmentController _controller;
  int _step = 0; // 0 = grammar, 1 = sentence, 2 = complete

  @override
  void initState() {
    super.initState();
    _controller = AssessmentController();
  }

  void _handleGrammarComplete() {
    setState(() => _step = 1);
  }

  void _handleSentenceComplete() {
    final result = _controller.getFinalResult();
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Assessment Complete!\n'
            'Grammar: ${result.grammarScore.toStringAsFixed(1)}%\n'
            'Sentence: ${result.sentenceCompletionScore.toStringAsFixed(1)}%\n'
            'Overall: ${result.overallScore.toStringAsFixed(1)}%',
          ),
        ),
      );
      // Navigate to next screen or save results
    }
    setState(() => _step = 2);
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 0) {
      return GrammarTestScreen(
        assessmentController: _controller,
        onCompleted: _handleGrammarComplete,
      );
    } else if (_step == 1) {
      return SentenceCompletionTestScreen(
        assessmentController: _controller,
        onCompleted: _handleSentenceComplete,
      );
    } else {
      return Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to Home'),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Clean up if needed
    super.dispose();
  }
}
```

---

## Error Handling Examples

### Handling Missing Questions

```dart
try {
  final questions = await service.getRandomQuestionsForAssessment();
  if (questions.isEmpty) {
    print('No questions available');
  }
} catch (e) {
  print('Error loading questions: $e');
  // Show error UI to user
}
```

### Validating Results

```dart
final result = controller.getFinalResult();
if (result == null) {
  print('Assessment not completed yet');
  return;
}

if (result.grammarResults.isEmpty) {
  print('Grammar test not completed');
}

if (result.sentenceCompletionResults.isEmpty) {
  print('Sentence test not completed');
}
```

### Safe Score Access

```dart
final result = controller.getFinalResult();
final grammarScore = result?.grammarScore ?? 0.0;
final sentenceScore = result?.sentenceCompletionScore ?? 0.0;
final overallScore = result?.overallScore ?? 0.0;
```

---

## Data Export Examples

### Export to JSON for API

```dart
final result = controller.getFinalResult();
final json = result?.toMap();

// Send to backend
await api.post('/assessments', json);
```

### Generate Report

```dart
final result = controller.getFinalResult();
final report = '''
Assessment Report
================
Grammar Score: ${result!.grammarScore.toStringAsFixed(1)}%
Sentence Completion: ${result.sentenceCompletionScore.toStringAsFixed(1)}%
Overall Score: ${result.overallScore.toStringAsFixed(1)}%

Grammar Average Response Time: ${result.grammarAverageResponseTime.toStringAsFixed(2)}s
Sentence Average Response Time: ${result.sentenceCompletionAverageResponseTime.toStringAsFixed(2)}s

Completed: ${result.completedAt}
''';

print(report);
```

---

This API reference provides all the necessary information for integrating and using the assessment modules in your application.
