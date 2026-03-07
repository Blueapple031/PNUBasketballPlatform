import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/post_model.dart';
import '../../providers/community_provider.dart';

class PostCreateScreen extends StatefulWidget {
  final String? postId;
  final String? initialTitle;
  final String? initialContent;

  const PostCreateScreen({
    super.key,
    this.postId,
    this.initialTitle,
    this.initialContent,
  });

  bool get isEdit => postId != null;

  @override
  State<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  bool _addPoll = false;
  final _pollQuestionController = TextEditingController();
  final List<TextEditingController> _pollOptionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  DateTime? _pollExpiresAt;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _contentController = TextEditingController(text: widget.initialContent ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _pollQuestionController.dispose();
    for (final c in _pollOptionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  PollCreatePayload? _buildPollPayload() {
    if (!_addPoll) return null;
    final question = _pollQuestionController.text.trim();
    final options = _pollOptionControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (question.isEmpty || options.length < 2) return null;
    return PollCreatePayload(
      question: question,
      options: options,
      expiresAt: _pollExpiresAt,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    if (_addPoll) {
      final question = _pollQuestionController.text.trim();
      final options = _pollOptionControllers
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (question.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('투표 질문을 입력해주세요.')),
        );
        return;
      }
      if (options.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('선택지는 최소 2개 이상 입력해주세요.')),
        );
        return;
      }
      if (options.length > 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('선택지는 최대 10개까지 가능합니다.')),
        );
        return;
      }
    }

    final provider = context.read<CommunityProvider>();

    if (widget.isEdit) {
      final updated = await provider.updatePost(
        postId: widget.postId!,
        title: title,
        content: content,
      );
      if (mounted && updated != null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시글이 수정되었습니다.')),
        );
      } else if (mounted && provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage!)),
        );
      }
    } else {
      final created = await provider.createPost(
        title: title,
        content: content,
        poll: _buildPollPayload(),
      );
      if (mounted && created != null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시글이 작성되었습니다.')),
        );
      } else if (mounted && provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage!)),
        );
      }
    }
  }

  void _addPollOption() {
    if (_pollOptionControllers.length >= 10) return;
    setState(() {
      _pollOptionControllers.add(TextEditingController());
    });
  }

  void _removePollOption(int index) {
    if (_pollOptionControllers.length <= 2) return;
    setState(() {
      _pollOptionControllers[index].dispose();
      _pollOptionControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.headerGrey,
        elevation: 0,
        title: Text(
          widget.isEdit ? '게시글 수정' : '글쓰기',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text(
              '완료',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                  hintText: '제목을 입력하세요',
                ),
                maxLength: 200,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '제목을 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: '내용',
                  hintText: '내용을 입력하세요',
                  alignLabelWithHint: true,
                ),
                maxLines: 12,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '내용을 입력해주세요.';
                  }
                  return null;
                },
              ),
              if (!widget.isEdit) ...[
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text('투표 첨부'),
                  subtitle: const Text('질문과 선택지를 추가하여 투표를 진행할 수 있습니다.'),
                  value: _addPoll,
                  onChanged: (v) => setState(() => _addPoll = v),
                ),
                if (_addPoll) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pollQuestionController,
                    decoration: const InputDecoration(
                      labelText: '투표 질문',
                      hintText: '예: 다음 모임 날짜는?',
                    ),
                    maxLength: 500,
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_pollOptionControllers.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _pollOptionControllers[i],
                              decoration: InputDecoration(
                                labelText: '선택지 ${i + 1}',
                                hintText: '선택지 내용',
                              ),
                              maxLength: 200,
                            ),
                          ),
                          IconButton(
                            onPressed: _pollOptionControllers.length > 2
                                ? () => _removePollOption(i)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (_pollOptionControllers.length < 10)
                    TextButton.icon(
                      onPressed: _addPollOption,
                      icon: const Icon(Icons.add),
                      label: const Text('선택지 추가'),
                    ),
                  const SizedBox(height: 8),
                  ListTile(
                    title: Text(
                      _pollExpiresAt != null
                          ? '만료일: ${_pollExpiresAt!.toString().substring(0, 10)}'
                          : '만료일 (선택)',
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 7)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null && mounted) {
                          setState(() => _pollExpiresAt = date);
                        }
                      },
                      child: Text(
                        _pollExpiresAt != null ? '변경' : '설정',
                      ),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submit,
                child: Text(widget.isEdit ? '수정하기' : '작성하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
