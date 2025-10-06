import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import './call_entry_widget.dart';

class CallSectionWidget extends StatelessWidget {
  final String sectionTitle;
  final List<Map<String, dynamic>> calls;
  final String searchQuery;
  final Function(Map<String, dynamic>) onCallBack;
  final Function(Map<String, dynamic>) onAddToContacts;
  final Function(Map<String, dynamic>) onBlockNumber;
  final Function(Map<String, dynamic>) onDelete;
  final Function(Map<String, dynamic>) onCallDetails;
  final Function(Map<String, dynamic>) onExport;
  final Function(Map<String, dynamic>) onShare;

  const CallSectionWidget({
    Key? key,
    required this.sectionTitle,
    required this.calls,
    required this.searchQuery,
    required this.onCallBack,
    required this.onAddToContacts,
    required this.onBlockNumber,
    required this.onDelete,
    required this.onCallDetails,
    required this.onExport,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (calls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Text(
            sectionTitle,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: isDarkMode
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: calls.length,
          itemBuilder: (context, index) {
            final call = calls[index];
            return CallEntryWidget(
              callData: call,
              searchQuery: searchQuery,
              onCallBack: () => onCallBack(call),
              onAddToContacts: () => onAddToContacts(call),
              onBlockNumber: () => onBlockNumber(call),
              onDelete: () => onDelete(call),
              onCallDetails: () => onCallDetails(call),
              onExport: () => onExport(call),
              onShare: () => onShare(call),
            );
          },
        ),
        SizedBox(height: 2.h),
      ],
    );
  }
}
