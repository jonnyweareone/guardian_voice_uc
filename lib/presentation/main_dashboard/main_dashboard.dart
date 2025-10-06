import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/dial_pad_button_widget.dart';
import './widgets/network_quality_indicator_widget.dart';
import './widgets/quick_action_button_widget.dart';
import './widgets/recent_contact_card_widget.dart';
import './widgets/sip_status_card_widget.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isRefreshing = false;
  String _sipStatus = "Registered";
  String _sipStatusMessage = "Connected to VoIP server";
  bool _isConnected = true;
  String _networkQuality = "Excellent";
  int _signalStrength = 95;
  String _networkType = "WiFi";
  DateTime _lastUpdated = DateTime.now();

  // Mock data for recent contacts
  final List<Map<String, dynamic>> _recentContacts = [
    {
      "id": 1,
      "name": "Sarah Johnson",
      "phone": "+1 (555) 123-4567",
      "avatar":
          "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face",
      "lastCall": DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      "id": 2,
      "name": "Michael Chen",
      "phone": "+1 (555) 987-6543",
      "avatar":
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
      "lastCall": DateTime.now().subtract(const Duration(hours: 5)),
    },
    {
      "id": 3,
      "name": "Emily Rodriguez",
      "phone": "+1 (555) 456-7890",
      "avatar":
          "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face",
      "lastCall": DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      "id": 4,
      "name": "David Wilson",
      "phone": "+1 (555) 321-0987",
      "avatar":
          "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
      "lastCall": DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      "id": 5,
      "name": "Lisa Thompson",
      "phone": "+1 (555) 654-3210",
      "avatar":
          "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop&crop=face",
      "lastCall": DateTime.now().subtract(const Duration(days: 3)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _simulateNetworkUpdates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _simulateNetworkUpdates() {
    // Simulate periodic network quality updates
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _signalStrength =
              (_signalStrength + (10 - (DateTime.now().millisecond % 20)))
                  .clamp(60, 100);
          _networkQuality = _signalStrength > 85
              ? "Excellent"
              : _signalStrength > 70
                  ? "Good"
                  : _signalStrength > 50
                      ? "Fair"
                      : "Poor";
        });
        _simulateNetworkUpdates();
      }
    });
  }

  Future<void> _refreshStatus() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate network request
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isRefreshing = false;
        _lastUpdated = DateTime.now();
        // Simulate status update
        _sipStatus = "Registered";
        _sipStatusMessage = "Connection refreshed successfully";
        _isConnected = true;
      });
    }
  }

  void _showContactMenu(Map<String, dynamic> contact) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Container(
                  width: 15.w,
                  height: 15.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: ClipOval(
                    child: contact["avatar"] != null
                        ? CustomImageWidget(
                            imageUrl: contact["avatar"] as String,
                            width: 15.w,
                            height: 15.w,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            child: Center(
                              child: Text(
                                _getInitials(contact["name"] as String),
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact["name"] as String,
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        contact["phone"] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Expanded(
                  child: _buildMenuButton(
                    icon: 'call',
                    label: 'Call',
                    onTap: () {
                      Navigator.pop(context);
                      _makeCall(contact);
                    },
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildMenuButton(
                    icon: 'message',
                    label: 'Message',
                    onTap: () {
                      Navigator.pop(context);
                      _sendMessage(contact);
                    },
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildMenuButton(
                    icon: 'edit',
                    label: 'Edit',
                    onTap: () {
                      Navigator.pop(context);
                      _editContact(contact);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 6.w,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    List<String> nameParts = name.split(" ");
    if (nameParts.length >= 2) {
      return "${nameParts[0][0]}${nameParts[1][0]}".toUpperCase();
    }
    return name[0].toUpperCase();
  }

  void _makeCall(Map<String, dynamic> contact) {
    Navigator.pushNamed(context, '/in-call-screen');
  }

  void _sendMessage(Map<String, dynamic> contact) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Messaging ${contact["name"]} - Feature coming soon'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _editContact(Map<String, dynamic> contact) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing ${contact["name"]} - Feature coming soon'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openDialPad() {
    Navigator.pushNamed(context, '/dtmf-keypad');
  }

  void _openSpeedDial() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Speed Dial - Feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openCallHistory() {
    Navigator.pushNamed(context, '/call-history');
  }

  void _openAudioSettings() {
    Navigator.pushNamed(context, '/audio-device-picker');
  }

  void _openEmergencyContacts() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency Contacts - Feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Guardian Voice UC',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          NetworkQualityIndicatorWidget(
            quality: _networkQuality,
            signalStrength: _signalStrength,
            networkType: _networkType,
          ),
          SizedBox(width: 2.w),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/settings-screen'),
            icon: CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'History'),
            Tab(text: 'Contacts'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildPlaceholderTab('Call History', '/call-history'),
          _buildPlaceholderTab('Contacts', '/contacts'),
          _buildPlaceholderTab('Settings', '/settings-screen'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openDialPad,
        child: CustomIconWidget(
          iconName: 'call',
          color: Colors.white,
          size: 7.w,
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _refreshStatus,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),

            // SIP Status Card
            SipStatusCardWidget(
              status: _sipStatus,
              statusMessage: _sipStatusMessage,
              isConnected: _isConnected,
              onRefresh: _isRefreshing ? null : _refreshStatus,
            ),

            // Dial Pad Button
            DialPadButtonWidget(
              onTap: _openDialPad,
            ),

            // Recent Contacts Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Contacts',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: _openCallHistory,
                    child: Text(
                      'View All',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 1.h),

            Container(
              height: 25.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: _recentContacts.length,
                itemBuilder: (context, index) {
                  final contact = _recentContacts[index];
                  return RecentContactCardWidget(
                    contact: contact,
                    onTap: () => _makeCall(contact),
                    onLongPress: () => _showContactMenu(contact),
                  );
                },
              ),
            ),

            SizedBox(height: 3.h),

            // Quick Actions Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Quick Actions',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(height: 2.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  QuickActionButtonWidget(
                    iconName: 'speed_dial',
                    label: 'Speed Dial',
                    onTap: _openSpeedDial,
                  ),
                  QuickActionButtonWidget(
                    iconName: 'history',
                    label: 'Call History',
                    onTap: _openCallHistory,
                  ),
                  QuickActionButtonWidget(
                    iconName: 'volume_up',
                    label: 'Audio Settings',
                    onTap: _openAudioSettings,
                  ),
                  QuickActionButtonWidget(
                    iconName: 'emergency',
                    label: 'Emergency',
                    onTap: _openEmergencyContacts,
                    backgroundColor:
                        AppTheme.getErrorColor(true).withValues(alpha: 0.1),
                    iconColor: AppTheme.getErrorColor(true),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Last Updated Info
            Center(
              child: Text(
                'Last updated: ${_formatLastUpdated(_lastUpdated)}',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab(String title, String route) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'construction',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 15.w,
          ),
          SizedBox(height: 2.h),
          Text(
            '$title Coming Soon',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, route),
            child: Text('Go to $title'),
          ),
        ],
      ),
    );
  }

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else {
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    }
  }
}
