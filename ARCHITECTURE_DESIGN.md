# Architecture & Design Documentation

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    PostLoginOnboardingScreen                     │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Navigation Flow:                                        │   │
│  │ 1. Learning Pace Selection                              │   │
│  │ 2. Interest Selection                                   │   │
│  │ 3. GrammarTestScreen                                    │   │
│  │ 4. SentenceCompletionTestScreen                         │   │
│  │ 5. Results Collection                                   │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                                   │
                    ┌──────────────┼──────────────┐
                    │              │              │
                    ▼              ▼              ▼
        ┌──────────────────┐  ┌──────────────────┐
        │ GrammarTestScreen│  │ Sentence         │
        │                  │  │ Completion       │
        │ ┌──────────────┐ │  │ TestScreen       │
        │ │ LoadQuestions│ │  │                  │
        │ │ Display Q&A  │ │  │ ┌──────────────┐ │
        │ │ Start Timer  │ │  │ │ LoadQuestions│ │
        │ │ Track Answer │ │  │ │ Display Q&A  │ │
        │ │ Record Time  │ │  │ │ Start Timer  │ │
        │ └──────────────┘ │  │ │ Track Answer │ │
        │                  │  │ │ Record Time  │ │
        │ 3 Questions:     │  │ └──────────────┘ │
        │ • Easy           │  │                  │
        │ • Medium         │  │ 3 Questions:     │
        │ • Hard           │  │ • Easy           │
        │                  │  │ • Medium         │
        └──────────────────┘  │ • Hard           │
                              │                  │
                              └──────────────────┘
                                   │
                    ┌──────────────┴──────────────┐
                    │                             │
                    ▼                             ▼
        ┌──────────────────────────┐  ┌─────────────────────────┐
        │ GrammarTestService       │  │ SentenceTestService     │
        │                          │  │                         │
        │ • loadAllQuestions()     │  │ • loadAllQuestions()    │
        │ • getQuestionsByDifficulty    │ • getQuestionsByDifficulty  │
        │ • getRandomQuestions()   │  │ • getRandomQuestions()  │
        │ • clearCache()           │  │ • clearCache()          │
        │                          │  │                         │
        │ Singleton Pattern        │  │ Singleton Pattern       │
        │ Caches JSON data         │  │ Caches JSON data        │
        └──────────────────────────┘  └─────────────────────────┘
                    │                             │
        ┌───────────┴─────────────┐   ┌──────────┴───────────────┐
        │                         │   │                          │
        ▼                         ▼   ▼                          ▼
    ┌─────────────────────┐  ┌──────────────────┐  ┌───────────────────┐
    │ JSON Asset File:    │  │ GrammarQuestion  │  │ Sentence Question │
    │ grammar_questions   │  │ Model            │  │ Model             │
    │ _dataset.json       │  │                  │  │                   │
    │                     │  │ • id             │  │ • id              │
    │ Structure:          │  │ • question       │  │ • question        │
    │ [{                  │  │ • optionA/B/C/D  │  │ • optionA/B/C/D   │
    │   id: 1,            │  │ • correctAnswer  │  │ • correctAnswer   │
    │   question: "...",  │  │ • difficulty     │  │ • difficulty      │
    │   option_a: "...",  │  │ • options        │  │ • options         │
    │   option_b: "...",  │  │ • optionMap      │  │ • optionMap       │
    │   option_c: "...",  │  │ • isAnswerCorrect()  │ • isAnswerCorrect()   │
    │   option_d: "...",  │  │                  │  │ • fromJson()      │
    │   correct_answer: "b",  │                  │  │                   │
    │   difficulty: "easy"│  │                  │  │                   │
    │ }, ...]            │  └──────────────────┘  └───────────────────┘
    │                     │
    └─────────────────────┘
                                       │
                                       ▼
                        ┌──────────────────────────────┐
                        │ AssessmentController         │
                        │                              │
                        │ • addGrammarResult()         │
                        │ • addSentenceResult()        │
                        │ • getFinalResult()           │
                        │ • clearResults()             │
                        │ • reset()                    │
                        │                              │
                        │ Manages:                     │
                        │ • grammarResults[]           │
                        │ • sentenceResults[]          │
                        └──────────────────────────────┘
                                       │
                                       ▼
                        ┌──────────────────────────────┐
                        │ AssessmentResult             │
                        │                              │
                        │ Contains:                    │
                        │ • grammarResults[]           │
                        │ • sentenceResults[]          │
                        │ • completedAt: DateTime      │
                        │                              │
                        │ Calculated Properties:       │
                        │ • grammarScore (0-100)       │
                        │ • sentenceScore (0-100)      │
                        │ • overallScore (0-100)       │
                        │ • grammarAvgTime             │
                        │ • sentenceAvgTime            │
                        │                              │
                        │ Methods:                     │
                        │ • toMap() -> JSON            │
                        └──────────────────────────────┘
                                       │
                                       ▼
                        ┌──────────────────────────────┐
                        │ AssessmentQuestionResult     │
                        │                              │
                        │ • questionId: int            │
                        │ • sectionType: String        │
                        │ • difficulty: String         │
                        │ • selectedAnswer: String     │
                        │ • correctAnswer: String      │
                        │ • isCorrect: bool            │
                        │ • responseTime: double       │
                        │                              │
                        │ Methods:                     │
                        │ • toMap() -> JSON            │
                        └──────────────────────────────┘
```

---

## Data Flow Sequence Diagram

```
User                GrammarTestScreen      GrammarService      UI Widget
 │                        │                     │                  │
 ├─ Navigate to Test ─────>│                     │                  │
 │                        │                     │                  │
 │                        ├─ Load Questions ───>│                  │
 │                        │                     ├─ Read JSON       │
 │                        │                     │<─ Parse JSON ────┤
 │                        │<─ Return Questions ─┤                  │
 │                        │                     │                  │
 │                        ├─ Filter by Level   │                  │
 │                        ├─ Random Select     │                  │
 │                        ├─ Shuffle Order     │                  │
 │                        │                     │                  │
 │                        ├─ Start Timer ──────────────────────────┤
 │                        │                     │                  │
 │<─ Display Question ────────────────────────────────────────────┤
 │                        │                     │                  │
 │ (Read & Process)       │                     │                  │
 │                        │                     │                  │
 ├─ Select Answer ───────>│                     │                  │
 │                        ├─ Validate Answer   │                  │
 │                        ├─ Stop Timer        │                  │
 │                        ├─ Check Correctness │                  │
 │                        ├─ Create Result ────┐                  │
 │                        │                    │                  │
 │                        ├─ Save to Controller│                  │
 │                        │                    │                  │
 ├─ Press Next ──────────>│                    │                  │
 │                        ├─ More Questions?   │                  │
 │                        ├─ Yes: Next Q ──────┐                  │
 │                        │<─────────────────────┘                  │
 │                        ├─ Start Timer ──────────────────────────┤
 │                        │                     │                  │
 │<─ Display Next Q ──────────────────────────────────────────────┤
 │                        │                     │                  │
 │ (Repeat for 3 Qs)      │                     │                  │
 │                        │                     │                  │
 │                        ├─ No: Complete ─────┐                  │
 │                        │<────────────────────┘                  │
 │                        │                     │                  │
 ├─ onCompleted() ───────>│                     │                  │
 │                        ├─ Navigate Next ─────────────────────── ┤
```

---

## State Management Flow

```
┌─────────────────────────────────────────────────┐
│ GrammarTestScreen State                         │
│                                                  │
│ Variables:                                       │
│ • _questions: List<GrammarQuestion>             │
│ • _currentQuestionIndex: int                    │
│ • _selectedAnswer: String?                      │
│ • _stopwatch: Stopwatch                         │
│ • _isLoading: bool                              │
│ • _error: String?                               │
│                                                  │
│ Lifecycle:                                       │
│                                                  │
│ initState()                                      │
│   ├─ Initialize _stopwatch                      │
│   └─ Call _loadQuestions()                      │
│                                                  │
│ _loadQuestions()                                 │
│   ├─ Set _isLoading = true                      │
│   ├─ Await service.getRandomQuestions()         │
│   ├─ Set _questions                             │
│   ├─ Start _stopwatch                           │
│   └─ Set _isLoading = false                     │
│                                                  │
│ _handleNext()                                    │
│   ├─ If no _selectedAnswer:                     │
│   │  └─ Show error SnackBar                     │
│   ├─ If _selectedAnswer exists:                 │
│   │  ├─ Stop _stopwatch                         │
│   │  ├─ Calculate responseTime                  │
│   │  ├─ Check answer correctness                │
│   │  ├─ Create AssessmentQuestionResult         │
│   │  ├─ Add to controller                       │
│   │  └─ If last question:                       │
│   │     └─ Call onCompleted()                   │
│   │  └─ Else:                                   │
│   │     ├─ Increment _currentQuestionIndex      │
│   │     ├─ Clear _selectedAnswer                │
│   │     ├─ Reset _stopwatch                     │
│   │     └─ Start _stopwatch                     │
│                                                  │
│ build()                                          │
│   ├─ If _isLoading: Show spinner                │
│   ├─ If _error: Show error                      │
│   └─ Else: Show question UI                     │
│                                                  │
│ dispose()                                        │
│   ├─ Stop _stopwatch                            │
│   └─ Clean resources                            │
└─────────────────────────────────────────────────┘
```

---

## Question Selection Algorithm

```
FUNCTION getRandomQuestionsForAssessment()
  INPUT: none
  OUTPUT: List<Question> (3 shuffled questions)

  STEP 1: Load all questions
    allQuestions = loadAllQuestions()

  STEP 2: Filter by difficulty
    easyQuestions = filter(allQuestions, difficulty="easy")
    mediumQuestions = filter(allQuestions, difficulty="medium")
    hardQuestions = filter(allQuestions, difficulty="hard")

  STEP 3: Random selection (one from each)
    easyQ = randomSelect(easyQuestions)
    mediumQ = randomSelect(mediumQuestions)
    hardQ = randomSelect(hardQuestions)

  STEP 4: Combine
    selectedQuestions = [easyQ, mediumQ, hardQ]

  STEP 5: Shuffle
    shuffle(selectedQuestions)

  RETURN selectedQuestions
END FUNCTION
```

---

## Scoring Calculation Flow

```
┌─────────────────────────────────────┐
│ Result Collection & Scoring         │
└─────────────────────────────────────┘

FOR each Grammar Question answered:
  ├─ Record: questionId
  ├─ Record: sectionType = "grammar"
  ├─ Record: difficulty (easy/medium/hard)
  ├─ Record: selectedAnswer
  ├─ Record: correctAnswer
  ├─ Calculate: isCorrect = (selectedAnswer == correctAnswer)
  ├─ Calculate: responseTime = stopwatch.elapsed / 1000
  └─ Create: AssessmentQuestionResult
     └─ Add to: assessmentController.grammarResults[]

FOR each Sentence Question answered:
  ├─ Record: questionId
  ├─ Record: sectionType = "sentence_completion"
  ├─ Record: difficulty (easy/medium/hard)
  ├─ Record: selectedAnswer
  ├─ Record: correctAnswer
  ├─ Calculate: isCorrect = (selectedAnswer == correctAnswer)
  ├─ Calculate: responseTime = stopwatch.elapsed / 1000
  └─ Create: AssessmentQuestionResult
     └─ Add to: assessmentController.sentenceResults[]

CALCULATE SCORES:

  grammarScore = (correctCount(grammarResults) / 3) * 100

  sentenceScore = (correctCount(sentenceResults) / 3) * 100

  overallScore = (grammarScore + sentenceScore) / 2

  grammarAvgTime = sum(responseTime) / 3

  sentenceAvgTime = sum(responseTime) / 3

RESULT OBJECT:
  AssessmentResult {
    grammarResults: [QuestionResult, QuestionResult, QuestionResult],
    sentenceCompletionResults: [QuestionResult, QuestionResult, QuestionResult],
    completedAt: DateTime.now(),

    // Calculated properties
    grammarScore: double (0-100),
    sentenceCompletionScore: double (0-100),
    overallScore: double (0-100),
    grammarAverageResponseTime: double,
    sentenceCompletionAverageResponseTime: double,
  }
```

---

## Timer Management Lifecycle

```
Timeline of Timer for Single Question:

T=0 seconds: Question appears on screen
  └─ _stopwatch.start()
     └─ Timer begins counting

T=2 seconds: User reads question
  └─ Timer running (elapsed = 2s)

T=3.5 seconds: User selects answer
  └─ _stopwatch still running (elapsed = 3.5s)

T=5.8 seconds: User presses Next
  └─ Check if answer selected
  └─ If not: Show error
  └─ If yes:
     ├─ _stopwatch.stop()
     ├─ responseTime = 5.8 seconds
     ├─ Save responseTime to result
     ├─ Add result to controller
     └─ Move to next question

Next Question:
  ├─ _stopwatch.reset()
  ├─ _stopwatch.start()
  └─ New timer for next question

After Last Question:
  └─ onCompleted() callback triggered
     └─ _stopwatch stopped in dispose()
```

---

## Error Handling Flow

```
┌─────────────────────────────────────┐
│ Error Scenarios & Handling          │
└─────────────────────────────────────┘

SCENARIO 1: JSON File Not Found
  ├─ rootBundle.loadString() throws exception
  ├─ Caught in try-catch
  ├─ Set _error = 'Failed to load questions: $e'
  ├─ Set _isLoading = false
  └─ UI shows error message

SCENARIO 2: JSON Parse Error
  ├─ json.decode() throws exception
  ├─ Caught in try-catch
  ├─ Set _error = 'Failed to load questions: $e'
  ├─ Set _isLoading = false
  └─ UI shows error message

SCENARIO 3: No Answer Selected
  ├─ User presses Next without selecting
  ├─ Check: if (_selectedAnswer == null)
  ├─ Show SnackBar: 'Please select an answer'
  ├─ Return from _handleNext()
  └─ Stay on same question

SCENARIO 4: Empty Question List
  ├─ Filter returns no questions for difficulty
  ├─ randomSelect() throws on empty list
  ├─ Exception caught
  ├─ Set _error message
  └─ UI shows error state

SCENARIO 5: No Difficulty Match
  ├─ Unlikely but handled
  ├─ getQuestionsByDifficulty() filters by string
  ├─ If no match: empty list returned
  ├─ randomSelect() would throw
  ├─ Exception handled
  └─ Error displayed

ALL ERRORS:
  ├─ Logged to console (print statements)
  ├─ Displayed to user in UI
  ├─ Prevent data corruption
  └─ Allow user to understand issue
```

---

## Class Diagram

```
┌─────────────────────────────────────────┐
│         GrammarQuestion                 │
├─────────────────────────────────────────┤
│ - id: int                               │
│ - question: String                      │
│ - optionA: String                       │
│ - optionB: String                       │
│ - optionC: String                       │
│ - optionD: String                       │
│ - correctAnswer: String                 │
│ - difficulty: String                    │
├─────────────────────────────────────────┤
│ + options: List<String>                 │
│ + optionMap: Map<String, String>        │
│ + isAnswerCorrect(String): bool         │
│ + fromJson(Map): GrammarQuestion        │
└─────────────────────────────────────────┘
           △
           │ inherits structure
           │
┌─────────────────────────────────────────┐
│    SentenceCompletionQuestion           │
├─────────────────────────────────────────┤
│ (identical structure to GrammarQuestion)│
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  AssessmentQuestionResult               │
├─────────────────────────────────────────┤
│ - questionId: int                       │
│ - sectionType: String                   │
│ - difficulty: String                    │
│ - selectedAnswer: String                │
│ - correctAnswer: String                 │
│ - isCorrect: bool                       │
│ - responseTime: double                  │
├─────────────────────────────────────────┤
│ + toMap(): Map<String, dynamic>         │
└─────────────────────────────────────────┘
           △
           │ multiple instances
           │
┌─────────────────────────────────────────┐
│      AssessmentResult                   │
├─────────────────────────────────────────┤
│ - grammarResults: List<Result>          │
│ - sentenceResults: List<Result>         │
│ - completedAt: DateTime                 │
├─────────────────────────────────────────┤
│ + grammarScore: double                  │
│ + sentenceScore: double                 │
│ + overallScore: double                  │
│ + grammarAvgTime: double                │
│ + sentenceAvgTime: double               │
│ + toMap(): Map<String, dynamic>         │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  AssessmentController                   │
├─────────────────────────────────────────┤
│ - grammarResults: List<Result>          │
│ - sentenceResults: List<Result>         │
├─────────────────────────────────────────┤
│ + addGrammarResult(Result): void        │
│ + addSentenceResult(Result): void       │
│ + getFinalResult(): Result?             │
│ + clearResults(): void                  │
│ + reset(): void                         │
│ + notifyListeners(): void               │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  GrammarTestService                     │
├─────────────────────────────────────────┤
│ - _allQuestions: List<GrammarQuestion>? │
│ - _random: Random                       │
├─────────────────────────────────────────┤
│ + loadAllQuestions(): List<Q>           │
│ + getQuestionsByDifficulty(...): List   │
│ + getRandomQuestionsForAssessment()     │
│ + clearCache(): void                    │
│ - _selectRandomQuestion(...): Question  │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  SentenceTestService                    │
├─────────────────────────────────────────┤
│ - _allQuestions: List<SQuestion>?       │
│ - _random: Random                       │
├─────────────────────────────────────────┤
│ + loadAllQuestions(): List<SQ>          │
│ + getQuestionsByDifficulty(...): List   │
│ + getRandomQuestionsForAssessment()     │
│ + clearCache(): void                    │
│ - _selectRandomQuestion(...): SQuestion │
└─────────────────────────────────────────┘
```

---

## Dependency Injection Diagram

```
PostLoginOnboardingScreen
│
├─ Creates: AssessmentController
│           └─ Passed to GrammarTestScreen
│           └─ Passed to SentenceTestScreen
│
├─ GrammarTestScreen
│  └─ Uses: GrammarTestService (singleton)
│           ├─ Loads: grammar_questions_dataset.json
│           └─ Returns: List<GrammarQuestion>
│
└─ SentenceCompletionTestScreen
   └─ Uses: SentenceTestService (singleton)
            ├─ Loads: sentence_dataset.json
            └─ Returns: List<SentenceCompletionQuestion>
```

---

This architecture ensures:

- ✅ Separation of concerns
- ✅ Reusable components
- ✅ Easy testing
- ✅ Efficient caching
- ✅ Proper error handling
- ✅ Scalability for future enhancements
