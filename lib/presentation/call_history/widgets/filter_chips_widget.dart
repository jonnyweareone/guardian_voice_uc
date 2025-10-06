import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterChipsWidget extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const FilterChipsWidget({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final List<Map<String, dynamic>> filters = [
      {'label': 'All', 'value': 'all', 'icon': 'call'},
      {'label': 'Missed', 'value': 'missed', 'icon': 'call_received'},
      {'label': 'Incoming', 'value': 'incoming', 'icon': 'call_received'},
      {'label': 'Outgoing', 'value': 'outgoing', 'icon': 'call_made'},
    ];

    return Container(
      height: 6.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final bool isSelected = selectedFilter == filter['value'];

          return Container(
            margin: EdgeInsets.only(right: 2.w),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: filter['icon'],
                    color: isSelected
                        ? Colors.white
                        : (isDarkMode
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight),
                    size: 4.w,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    filter['label'],
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: isSelected
                              ? Colors.white
                              : (isDarkMode
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => onFilterChanged(filter['value']),
              backgroundColor:
                  isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
              selectedColor: _getFilterColor(filter['value']),
              checkmarkColor: Colors.white,
              elevation: isSelected ? 2.0 : 0.0,
              shadowColor:
                  isDarkMode ? AppTheme.shadowDark : AppTheme.shadowLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(
                  color: isSelected
                      ? _getFilterColor(filter['value'])
                      : (isDarkMode
                          ? AppTheme.dividerDark
                          : AppTheme.dividerLight),
                  width: 1.0,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            ),
          );
        },
      ),
    );
  }

  Color _getFilterColor(String filterValue) {
    switch (filterValue) {
      case 'missed':
        return AppTheme.lightTheme.colorScheme.error;
      case 'incoming':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'outgoing':
        return AppTheme.lightTheme.primaryColor;
      default:
        return AppTheme.lightTheme.primaryColor;
    }
  }
}
