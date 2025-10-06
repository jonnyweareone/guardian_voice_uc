import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExportDialogWidget extends StatefulWidget {
  final Function(String format, DateTimeRange? dateRange) onExport;

  const ExportDialogWidget({
    Key? key,
    required this.onExport,
  }) : super(key: key);

  @override
  State<ExportDialogWidget> createState() => _ExportDialogWidgetState();
}

class _ExportDialogWidgetState extends State<ExportDialogWidget> {
  String _selectedFormat = 'CSV';
  DateTimeRange? _selectedDateRange;
  bool _useCustomDateRange = false;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Row(
        children: [
          CustomIconWidget(
            iconName: 'file_download',
            color: AppTheme.lightTheme.primaryColor,
            size: 6.w,
          ),
          SizedBox(width: 2.w),
          const Text('Export Call History'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Format',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('CSV'),
                    subtitle: const Text('Spreadsheet format'),
                    value: 'CSV',
                    groupValue: _selectedFormat,
                    onChanged: (value) {
                      setState(() {
                        _selectedFormat = value!;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('PDF'),
                    subtitle: const Text('Document format'),
                    value: 'PDF',
                    groupValue: _selectedFormat,
                    onChanged: (value) {
                      setState(() {
                        _selectedFormat = value!;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              'Date Range',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 1.h),
            CheckboxListTile(
              title: const Text('Use custom date range'),
              value: _useCustomDateRange,
              onChanged: (value) {
                setState(() {
                  _useCustomDateRange = value!;
                  if (!_useCustomDateRange) {
                    _selectedDateRange = null;
                  }
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            if (_useCustomDateRange) ...[
              SizedBox(height: 1.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDarkMode
                        ? AppTheme.dividerDark
                        : AppTheme.dividerLight,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedDateRange != null
                          ? 'From: ${_formatDate(_selectedDateRange!.start)}\nTo: ${_formatDate(_selectedDateRange!.end)}'
                          : 'No date range selected',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 1.h),
                    TextButton.icon(
                      onPressed: _selectDateRange,
                      icon: CustomIconWidget(
                        iconName: 'date_range',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 4.w,
                      ),
                      label: const Text('Select Date Range'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            widget.onExport(_selectedFormat, _selectedDateRange);
            Navigator.of(context).pop();
          },
          icon: CustomIconWidget(
            iconName: 'file_download',
            color: Colors.white,
            size: 4.w,
          ),
          label: const Text('Export'),
        ),
      ],
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.lightTheme.primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
