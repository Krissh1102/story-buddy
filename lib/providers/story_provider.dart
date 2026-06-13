// lib/providers/story_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/quiz_model.dart';

enum AudioState { idle, loading, playing, finished, error }

enum QuizState { hidden, visible, answered }

class StoryProvider extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  AudioState _audioState = AudioState.idle;
  QuizState _quizState = QuizState.hidden;
  String? _selectedAnswer;
  bool _isCorrect = false;
  String _errorMessage = '';

  AudioState get audioState => _audioState;
  QuizState get quizState => _quizState;
  String? get selectedAnswer => _selectedAnswer;
  bool get isCorrect => _isCorrect;
  String get errorMessage => _errorMessage;


  static const String storyText =
      'Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods...';

  static final QuizModel quizData = QuizModel.fromJson({
    'question': "What colour was Pip the Robot's lost gear?",
    'options': ['Red', 'Green', 'Blue', 'Yellow'],
    'answer': 'Blue',
  });

  StoryProvider() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.42); // child-friendly, slightly slower
    await _tts.setPitch(1.15); // slightly higher pitch for a friendly voice
    await _tts.setVolume(1.0);

    _tts.setStartHandler(() {
      _audioState = AudioState.playing;
      notifyListeners();
    });

    _tts.setCompletionHandler(() {
      _audioState = AudioState.finished;
      _quizState = QuizState.visible;
      notifyListeners();
    });

    _tts.setErrorHandler((msg) {
      _audioState = AudioState.error;
      _errorMessage = 'Oops! I lost my voice. Tap to try again!';
      notifyListeners();
    });

    _tts.setCancelHandler(() {
      if (_audioState == AudioState.playing) {
        _audioState = AudioState.idle;
        notifyListeners();
      }
    });
  }

  Future<void> readStory() async {
    if (_audioState == AudioState.playing) {
      await _tts.stop();
      _audioState = AudioState.idle;
      notifyListeners();
      return;
    }

    _audioState = AudioState.loading;
    _errorMessage = '';
    notifyListeners();

    // Small delay to show loading state (simulates TTS engine prep)
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      final result = await _tts.speak(storyText);
      if (result != 1) {
        // TTS returned error
        _audioState = AudioState.error;
        _errorMessage = 'Oops! I lost my voice. Tap to try again!';
        notifyListeners();
      }
    } catch (e) {
      _audioState = AudioState.error;
      _errorMessage = 'Oops! Something went wrong. Tap to try again!';
      notifyListeners();
    }
  }

  void selectAnswer(String answer) {
    if (_quizState == QuizState.answered && _isCorrect) return;

    _selectedAnswer = answer;
    _isCorrect = answer == quizData.answer;

    if (_isCorrect) {
      _quizState = QuizState.answered;
    }
    notifyListeners();
  }

  void reset() {
    _tts.stop();
    _audioState = AudioState.idle;
    _quizState = QuizState.hidden;
    _selectedAnswer = null;
    _isCorrect = false;
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
