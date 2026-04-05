# Picture Description Assessment Module

## Overview

The Picture Description Assessment module is a comprehensive Flutter feature that evaluates user descriptions of images using a hybrid scoring approach. It combines fast rule-based scoring with optional on-device LLM-based evaluation for a balanced offline-first assessment experience.

## Architecture

### Key Components

#### 1. **Models** (`models/picture_model.dart`)

- `Picture` - Represents an image with descriptions at different CEFR levels
- `ScoreBreakdown` - Score components (grammar, vocabulary, accuracy, detail)
- `RuleBasedScoringResult` - Result from rule-based evaluation
- `LlmScoringResult` - Result from LLM evaluation
- `PictureScore` - Combined hybrid scoring result

#### 2. **Services**

##### ModelManager (`services/model_manager.dart`)

Manages lazy loading of LLM models:

- Checks if GGUF model exists locally
- Downloads models from remote storage with progress tracking
- Stores models in app documents directory
- Shows UI banner when model is unavailable

**Key Methods:**

- `initialize()` - Check for existing models
- `downloadModel()` - Async model download
- `deleteModel()` - Clean up downloaded models
- `isModelAvailable` - Get model availability status

**Features:**

- Offline operation (no download needed)
- ~500MB model size (TinyLlama default)
- Progress tracking for downloads
- Error handling with user feedback

##### RuleEngine (`services/rule_engine.dart`)

Fast rule-based scoring (runs instantly, no ML required):

- **Grammar (0-25)** - Sentence structure, punctuation, capitalization
- **Vocabulary (0-25)** - Word diversity and word length
- **Accuracy (0-25)** - Keyword matching against required elements
- **Detail (0-25)** - Response length and descriptiveness

**Scoring Algorithm:**

```
final_score = (grammar + vocabulary + accuracy + detail) / 4
```

Always available, never blocks UI.

##### LLMService (`services/llm_service.dart`)

On-device LLM inference interface:

- `LLMService` - Abstract interface
- `LLMServiceStub` - Stub implementation for development

**Responsibilities:**

- Load GGUF models via native FFI (llama.cpp)
- Run inference with structured JSON output
- Temperature: 0.2 (low randomness)
- Max tokens: 150

**JSON Output Format:**

```json
{
  "score": 75.0,
  "level": "B1",
  "breakdown": {
    "grammar": 19,
    "vocabulary": 18,
    "accuracy": 20,
    "detail": 18
  },
  "feedback": "Good description with clear details"
}
```

##### PromptBuilder (`services/llm_service.dart`)

Generates structured evaluation prompts:

- Provides system instructions
- Includes image context
- Lists key elements/keywords
- Handles JSON response parsing safely

##### ScoringService (`services/scoring_service.dart`)

Orchestrates hybrid scoring:

**Scoring Algorithm:**

1. Run RuleEngine → ruleScore (always)
2. If LLM available → run LLM → llmScore
3. **Combine:** `finalScore = 0.6 * ruleScore + 0.4 * llmScore`
4. **Fallback:** If LLM fails, use ruleScore only

**CEFR Level Assignment:**

- A1: 0-25%
- A2: 25-40%
- B1: 40-60%
- B2: 60-75%
- C1: 75-100%

##### PictureDatasetService (`services/picture_dataset_service.dart`)

Loads and manages picture datasets:

- Loads from `assets/datasets/picture_description_dataset.json`
- Caches loaded data
- Supports getting pictures by ID or first picture

#### 3. **UI Screen** (`picture_description_test_screen.dart`)

Complete assessment interface:

- Image display area
- Multi-line text input for description
- Keywords hint list
- Response timer tracking
- Submit button with loading state

**Features:**

- Model availability banner
- Download AI Pack button with progress
- Inline error handling
- Integration with AssessmentController

#### 4. **Dataset** (`assets/datasets/picture_description_dataset.json`)

Structured image dataset:

```json
[
  {
    "id": 1,
    "image_path": "assets/images/kitchen_couple.jpg",
    "keywords": ["kitchen", "cooking", "vegetables", ...],
    "cefr_levels": {
      "A1": { "description": "...", "level": "A1" },
      "A2": { "description": "...", "level": "A2" },
      ...
      "C1": { "description": "...", "level": "C1" }
    }
  }
]
```

## Integration Points

### AssessmentController Updates

Extended to support picture description results:

```dart
void addPictureDescriptionResult(AssessmentQuestionResult result)
```

### AssessmentResult Model Updates

Added picture description score calculation:

```dart
double get pictureDescriptionScore
```

### OnboardingStep Enum

New step added:

```dart
enum OnboardingStep {
  // ... existing steps ...
  pictureDescriptionTest,
  results,
}
```

### Flow Integration

```
pace → interests → grammar → sentence → listening → picture_description → results
```

### Results Screen

Added Picture Description tile showing score and description count.

## Scoring Breakdown

### Rule-Based Scoring Details

**Grammar (0-25):**

- Capitalization at start: +5
- Multiple sentences: +5
- Punctuation quality: +5
- Comma usage (complex sentences): +5
- Common structures (is/are/the): +5

**Vocabulary (0-25):**

- Diversity: unique_words / total_words × 20 (max 20)
- Long words (>5 chars): +5 (bonus)

**Accuracy (0-25):**

- Keywords found / total keywords × 25

**Detail (0-25):**

- 50+ words: 25
- 40+ words: 22
- 30+ words: 18
- 20+ words: 15
- 10+ words: 10
- 5+ words: 5
- Descriptive adjectives: +2 (bonus)

### LLM Scoring Details

- Based on CEFR-aligned rubric
- Each component: 0-25
- Returns feedback text
- Uses reference description for context

## Offline-First Design

### Always Available

- Rule-based scoring works without LLM
- Fast evaluation (< 100ms)
- No internet required

### Optional Enhancement

- LLM model download is optional
- User prompted with banner notification
- Download happens in background
- Graceful degradation if download fails

### Storage Strategy

- Models stored in app documents directory
- Not bundled in APK
- Lazy loaded on first use
- User can delete to free space

## Error Handling

**Model Download Errors:**

- Show error message to user
- Disable download button
- Allow retry

**LLM Inference Errors:**

- Log error
- Fall back to rule-based score
- Continue assessment
- No user disruption

**Empty Input:**

- Validate before submission
- Show snackbar message
- Prevent submission

**JSON Parse Errors:**

- Safely handle malformed LLM output
- Return null result
- Fall back to rule-based

## Performance Considerations

- Rule engine: ~10-50ms (local only)
- LLM inference: 1-3s (on-device, can be slow)
- Runs in isolate to prevent UI blocking
- Limits token generation to 150 tokens
- Temperature 0.2 for consistent output

## Testing the Module

### For Development (No LLM):

1. Rule-based scoring works immediately
2. Model download button shows but not required
3. All assessments use rule engine

### For Full Feature (With LLM):

1. Click "Download AI Pack"
2. Wait for download completion
3. Re-run assessment for LLM scoring
4. See combined scores and feedback

### Sample Test Inputs:

**Short (low score):**

```
Two people.
```

**Medium (medium score):**

```
A man and woman are in a kitchen.
The woman is cutting vegetables.
The man is cooking.
```

**Detailed (high score):**

```
The image shows a couple preparing a meal in their well-lit kitchen.
The woman is carefully slicing red and yellow peppers on a cutting board,
while the man stirs contents in a pot on the stove.
They appear happy and engaged in the cooking process.
```

## Future Enhancements

1. **Multiple Images** - Support more pictures in dataset
2. **Custom Models** - Allow Phi-3 Mini for high-end devices
3. **Streaming Inference** - Show live token generation
4. **Image Processing** - Optional image analysis for accuracy
5. **User Feedback** - Detailed tips for improvement
6. **Offline Training** - Fine-tune models on user responses

## Files Summary

```
picture_description_test/
├── models/
│   └── picture_model.dart (Models)
├── services/
│   ├── model_manager.dart (Model downloads)
│   ├── rule_engine.dart (Fast scoring)
│   ├── llm_service.dart (LLM interface + stub)
│   ├── scoring_service.dart (Hybrid scoring)
│   └── picture_dataset_service.dart (Data loading)
├── picture_description_test_screen.dart (UI)
└── picture_description.dart (Exports)
```

## Dependencies

- flutter: ^3.0
- path_provider: ^2.1.5 (for model storage)

Native dependencies (future):

- llama.cpp (via FFI for LLM inference)
