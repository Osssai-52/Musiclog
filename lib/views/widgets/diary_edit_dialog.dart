import 'package:flutter/material.dart';
import 'package:musiclog/config/app_colors.dart';
import 'package:musiclog/domain/repositories/diary_repository.dart';
import 'package:musiclog/domain/repositories/song_catalog_repository.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryEditDialog extends StatefulWidget {
  final DiaryRepository diaryRepository;
  final SongCatalogRepository songRepository;
  final DateTime selectedDate;

  const DiaryEditDialog({
    super.key,
    required this.diaryRepository,
    required this.songRepository,
    required this.selectedDate,
  });

  @override
  State<DiaryEditDialog> createState() => _DiaryEditDialogState();
}

class _DiaryEditDialogState extends State<DiaryEditDialog> {
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _draftLoaded = false;

  SharedPreferences? _prefs;

  String get _draftKey {
    final d = widget.selectedDate;
    final key = d.year * 10000 + d.month * 100 + d.day;
    return 'draft_$key';
  }

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final draft = _prefs?.getString(_draftKey) ?? '';
      if (!mounted) return;
      _contentController.text = draft;
    } catch (_) {
      if (!mounted) return;
    } finally {
      if (!mounted) return;
      setState(() {
        _draftLoaded = true;
      });
    }
  }

  Future<void> _persistDraft() async {
    if (_isSaving) return;

    final text = _contentController.text.trim();
    try {
      _prefs ??= await SharedPreferences.getInstance();
      if (_prefs == null) return;

      if (text.isEmpty) {
        await _prefs!.remove(_draftKey);
      } else {
        await _prefs!.setString(_draftKey, text);
      }
    } catch (_) {}
  }

  Future<void> _clearDraft() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      if (_prefs == null) return;
      await _prefs!.remove(_draftKey);
    } catch (_) {}
  }

  Future<void> _closeWithDraft() async {
    await _persistDraft();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!_draftLoaded) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.all(16),
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: SizedBox(
            height: 120,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        await _persistDraft();
        return true;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat('MMMM d, yyyy').format(widget.selectedDate),
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nanum',
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _closeWithDraft,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'What happened today?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nanum',
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _contentController,
                    maxLines: 8,
                    minLines: 4,
                    decoration: InputDecoration(
                      hintText: '오늘 있었던 일, 기분, 생각 등을 자유롭게 적어보세요...',
                      hintStyle: TextStyle(
                        fontFamily: 'Nanum',
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Nanum',
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '일기 내용을 작성해주세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveDiary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                          : const Text(
                        'Save Diary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nanum',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    DateFormat('MMM d, yyyy HH:mm').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Nanum',
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveDiary() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.diaryRepository.upsertForDate(
        date: widget.selectedDate,
        content: _contentController.text.trim(),
      );

      await _clearDraft();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('일기가 저장되었습니다.'),
          backgroundColor: AppColors.primary,
        ),
      );

      Navigator.pop(context, 'refresh');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}