import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_provider.dart';

class ClassFeedbackScreen extends StatefulWidget {
  final String classId;
  const ClassFeedbackScreen({super.key, required this.classId});

  @override
  State<ClassFeedbackScreen> createState() => _ClassFeedbackScreenState();
}

class _ClassFeedbackScreenState extends State<ClassFeedbackScreen> {
  late TrainingClass _trainingClass;
  final Map<String, int> _ratings = {};
  final Map<String, TextEditingController> _textControllers = {};
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    _trainingClass = MockClasses.findById(widget.classId)!;
    for (final q in _trainingClass.feedbackQuestions) {
      if (q.type == FeedbackQuestionType.text) {
        _textControllers[q.id] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (final ctrl in _textControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _submit(AuthProvider auth) {
    final unanswered = _trainingClass.feedbackQuestions.where((q) {
      if (q.type == FeedbackQuestionType.rating) return !_ratings.containsKey(q.id);
      return (_textControllers[q.id]?.text.trim().isEmpty ?? true);
    }).toList();

    if (unanswered.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions before submitting')),
      );
      return;
    }

    final answers = _trainingClass.feedbackQuestions.map((q) {
      if (q.type == FeedbackQuestionType.rating) {
        return FeedbackAnswer(questionId: q.id, ratingValue: _ratings[q.id]);
      }
      return FeedbackAnswer(questionId: q.id, textValue: _textControllers[q.id]!.text.trim());
    }).toList();

    MockClassFeedback.add(ClassFeedback(
      id: 'feedback_${DateTime.now().microsecondsSinceEpoch}',
      classId: _trainingClass.id,
      memberId: auth.currentMember!.id,
      answers: answers,
      submittedAt: DateTime.now(),
      isAnonymous: _isAnonymous,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you for your feedback!')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (_trainingClass.feedbackQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Feedback')),
        body: Center(
          child: Text(
            'No feedback questions have been set up for this class.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Feedback'),
        actions: [
          TextButton(
            onPressed: () => _submit(auth),
            child: const Text('SUBMIT', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(_trainingClass.title, style: AppTextStyles.headingMedium),
          const SizedBox(height: 4),
          Text(
            'Your feedback helps us improve future training.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey700),
          ),
          const SizedBox(height: 20),
          ..._trainingClass.feedbackQuestions.map((q) => _questionCard(q)),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Submit anonymously'),
            subtitle: Text('Your name will not be linked to this feedback.', style: AppTextStyles.labelSmall),
            value: _isAnonymous,
            onChanged: (v) => setState(() => _isAnonymous = v),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _submit(auth),
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('Submit Feedback'),
          ),
        ],
      ),
    );
  }

  Widget _questionCard(FeedbackQuestion q) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.text, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (q.type == FeedbackQuestionType.rating)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (i) {
                  final value = i + 1;
                  final isSelected = _ratings[q.id] == value;
                  return InkWell(
                    onTap: () => setState(() => _ratings[q.id] = value),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isSelected ? Icons.star : Icons.star_outline,
                        size: 32,
                        color: isSelected ? Colors.amber : AppColors.grey500,
                      ),
                    ),
                  );
                }),
              )
            else
              TextField(
                controller: _textControllers[q.id],
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Your answer...',
                  border: OutlineInputBorder(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
