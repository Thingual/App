# Integration Guide - Onboarding Assessment

## Quick Start

### 1. Assets Already Configured

The `pubspec.yaml` has been updated to include the dataset assets:

```yaml
flutter:
  assets:
    - assets/datasets/grammar_questions_dataset.json
    - assets/datasets/sentence_dataset.json
```

Run `flutter pub get` to ensure assets are properly recognized.

### 2. Navigation Integration

The `PostLoginOnboardingScreen` now has 4 steps:

1. **Pace Selection** (existing)
2. **Interest Selection** (existing)
3. **Grammar Test** (new)
4. **Sentence Completion Test** (new)

Navigation flow is automatic:

```dart
PostLoginOnboardingScreen
  ├─ Step 1: Learning Pace
  ├─ Step 2: Select Interests
  ├─ Step 3: Grammar Assessment (3 questions)
  └─ Step 4: Sentence Completion (3 questions)
```

### 3. Getting Assessment Results

After both tests are completed:

```dart
final result = assessmentController.getFinalResult();

// Access scores
final grammarScore = result?.grammarScore;        // 0-100
final sentenceScore = result?.sentenceCompletionScore;  // 0-100
final overallScore = result?.overallScore;        // 0-100

// Access details
final grammarResults = result?.grammarResults;    // List of question results
final sentenceResults = result?.sentenceCompletionResults;

// Access timing data
final grammarAvgTime = result?.grammarAverageResponseTime;
final sentenceAvgTime = result?.sentenceCompletionAverageResponseTime;
```

## Module Details

### GrammarTestScreen

```dart
GrammarTestScreen(
  assessmentController: assessmentController,
  onCompleted: () {
    // Called when all 3 grammar questions are answered
    // Navigate to next screen or save progress
  },
)
```

**Features:**

- Loads 3 random questions (1 easy, 1 medium, 1 hard)
- Shuffles question order
- Tracks response time for each question
- Validates answers against correct answers
- Shows progress indicator
- Prevents advancement without answer selection

### SentenceCompletionTestScreen

```dart
SentenceCompletionTestScreen(
  assessmentController: assessmentController,
  onCompleted: () {
    // Called when all 3 sentence questions are answered
    // Complete assessment or show results
  },
)
```

**Features:**

- Same functionality as Grammar Test
- Different dataset (sentence completions)
- Identical UI/UX pattern for consistency

### AssessmentController

```dart
final controller = AssessmentController();

// Add results (done automatically by screens)
controller.addGrammarResult(result);
controller.addSentenceResult(result);

// Get final results
final finalResult = controller.getFinalResult();

// Reset for new assessment
controller.reset();
```

## Data Flow

### Question Selection Algorithm

```
1. Load all questions from JSON
2. Filter by difficulty:
   - Get all "easy" questions
   - Get all "medium" questions
   - Get all "hard" questions
3. Random selection:
   - Pick 1 random question from easy list
   - Pick 1 random question from medium list
   - Pick 1 random question from hard list
4. Shuffle:
   - Combine 3 questions into list
   - Shuffle the list
5. Display in shuffled order
```

### Result Recording

When user answers a question and presses Next:

```
1. Stop timer (record elapsed time)
2. Check if answer is correct
3. Create AssessmentQuestionResult with:
   - Question ID
   - Section type (grammar/sentence_completion)
   - Difficulty level
   - Selected answer
   - Correct answer
   - Is correct (boolean)
   - Response time (seconds)
4. Add to AssessmentController
5. Move to next question
```

## Error Handling

The screens handle:

- **Missing dataset files** - Shows error message
- **Empty question lists** - Shows error message
- **JSON parsing errors** - Shows error message
- **No answer selected** - Shows SnackBar, prevents advancement
- **Loading state** - Shows loading spinner

## Performance Considerations

### Singleton Pattern

Both `GrammarTestService` and `SentenceTestService` use singleton pattern:

```dart
// Only loads JSON once, caches results
final service = GrammarTestService();
final questions1 = await service.getRandomQuestionsForAssessment();
final questions2 = await service.getRandomQuestionsForAssessment(); // Uses cache
```

### Memory Efficient

- Questions are loaded once and reused
- Random selection creates no copies of entire dataset
- Timers cleaned up properly in `dispose()`

### Cache Management

```dart
// Clear cache if needed (e.g., for testing)
service.clearCache();
```

## Customization

### Modifying Question Count

To change from 3 questions to a different number:

**In service file:**

```dart
// Change the selection logic in getRandomQuestionsForAssessment()
final selectedQuestions = [
  _selectRandomQuestion(easyQuestions),
  _selectRandomQuestion(mediumQuestions),
  _selectRandomQuestion(hardQuestions),
  // Add more selections here
];
```

### Changing Difficulty Distribution

To use different difficulties (e.g., 2 medium, 1 hard):

```dart
final selectedQuestions = [
  _selectRandomQuestion(mediumQuestions),
  _selectRandomQuestion(mediumQuestions),
  _selectRandomQuestion(hardQuestions),
];
```

### Customizing Scoring

Modify `AssessmentResult` class:

```dart
// Different scoring formula (e.g., weighted scoring)
double get grammarScore {
  // Implement custom scoring logic
}
```

## Testing

### Manual Testing Checklist

- [ ] Grammar test loads correctly
- [ ] 3 questions appear with different difficulties
- [ ] Questions are shuffled each time
- [ ] Timer works for each question
- [ ] Answer selection works
- [ ] Navigation to sentence test works
- [ ] Sentence test completes successfully
- [ ] Results are calculated correctly
- [ ] Scores are displayed properly

### Unit Testing Example

```dart
test('Grammar service returns 3 questions', () async {
  final service = GrammarTestService();
  final questions = await service.getRandomQuestionsForAssessment();

  expect(questions.length, equals(3));
  expect(
    questions.where((q) => q.difficulty == 'easy').length,
    equals(1),
  );
});
```

## Troubleshooting

### Questions not loading

1. Check assets are in `assets/datasets/` directory
2. Verify `pubspec.yaml` has correct asset paths
3. Run `flutter pub get`
4. Run `flutter clean`

### Timer not working

1. Ensure `_stopwatch` is started in `initState`
2. Verify `_stopwatch` is stopped in `dispose`
3. Check response time calculation: `_stopwatch.elapsedMilliseconds / 1000.0`

### Incorrect scoring

1. Verify question's `correct_answer` matches option values exactly
2. Check case sensitivity in answer comparison
3. Ensure correct dataset is being used

### Navigation issues

1. Verify `onCompleted` callbacks are properly set
2. Check `AssessmentController` state is not null
3. Ensure screens are calling callbacks at correct time

## Next Steps

After assessment completion, you can:

1. **Save Results to Backend**

   ```dart
   await api.saveAssessmentResults(result.toMap());
   ```

2. **Navigate to Next Screen**

   ```dart
   Navigator.of(context).pushNamed('/learn-page');
   ```

3. **Show Results Summary**

   ```dart
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text('Overall Score: ${result.overallScore}%')),
   );
   ```

4. **Start Main Learning Flow**
   ```dart
   // Use assessment results to personalize learning path
   final userLevel = _determineUserLevel(result);
   ```

## Support

For issues or questions about the implementation:

1. Check the error messages in the UI
2. Review logs for JSON parsing errors
3. Verify dataset structure matches expected format
4. Ensure all files are in correct directories
