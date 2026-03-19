import 'package:flutter/material.dart';
import 'package:heart_disease/features/submit_assessment/presentation/widgets/assessment_flow.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: Center(
        child: ElevatedButton(
          child: const Text("Start Assessment"),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AssessmentFlow(),
              ),
            );

            /// 👇 هنا ممكن تعمل refresh للـ history
            // context.read<HistoryCubit>().getHistory();
            // final result = await Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (_) => const AssessmentFlow()),
            // );

            // if (result == true) {
            //   context.read<HistoryCubit>().getHistory();
            // }
          },
        ),
      ),
    );
  }
}

class DoctorsScreen extends StatelessWidget {
  const DoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: const Text('doctors screen'));
  }
}

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: const Text('articles screen'));
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: const Text('chat screen'));
  }
}
