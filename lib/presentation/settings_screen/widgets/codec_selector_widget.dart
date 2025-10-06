import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CodecSelectorWidget extends StatelessWidget {
  final String selectedCodec;
  final ValueChanged<String> onCodecChanged;

  const CodecSelectorWidget({
    Key? key,
    required this.selectedCodec,
    required this.onCodecChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> codecs = [
      {
        'name': 'G.711 (PCMU)',
        'value': 'g711',
        'description': 'Standard quality, low bandwidth',
        'bandwidth': '64 kbps',
      },
      {
        'name': 'G.722',
        'value': 'g722',
        'description': 'High quality, moderate bandwidth',
        'bandwidth': '64 kbps',
      },
      {
        'name': 'Opus',
        'value': 'opus',
        'description': 'Best quality, adaptive bandwidth',
        'bandwidth': '6-510 kbps',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'audiotrack',
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 3.w),
              Text(
                'Preferred Audio Codec',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...codecs.map((codec) {
            final bool isSelected = selectedCodec == codec['value'];
            return GestureDetector(
              onTap: () => onCodecChanged(codec['value']),
              child: Container(
                margin: EdgeInsets.only(bottom: 1.h),
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1)
                      : Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Radio<String>(
                      value: codec['value'],
                      groupValue: selectedCodec,
                      onChanged: (value) {
                        if (value != null) {
                          onCodecChanged(value);
                        }
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            codec['name'],
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            codec['description'],
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      codec['bandwidth'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
