import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import './audio_device_item_widget.dart';
import './device_category_header_widget.dart';

class AudioDeviceListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> devices;
  final String? selectedDeviceId;
  final Function(Map<String, dynamic>) onDeviceSelected;

  const AudioDeviceListWidget({
    Key? key,
    required this.devices,
    required this.selectedDeviceId,
    required this.onDeviceSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final groupedDevices = _groupDevicesByType();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedDevices.length,
      itemBuilder: (context, index) {
        final category = groupedDevices.keys.elementAt(index);
        final categoryDevices = groupedDevices[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DeviceCategoryHeaderWidget(
              title: _getCategoryTitle(category),
              iconName: _getCategoryIcon(category),
              deviceCount: categoryDevices.length,
            ),
            ...categoryDevices
                .map((device) => AudioDeviceItemWidget(
                      device: device,
                      isSelected: device['id'] == selectedDeviceId,
                      onTap: () => onDeviceSelected(device),
                    ))
                .toList(),
            if (index < groupedDevices.length - 1)
              Divider(
                height: 3.h,
                thickness: 1,
                color: AppTheme.lightTheme.dividerColor,
                indent: 4.w,
                endIndent: 4.w,
              ),
          ],
        );
      },
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupDevicesByType() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final device in devices) {
      final type = device['type'] as String;
      if (!grouped.containsKey(type)) {
        grouped[type] = [];
      }
      grouped[type]!.add(device);
    }

    // Sort categories by priority
    final sortedKeys = grouped.keys.toList()
      ..sort(
          (a, b) => _getCategoryPriority(a).compareTo(_getCategoryPriority(b)));

    final Map<String, List<Map<String, dynamic>>> sortedGrouped = {};
    for (final key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
  }

  int _getCategoryPriority(String category) {
    switch (category) {
      case 'earpiece':
        return 1;
      case 'speaker':
        return 2;
      case 'bluetooth':
        return 3;
      case 'headphones':
        return 4;
      case 'car':
        return 5;
      case 'hearing_aid':
        return 6;
      default:
        return 99;
    }
  }

  String _getCategoryTitle(String category) {
    switch (category) {
      case 'earpiece':
        return 'Phone Audio';
      case 'speaker':
        return 'Speaker Phone';
      case 'bluetooth':
        return 'Bluetooth Devices';
      case 'headphones':
        return 'Wired Headphones';
      case 'car':
        return 'Car Audio';
      case 'hearing_aid':
        return 'Hearing Aids';
      default:
        return 'Other Devices';
    }
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'earpiece':
        return 'phone';
      case 'speaker':
        return 'volume_up';
      case 'bluetooth':
        return 'bluetooth';
      case 'headphones':
        return 'headphones';
      case 'car':
        return 'directions_car';
      case 'hearing_aid':
        return 'hearing';
      default:
        return 'speaker';
    }
  }
}
