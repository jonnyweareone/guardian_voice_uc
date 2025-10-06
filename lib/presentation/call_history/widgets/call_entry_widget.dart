import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CallEntryWidget extends StatelessWidget {
  final Map<String, dynamic> callData;
  final VoidCallback? onCallBack;
  final VoidCallback? onAddToContacts;
  final VoidCallback? onBlockNumber;
  final VoidCallback? onDelete;
  final VoidCallback? onCallDetails;
  final VoidCallback? onExport;
  final VoidCallback? onShare;
  final String searchQuery;

  const CallEntryWidget({
    Key? key,
    required this.callData,
    this.onCallBack,
    this.onAddToContacts,
    this.onBlockNumber,
    this.onDelete,
    this.onCallDetails,
    this.onExport,
    this.onShare,
    this.searchQuery = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String callType = callData['type'] as String? ?? 'outgoing';
    final bool isMissed = callType == 'missed';
    final String contactName = callData['contactName'] as String? ?? '';
    final String phoneNumber = callData['phoneNumber'] as String? ?? '';
    final DateTime timestamp =
        callData['timestamp'] as DateTime? ?? DateTime.now();
    final String duration = callData['duration'] as String? ?? '0:00';
    final String? contactPhoto = callData['contactPhoto'] as String?;

    return Slidable(
      key: ValueKey(callData['id']),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onCallBack?.call(),
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
            foregroundColor: Colors.white,
            icon: Icons.phone,
            label: 'Call Back',
            borderRadius: BorderRadius.circular(12.0),
          ),
          SlidableAction(
            onPressed: (_) => onAddToContacts?.call(),
            backgroundColor: AppTheme.lightTheme.primaryColor,
            foregroundColor: Colors.white,
            icon: Icons.person_add,
            label: 'Add Contact',
            borderRadius: BorderRadius.circular(12.0),
          ),
          SlidableAction(
            onPressed: (_) => onBlockNumber?.call(),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            foregroundColor: Colors.white,
            icon: Icons.block,
            label: 'Block',
            borderRadius: BorderRadius.circular(12.0),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _showDeleteConfirmation(context),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(12.0),
          ),
        ],
      ),
      child: GestureDetector(
        onLongPress: () => _showContextMenu(context),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? AppTheme.shadowDark : AppTheme.shadowLight,
                blurRadius: 4.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 6.w,
                  backgroundColor:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                  child: contactPhoto != null
                      ? CustomImageWidget(
                          imageUrl: contactPhoto,
                          width: 12.w,
                          height: 12.w,
                          fit: BoxFit.cover,
                        )
                      : CustomIconWidget(
                          iconName: 'person',
                          color: AppTheme.lightTheme.primaryColor,
                          size: 6.w,
                        ),
                ),
                if (isMissed)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 3.w,
                      height: 3.w,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDarkMode
                              ? AppTheme.cardDark
                              : AppTheme.cardLight,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            title: _buildHighlightedText(
              contactName.isNotEmpty ? contactName : phoneNumber,
              searchQuery,
              Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: isMissed ? FontWeight.w600 : FontWeight.w500,
                    color: isMissed
                        ? AppTheme.lightTheme.colorScheme.error
                        : (isDarkMode
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight),
                  ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (contactName.isNotEmpty)
                  _buildHighlightedText(
                    phoneNumber,
                    searchQuery,
                    Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: isDarkMode
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                  ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: _getCallTypeIcon(callType),
                      color: _getCallTypeColor(callType),
                      size: 4.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      _formatTimestamp(timestamp),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: isDarkMode
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomIconWidget(
                  iconName: 'info_outline',
                  color: isDarkMode
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                  size: 5.w,
                ),
                SizedBox(height: 0.5.h),
                if (duration != '0:00')
                  Text(
                    duration,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: isDarkMode
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
              ],
            ),
            onTap: () => onCallDetails?.call(),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, String query, TextStyle style) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return Text(text, style: style);
    }

    final int startIndex = text.toLowerCase().indexOf(query.toLowerCase());
    final int endIndex = startIndex + query.length;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: text.substring(0, startIndex), style: style),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: style.copyWith(
              backgroundColor:
                  AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: text.substring(endIndex), style: style),
        ],
      ),
    );
  }

  String _getCallTypeIcon(String callType) {
    switch (callType) {
      case 'incoming':
        return 'call_received';
      case 'outgoing':
        return 'call_made';
      case 'missed':
        return 'call_received';
      default:
        return 'call';
    }
  }

  Color _getCallTypeColor(String callType) {
    switch (callType) {
      case 'incoming':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'outgoing':
        return AppTheme.lightTheme.primaryColor;
      case 'missed':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.primaryColor;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${weekdays[timestamp.weekday - 1]} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Call'),
          content: const Text(
              'Are you sure you want to delete this call from history?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete?.call();
              },
              child: Text(
                'Delete',
                style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              SizedBox(height: 2.h),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'info',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 6.w,
                ),
                title: const Text('Call Details'),
                onTap: () {
                  Navigator.pop(context);
                  onCallDetails?.call();
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'file_download',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 6.w,
                ),
                title: const Text('Export'),
                onTap: () {
                  Navigator.pop(context);
                  onExport?.call();
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'share',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 6.w,
                ),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  onShare?.call();
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'delete',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 6.w,
                ),
                title: Text(
                  'Delete',
                  style:
                      TextStyle(color: AppTheme.lightTheme.colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
