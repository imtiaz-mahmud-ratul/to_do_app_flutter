import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../services/voice_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  TaskType _type = TaskType.study;
  TaskPriority _priority = TaskPriority.medium;

  final VoiceService _voice = VoiceService();
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _voice.initSpeech();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final res = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (res != null) setState(() => _dueDate = res);
  }

  Future<void> _pickTime() async {
    final res = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (res != null) setState(() => _dueTime = res);
  }

  DateTime? _combineDue() {
    if (_dueDate == null || _dueTime == null) return null;
    return DateTime(
      _dueDate!.year,
      _dueDate!.month,
      _dueDate!.day,
      _dueTime!.hour,
      _dueTime!.minute,
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final due = _combineDue();
    if (due == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select due date and time')));
      return;
    }
    final provider = context.read<TaskProvider>();
    final task = Task(
      id: '',
      title: _title.text.trim(),
      description: _description.text.trim(),
      dueDateTime: due,
      type: _type,
      priority: _priority,
      status: TaskStatus.pending,
      createdAt: DateTime.now(),
    );
    await provider.addTask(task);
    if (mounted) Navigator.pop(context);
  }

  void _startVoice() async {
    setState(() => _listening = true);
    await _voice.listen(onResult: (text) {
      setState(() => _listening = false);
      // Simple parsing: "Title: Flutter Lab; Description: Finish; Date: 2026-01-21; Time: 20:00"
      // Or just set title from speech
      if (text.isNotEmpty) {
        _title.text = text;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Captured title: "$text"')));
      }
    });
  }

  void _stopVoice() async {
    await _voice.stopListening();
    setState(() => _listening = false);
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _dueDate == null
        ? 'Select date'
        : DateFormat('EEE, MMM d, yyyy').format(_dueDate!);
    final timeStr =
        _dueTime == null ? 'Select time' : _dueTime!.format(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _title,
                decoration: InputDecoration(
                  labelText: 'Title of Task',
                  suffixIcon: IconButton(
                    icon: Icon(_listening ? Icons.mic : Icons.mic_none),
                    onPressed: _listening ? _stopVoice : _startVoice,
                    tooltip: 'Voice input',
                  ),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TaskType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Task Type'),
                items: TaskType.values.map((t) {
                  return DropdownMenuItem(
                      value: t, child: Text(t.name.toUpperCase()));
                }).toList(),
                onChanged: (v) => setState(() => _type = v ?? TaskType.study),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TaskPriority>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: TaskPriority.values.map((p) {
                  return DropdownMenuItem(
                      value: p, child: Text(p.name.toUpperCase()));
                }).toList(),
                onChanged: (v) =>
                    setState(() => _priority = v ?? TaskPriority.medium),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(dateStr),
                      onPressed: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text(timeStr),
                      onPressed: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Task'),
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
