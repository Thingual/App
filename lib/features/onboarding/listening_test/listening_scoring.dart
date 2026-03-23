String normalizeForListeningScore(String input) {
  var text = input.toLowerCase();
  text = text.replaceAll(RegExp(r"[^a-z0-9\s']"), ' ');
  text = text.replaceAll(RegExp(r"\s+"), ' ').trim();
  return text;
}

List<String> _tokenizeWords(String input) {
  final normalized = normalizeForListeningScore(input);
  if (normalized.isEmpty) return const [];
  return normalized.split(' ');
}

int _levenshtein(List<String> a, List<String> b) {
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  final prev = List<int>.generate(b.length + 1, (i) => i);
  final curr = List<int>.filled(b.length + 1, 0);

  for (var i = 1; i <= a.length; i++) {
    curr[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      curr[j] = [
        curr[j - 1] + 1,
        prev[j] + 1,
        prev[j - 1] + cost,
      ].reduce((x, y) => x < y ? x : y);
    }

    for (var j = 0; j <= b.length; j++) {
      prev[j] = curr[j];
    }
  }

  return prev[b.length];
}

/// Returns a similarity score from 0.0 to 1.0 based on word-level edit distance.
///
/// - 1.0 means identical after normalization.
/// - 0.0 means completely different (or one side empty).
double listeningSimilarityScore({
  required String expected,
  required String actual,
}) {
  final expectedWords = _tokenizeWords(expected);
  final actualWords = _tokenizeWords(actual);

  if (expectedWords.isEmpty && actualWords.isEmpty) return 1.0;
  if (expectedWords.isEmpty || actualWords.isEmpty) return 0.0;

  final distance = _levenshtein(expectedWords, actualWords);
  final denom = expectedWords.length > actualWords.length
      ? expectedWords.length
      : actualWords.length;

  final score = 1.0 - (distance / denom);
  if (score < 0) return 0.0;
  if (score > 1) return 1.0;
  return score;
}
