import 'package:flutter/material.dart';

class FilterSelection {
  final String? priority;
  final String? status;
  final DateTime? start;
  final DateTime? end;
  final bool cleared;

  const FilterSelection({
    this.priority,
    this.status,
    this.start,
    this.end,
    this.cleared = false,
  });
}

class FiltersDialog extends StatefulWidget {
  final String? initialPriority;
  final String? initialStatus;
  final DateTime? initialStart;
  final DateTime? initialEnd;

  final Color borderColor;
  final Color fillColor;

  const FiltersDialog({
    super.key,
    this.initialPriority,
    this.initialStatus,
    this.initialStart,
    this.initialEnd,
    this.borderColor = const Color(0xFFA62424),
    this.fillColor = const Color(0xFFFF0000),
  });

  static Future<FilterSelection?> show(
      BuildContext context, {
        String? initialPriority,
        String? initialStatus,
        DateTime? initialStart,
        DateTime? initialEnd,
      }) {
    return showDialog<FilterSelection>(
      context: context,
      builder: (ctx) => FiltersDialog(
        initialPriority: initialPriority,
        initialStatus: initialStatus,
        initialStart: initialStart,
        initialEnd: initialEnd,
      ),
    );
  }

  @override
  State<FiltersDialog> createState() => _FiltersDialogState();
}

class _FiltersDialogState extends State<FiltersDialog> {
  late String? tempPriority;
  late String? tempStatus;
  late DateTime? tempStart;
  late DateTime? tempEnd;

  Color get _borderColor => widget.borderColor;
  Color get _fillColor => widget.fillColor;

  @override
  void initState() {
    super.initState();
    tempPriority = widget.initialPriority;
    tempStatus = widget.initialStatus;
    tempStart = widget.initialStart;
    tempEnd = widget.initialEnd;
  }

  String? _statusLabelFromInternal(String? internal) {
    if (internal == null) return null;
    switch (internal) {
      case 'TO_DO':
        return 'Por hacer';
      case 'IN_PROGRESS':
        return 'En proceso';
      case 'DONE':
        return 'Realizado';
      default:
        return null;
    }
  }

  String? _statusInternalFromLabel(String? label) {
    if (label == null) return null;
    switch (label) {
      case 'Por hacer':
        return 'TO_DO';
      case 'En proceso':
        return 'IN_PROGRESS';
      case 'Realizado':
        return 'DONE';
      default:
        return null;
    }
  }

  Widget _priorityOption(String label, String value) {
    final selected = tempPriority == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          tempPriority = selected ? null : value;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 8),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _borderColor, width: 2.2),
            ),
            child: Center(
              child: Container(
                width: 12.0,
                height: 12.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? _fillColor : Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: tempStart ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        tempStart = picked;
        if (tempEnd != null && tempEnd!.isBefore(tempStart!)) tempEnd = null;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: tempEnd ?? (tempStart ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        tempEnd = picked;
        if (tempStart != null && tempStart!.isAfter(tempEnd!)) tempStart = null;
      });
    }
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text('Filtros'),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prioridad:', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                _priorityOption('Alta', 'HIGH'),
                const SizedBox(width: 16),
                _priorityOption('Media', 'MEDIUM'),
                const SizedBox(width: 16),
                _priorityOption('Baja', 'LOW'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Estado:', style: Theme.of(context).textTheme.bodyLarge),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: _borderColor, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: tempStatus == null ? null : _statusLabelFromInternal(tempStatus),
                      hint: Text('Por hacer'),
                      items: const [
                        DropdownMenuItem(value: 'Por hacer', child: Text('Por hacer')),
                        DropdownMenuItem(value: 'En proceso', child: Text('En proceso')),
                        DropdownMenuItem(value: 'Realizado', child: Text('Realizado')),
                      ],
                      onChanged: (label) {
                        setState(() {
                          tempStatus = _statusInternalFromLabel(label);
                        });
                      },
                      icon: Icon(Icons.arrow_drop_down, color: _borderColor),
                      dropdownColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Rango de fechas:', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickStartDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Fecha inicio',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _borderColor, width: 2),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _borderColor, width: 2),
                        ),
                      ),
                      child: Text(
                        tempStart == null ? 'Seleccionar' : _formatDate(tempStart!)
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickEndDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Fecha fin',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _borderColor, width: 2),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _borderColor, width: 2),
                        ),
                      ),
                      child: Text(
                        tempEnd == null ? 'Seleccionar' : _formatDate(tempEnd!)
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(const FilterSelection(cleared: true));
          },
          child: const Text('Limpiar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(FilterSelection(
              priority: tempPriority,
              status: tempStatus,
              start: tempStart,
              end: tempEnd,
              cleared: false,
            ));
          },
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
}
