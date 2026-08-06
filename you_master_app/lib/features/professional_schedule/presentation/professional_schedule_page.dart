import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/features/professional_schedule/domain/professional_schedule.dart';
import 'package:you_master_app/features/professional_schedule/presentation/state/professional_schedule_controller.dart';

class ProfessionalSchedulePage extends ConsumerWidget {
  const ProfessionalSchedulePage({super.key});

  static const _months = [
    'янв.',
    'февр.',
    'марта',
    'апр.',
    'мая',
    'июня',
    'июля',
    'авг.',
    'сент.',
    'окт.',
    'нояб.',
    'дек.',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(professionalScheduleControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Создание расписания')),
      body: schedule.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: FilledButton(
            onPressed: () =>
                ref.invalidate(professionalScheduleControllerProvider),
            child: const Text('Повторить загрузку'),
          ),
        ),
        data: (state) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            const Text('1. Выберите даты', style: _titleStyle),
            const SizedBox(height: 6),
            const Text(
              'Одинаковые окна будут созданы сразу для всех выбранных дат.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final date in state.selectedDates.toList()..sort())
                  InputChip(
                    label: Text('${date.day} ${_months[date.month - 1]}'),
                    selected: true,
                    onDeleted: state.selectedDates.length == 1
                        ? null
                        : () => ref
                              .read(
                                professionalScheduleControllerProvider.notifier,
                              )
                              .toggleDate(date),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Добавить дату'),
                  onPressed: () => _addDate(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text('2. Время начала', style: _titleStyle),
            const SizedBox(height: 6),
            const Text(
              'Оставьте «Любая услуга» или ограничьте конкретное окно.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 14),
            for (var index = 0; index < state.starts.length; index++) ...[
              _StartEditor(
                start: state.starts[index],
                services: state.services,
                onServiceChanged: (serviceId) => ref
                    .read(professionalScheduleControllerProvider.notifier)
                    .restrictStart(index, serviceId),
                onDelete: () => ref
                    .read(professionalScheduleControllerProvider.notifier)
                    .removeStart(index),
              ),
              const SizedBox(height: 10),
            ],
            OutlinedButton.icon(
              onPressed: () => _addTime(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Добавить время'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            if (state.saveError != null) ...[
              const SizedBox(height: 12),
              Text(
                state.saveError!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ],
            const SizedBox(height: 28),
            FilledButton(
              onPressed: state.isSaving ? null : () => _save(context, ref),
              child: state.isSaving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Сохранить расписание'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addDate(BuildContext context, WidgetRef ref) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      ref
          .read(professionalScheduleControllerProvider.notifier)
          .toggleDate(date);
    }
  }

  Future<void> _addTime(BuildContext context, WidgetRef ref) async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 30),
    );
    if (time != null) {
      ref
          .read(professionalScheduleControllerProvider.notifier)
          .addStart(TimeOfDayValue(time.hour, time.minute));
    }
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final saved = await ref
        .read(professionalScheduleControllerProvider.notifier)
        .save();
    if (saved && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Расписание сохранено')));
      Navigator.of(context).pop();
    }
  }

  static const _titleStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
  );
}

class _StartEditor extends StatelessWidget {
  const _StartEditor({
    required this.start,
    required this.services,
    required this.onServiceChanged,
    required this.onDelete,
  });

  final EditableAvailabilityStart start;
  final List<ScheduleServiceOption> services;
  final ValueChanged<String?> onServiceChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: Text(
              start.time.label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: start.restrictedServiceId,
                isExpanded: true,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Любая услуга'),
                  ),
                  for (final service in services)
                    DropdownMenuItem<String?>(
                      value: service.id,
                      child: Text(
                        service.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: onServiceChanged,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Удалить время',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }
}
