import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/codec_selector_widget.dart';
import './widgets/microphone_level_widget.dart';
import './widgets/settings_item_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/settings_switch_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Section expansion states
  bool _accountExpanded = true;
  bool _audioExpanded = true;
  bool _callExpanded = true;
  bool _networkExpanded = false;
  bool _notificationExpanded = false;
  bool _securityExpanded = false;

  // Mock settings data
  final Map<String, dynamic> _settingsData = {
    'account': {
      'server': 'sip.guardianvoice.com',
      'username': 'john.doe@company.com',
      'status': 'Connected',
      'encryption': 'TLS 1.3',
      'lastSync': DateTime.now().subtract(Duration(minutes: 5)),
    },
    'audio': {
      'codec': 'opus',
      'echoCancellation': true,
      'noiseSuppression': true,
      'microphoneGain': 0.7,
    },
    'call': {
      'autoAnswer': false,
      'callForwarding': false,
      'forwardingNumber': '+1 (555) 123-4567',
      'doNotDisturb': false,
      'dndSchedule': '22:00 - 08:00',
      'callRecording': false,
    },
    'network': {
      'transport': 'UDP',
      'stunServer': 'stun.guardianvoice.com',
      'bandwidthOptimization': true,
      'natTraversal': true,
    },
    'notifications': {
      'incomingCalls': true,
      'missedCallBadge': true,
      'pushTiming': 'Immediate',
    },
    'security': {
      'encryptionRequired': true,
      'certificateValidation': true,
      'auditLogAccess': false,
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _exportSettings() async {
    try {
      final settingsJson = jsonEncode(_settingsData);
      final timestamp = DateTime.now().toIso8601String().split('T')[0];
      final filename = 'guardian_voice_settings_$timestamp.json';

      if (kIsWeb) {
        final bytes = utf8.encode(settingsJson);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", filename)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsString(settingsJson);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Settings exported successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export settings'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importSettings() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        String content;
        if (kIsWeb) {
          final bytes = result.files.first.bytes;
          if (bytes != null) {
            content = utf8.decode(bytes);
          } else {
            throw Exception('Failed to read file');
          }
        } else {
          final file = File(result.files.first.path!);
          content = await file.readAsString();
        }

        final importedSettings = jsonDecode(content) as Map<String, dynamic>;
        setState(() {
          _settingsData.addAll(importedSettings);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Settings imported successfully'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import settings'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditDialog(
      String title, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTransportDialog() {
    final transports = ['UDP', 'TCP', 'TLS'];
    final currentTransport = _settingsData['network']['transport'] as String;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transport Protocol'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: transports.map((transport) {
            return RadioListTile<String>(
              title: Text(transport),
              subtitle: Text(_getTransportDescription(transport)),
              value: transport,
              groupValue: currentTransport,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _settingsData['network']['transport'] = value;
                  });
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _getTransportDescription(String transport) {
    switch (transport) {
      case 'UDP':
        return 'Fast, low latency';
      case 'TCP':
        return 'Reliable, firewall friendly';
      case 'TLS':
        return 'Encrypted, most secure';
      default:
        return '';
    }
  }

  void _showPushTimingDialog() {
    final timings = ['Immediate', '5 seconds', '10 seconds', '30 seconds'];
    final currentTiming =
        _settingsData['notifications']['pushTiming'] as String;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Push Notification Timing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: timings.map((timing) {
            return RadioListTile<String>(
              title: Text(timing),
              value: timing,
              groupValue: currentTiming,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _settingsData['notifications']['pushTiming'] = value;
                  });
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: Theme.of(context).appBarTheme.iconTheme?.color ??
                Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _exportSettings();
                  break;
                case 'import':
                  _importSettings();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'file_download',
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text('Export Settings'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'file_upload',
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text('Import Settings'),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: EdgeInsets.all(2.w),
              child: CustomIconWidget(
                iconName: 'more_vert',
                color: Theme.of(context).appBarTheme.iconTheme?.color ??
                    Theme.of(context).colorScheme.onSurface,
                size: 24,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'settings',
                    color: Theme.of(context).tabBarTheme.labelColor,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text('Settings'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 2.h),

                // Account Section
                SettingsSectionWidget(
                  title: 'Account',
                  isExpanded: _accountExpanded,
                  onToggle: () =>
                      setState(() => _accountExpanded = !_accountExpanded),
                  children: [
                    SettingsItemWidget(
                      title: 'SIP Server',
                      value: _settingsData['account']['server'],
                      iconName: 'dns',
                      onTap: () => _showEditDialog(
                        'SIP Server',
                        _settingsData['account']['server'],
                        (value) => setState(
                            () => _settingsData['account']['server'] = value),
                      ),
                    ),
                    SettingsItemWidget(
                      title: 'Username',
                      value: _settingsData['account']['username'],
                      iconName: 'person',
                      onTap: () => _showEditDialog(
                        'Username',
                        _settingsData['account']['username'],
                        (value) => setState(
                            () => _settingsData['account']['username'] = value),
                      ),
                    ),
                    SettingsItemWidget(
                      title: 'Connection Status',
                      value: _settingsData['account']['status'],
                      iconName: 'wifi',
                      showDivider: false,
                    ),
                  ],
                ),

                // Audio Preferences Section
                SettingsSectionWidget(
                  title: 'Audio Preferences',
                  isExpanded: _audioExpanded,
                  onToggle: () =>
                      setState(() => _audioExpanded = !_audioExpanded),
                  children: [
                    CodecSelectorWidget(
                      selectedCodec: _settingsData['audio']['codec'],
                      onCodecChanged: (codec) => setState(
                          () => _settingsData['audio']['codec'] = codec),
                    ),
                    Divider(height: 1, thickness: 0.5),
                    SettingsSwitchWidget(
                      title: 'Echo Cancellation',
                      subtitle: 'Reduces audio feedback during calls',
                      iconName: 'volume_off',
                      value: _settingsData['audio']['echoCancellation'],
                      onChanged: (value) => setState(() =>
                          _settingsData['audio']['echoCancellation'] = value),
                    ),
                    SettingsSwitchWidget(
                      title: 'Noise Suppression',
                      subtitle: 'Filters background noise',
                      iconName: 'noise_control_off',
                      value: _settingsData['audio']['noiseSuppression'],
                      onChanged: (value) => setState(() =>
                          _settingsData['audio']['noiseSuppression'] = value),
                      showDivider: false,
                    ),
                    Divider(height: 1, thickness: 0.5),
                    MicrophoneLevelWidget(
                      gain: _settingsData['audio']['microphoneGain'],
                      onGainChanged: (gain) => setState(() =>
                          _settingsData['audio']['microphoneGain'] = gain),
                    ),
                  ],
                ),

                // Call Settings Section
                SettingsSectionWidget(
                  title: 'Call Settings',
                  isExpanded: _callExpanded,
                  onToggle: () =>
                      setState(() => _callExpanded = !_callExpanded),
                  children: [
                    SettingsSwitchWidget(
                      title: 'Auto Answer',
                      subtitle: 'Automatically answer incoming calls',
                      iconName: 'call',
                      value: _settingsData['call']['autoAnswer'],
                      onChanged: (value) => setState(
                          () => _settingsData['call']['autoAnswer'] = value),
                    ),
                    SettingsSwitchWidget(
                      title: 'Call Forwarding',
                      subtitle: _settingsData['call']['callForwarding']
                          ? 'Forward to ${_settingsData['call']['forwardingNumber']}'
                          : 'Forward calls when unavailable',
                      iconName: 'call_made',
                      value: _settingsData['call']['callForwarding'],
                      onChanged: (value) => setState(() =>
                          _settingsData['call']['callForwarding'] = value),
                    ),
                    SettingsSwitchWidget(
                      title: 'Do Not Disturb',
                      subtitle: _settingsData['call']['doNotDisturb']
                          ? 'Active during ${_settingsData['call']['dndSchedule']}'
                          : 'Block calls during specified hours',
                      iconName: 'do_not_disturb',
                      value: _settingsData['call']['doNotDisturb'],
                      onChanged: (value) => setState(
                          () => _settingsData['call']['doNotDisturb'] = value),
                    ),
                    SettingsSwitchWidget(
                      title: 'Call Recording',
                      subtitle: 'Record calls where legally permitted',
                      iconName: 'record_voice_over',
                      value: _settingsData['call']['callRecording'],
                      onChanged: (value) => setState(
                          () => _settingsData['call']['callRecording'] = value),
                      showDivider: false,
                    ),
                  ],
                ),

                // Network Section
                SettingsSectionWidget(
                  title: 'Network',
                  isExpanded: _networkExpanded,
                  onToggle: () =>
                      setState(() => _networkExpanded = !_networkExpanded),
                  children: [
                    SettingsItemWidget(
                      title: 'Transport Protocol',
                      value: _settingsData['network']['transport'],
                      iconName: 'router',
                      onTap: _showTransportDialog,
                    ),
                    SettingsItemWidget(
                      title: 'STUN Server',
                      value: _settingsData['network']['stunServer'],
                      iconName: 'public',
                      onTap: () => _showEditDialog(
                        'STUN Server',
                        _settingsData['network']['stunServer'],
                        (value) => setState(() =>
                            _settingsData['network']['stunServer'] = value),
                      ),
                    ),
                    SettingsSwitchWidget(
                      title: 'Bandwidth Optimization',
                      subtitle: 'Adjust quality based on connection',
                      iconName: 'speed',
                      value: _settingsData['network']['bandwidthOptimization'],
                      onChanged: (value) => setState(() =>
                          _settingsData['network']['bandwidthOptimization'] =
                              value),
                    ),
                    SettingsSwitchWidget(
                      title: 'NAT Traversal',
                      subtitle: 'Enable for firewall compatibility',
                      iconName: 'security',
                      value: _settingsData['network']['natTraversal'],
                      onChanged: (value) => setState(() =>
                          _settingsData['network']['natTraversal'] = value),
                      showDivider: false,
                    ),
                  ],
                ),

                // Notification Preferences Section
                SettingsSectionWidget(
                  title: 'Notification Preferences',
                  isExpanded: _notificationExpanded,
                  onToggle: () => setState(
                      () => _notificationExpanded = !_notificationExpanded),
                  children: [
                    SettingsSwitchWidget(
                      title: 'Incoming Call Alerts',
                      subtitle: 'Show notifications for incoming calls',
                      iconName: 'notifications',
                      value: _settingsData['notifications']['incomingCalls'],
                      onChanged: (value) => setState(() =>
                          _settingsData['notifications']['incomingCalls'] =
                              value),
                    ),
                    SettingsSwitchWidget(
                      title: 'Missed Call Badge',
                      subtitle: 'Show badge count for missed calls',
                      iconName: 'notifications_active',
                      value: _settingsData['notifications']['missedCallBadge'],
                      onChanged: (value) => setState(() =>
                          _settingsData['notifications']['missedCallBadge'] =
                              value),
                    ),
                    SettingsItemWidget(
                      title: 'Push Notification Timing',
                      value: _settingsData['notifications']['pushTiming'],
                      iconName: 'schedule',
                      onTap: _showPushTimingDialog,
                      showDivider: false,
                    ),
                  ],
                ),

                // Security Section
                SettingsSectionWidget(
                  title: 'Security',
                  isExpanded: _securityExpanded,
                  onToggle: () =>
                      setState(() => _securityExpanded = !_securityExpanded),
                  children: [
                    SettingsSwitchWidget(
                      title: 'Encryption Required',
                      subtitle: 'Force encrypted connections only',
                      iconName: 'lock',
                      value: _settingsData['security']['encryptionRequired'],
                      onChanged: (value) => setState(() =>
                          _settingsData['security']['encryptionRequired'] =
                              value),
                    ),
                    SettingsSwitchWidget(
                      title: 'Certificate Validation',
                      subtitle: 'Verify server certificates',
                      iconName: 'verified',
                      value: _settingsData['security']['certificateValidation'],
                      onChanged: (value) => setState(() =>
                          _settingsData['security']['certificateValidation'] =
                              value),
                    ),
                    SettingsSwitchWidget(
                      title: 'Audit Log Access',
                      subtitle: 'Enable enterprise compliance logging',
                      iconName: 'history',
                      value: _settingsData['security']['auditLogAccess'],
                      onChanged: (value) => setState(() =>
                          _settingsData['security']['auditLogAccess'] = value),
                      showDivider: false,
                    ),
                  ],
                ),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}