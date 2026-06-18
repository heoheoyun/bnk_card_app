import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../data/models/terms_model.dart';

class TermsDetailBottomSheet extends StatelessWidget {
  final TermsModel terms;
  final String? contentHtml;
  const TermsDetailBottomSheet({super.key, required this.terms, this.contentHtml});

  static Future<void> show(BuildContext context, TermsModel terms, {String? contentHtml}) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => TermsDetailBottomSheet(terms: terms, contentHtml: contentHtml),
      );

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: 0.9,
    minChildSize: 0.5,
    maxChildSize: 0.95,
    expand: false,
    builder: (_, controller) => Column(children: [
      // 핸들
      Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
      // 제목
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(children: [
          Expanded(child: Text(terms.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ]),
      ),
      const Divider(height: 1),
      // 본문
      Expanded(child: ListView(controller: controller, padding: const EdgeInsets.all(16), children: [
        if (contentHtml != null)
          Html(data: contentHtml!)
        else
          const Center(child: Text('약관 내용을 불러올 수 없습니다.')),
      ])),
    ]),
  );
}
