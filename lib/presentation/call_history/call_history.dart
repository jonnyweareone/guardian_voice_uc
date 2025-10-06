import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_export.dart';
import './widgets/call_section_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/export_dialog_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/search_bar_widget.dart';

class CallHistory extends StatefulWidget {
  const CallHistory({Key? key}) : super(key: key);

  @override
  State<CallHistory> createState() => _CallHistoryState();
}

class _CallHistoryState extends State<CallHistory>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedFilter = 'all';
  bool _isLoading = false;
  bool _isRefreshing = false;

  final List<Map<String, dynamic>> _mockCallHistory = [
    {
      "id": 1,
      "contactName": "Sarah Johnson",
      "phoneNumber": "+1 (555) 123-4567",
      "contactPhoto":
          "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400",
      "type": "incoming",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 15)),
      "duration": "5:23",
    },
    {
      "id": 2,
      "contactName": "Michael Chen",
      "phoneNumber": "+1 (555) 987-6543",
      "contactPhoto":
          "https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=400",
      "type": "outgoing",
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
      "duration": "12:45",
    },
    {
      "id": 3,
      "contactName": "Emma Wilson",
      "phoneNumber": "+1 (555) 456-7890",
      "contactPhoto":
          "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400",
      "type": "missed",
      "timestamp": DateTime.now().subtract(const Duration(hours: 4)),
      "duration": "0:00",
    },
    {
      "id": 4,
      "contactName": "David Rodriguez",
      "phoneNumber": "+1 (555) 321-0987",
      "contactPhoto":
          "https://images.pexels.com/photos/1043471/pexels-photo-1043471.jpeg?auto=compress&cs=tinysrgb&w=400",
      "type": "incoming",
      "timestamp": DateTime.now().subtract(const Duration(hours: 6)),
      "duration": "8:12",
    },
    {
      "id": 5,
      "contactName": "",
      "phoneNumber": "+1 (555) 111-2222",
      "contactPhoto": null,
      "type": "missed",
      "timestamp": DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      "duration": "0:00",
    },
    {
      "id": 6,
      "contactName": "Lisa Thompson",
      "phoneNumber": "+1 (555) 888-9999",
      "contactPhoto":
          "https://images.pexels.com/photos/1130626/pexels-photo-1130626.jpeg?auto=compress&cs=tinysrgb&w=400",
      "type": "outgoing",
      "timestamp": DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      "duration": "3:45",
    },
    {
      "id": 7,
      "contactName": "James Park",
      "phoneNumber": "+1 (555) 777-8888",
      "contactPhoto":
          "https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg?auto=compress&cs=tinysrgb&w=400",
      "type": "incoming",
      "timestamp": DateTime.now().subtract(const Duration(days: 3)),
      "duration": "15:30",
    },
    {
      "id": 8,
      "contactName": "Anna Martinez",
      "phoneNumber": "+1 (555) 444-5555",
      "contactPhoto":
          "https://images.pexels.com/photos/1036623/pexels-photo-1036623.jpeg?auto=compress&cs=tinysrgb&w=400",
      "type": "outgoing",
      "timestamp": DateTime.now().subtract(const Duration(days: 5)),
      "duration": "7:18",
    },
    {
      "id": 9,
      "contactName": "Robert Kim",
      "phoneNumber": "+1 (555) 666-7777",
      "contactPhoto":
          "https://images.pexels.com/photos/1212984/pexels-photo-1212984.jpeg?auto=compress&cs=tinysrgb&w=400",
      "type": "missed",
      "timestamp": DateTime.now().subtract(const Duration(days: 7)),
      "duration": "0:00",
    },
    {
      "id": 10,
      "contactName": "Jennifer Lee",
      "phoneNumber": "+1 (555) 333-4444",
      "contactPhoto":
          "https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg?auto=compress&cs=tinysrgb&w=400",
      "type": "incoming",
      "timestamp": DateTime.now().subtract(const Duration(days: 10)),
      "duration": "22:15",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _loadCallHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCallHistory() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshCallHistory() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });

    Fluttertoast.showToast(
      msg: "Call history refreshed",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  List<Map<String, dynamic>> _getFilteredCalls() {
    List<Map<String, dynamic>> filteredCalls = List.from(_mockCallHistory);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredCalls = filteredCalls.where((call) {
        final contactName =
            (call['contactName'] as String? ?? '').toLowerCase();
        final phoneNumber =
            (call['phoneNumber'] as String? ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();
        return contactName.contains(query) || phoneNumber.contains(query);
      }).toList();
    }

    // Apply type filter
    if (_selectedFilter != 'all') {
      filteredCalls = filteredCalls.where((call) {
        return call['type'] == _selectedFilter;
      }).toList();
    }

    return filteredCalls;
  }

  Map<String, List<Map<String, dynamic>>> _groupCallsByDate(
      List<Map<String, dynamic>> calls) {
    final Map<String, List<Map<String, dynamic>>> groupedCalls = {
      'Today': [],
      'Yesterday': [],
      'This Week': [],
      'Earlier': [],
    };

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: now.weekday - 1));

    for (final call in calls) {
      final callDate = call['timestamp'] as DateTime;
      final callDay = DateTime(callDate.year, callDate.month, callDate.day);

      if (callDay == today) {
        groupedCalls['Today']!.add(call);
      } else if (callDay == yesterday) {
        groupedCalls['Yesterday']!.add(call);
      } else if (callDay.isAfter(weekStart.subtract(const Duration(days: 1)))) {
        groupedCalls['This Week']!.add(call);
      } else {
        groupedCalls['Earlier']!.add(call);
      }
    }

    return groupedCalls;
  }

  void _handleCallBack(Map<String, dynamic> call) {
    final phoneNumber = call['phoneNumber'] as String? ?? '';
    Fluttertoast.showToast(
      msg: "Calling $phoneNumber...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
    Navigator.pushNamed(context, '/in-call-screen');
  }

  void _handleAddToContacts(Map<String, dynamic> call) {
    final contactName = call['contactName'] as String? ?? '';
    final phoneNumber = call['phoneNumber'] as String? ?? '';

    if (contactName.isEmpty) {
      Fluttertoast.showToast(
        msg: "Adding $phoneNumber to contacts",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Contact already exists",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _handleBlockNumber(Map<String, dynamic> call) {
    final phoneNumber = call['phoneNumber'] as String? ?? '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Block Number'),
          content: Text('Are you sure you want to block $phoneNumber?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Fluttertoast.showToast(
                  msg: "Number blocked",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              },
              child: Text(
                'Block',
                style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleDeleteCall(Map<String, dynamic> call) {
    setState(() {
      _mockCallHistory.removeWhere((c) => c['id'] == call['id']);
    });
    Fluttertoast.showToast(
      msg: "Call deleted from history",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleCallDetails(Map<String, dynamic> call) {
    final contactName = call['contactName'] as String? ?? '';
    final phoneNumber = call['phoneNumber'] as String? ?? '';
    final type = call['type'] as String? ?? '';
    final timestamp = call['timestamp'] as DateTime? ?? DateTime.now();
    final duration = call['duration'] as String? ?? '0:00';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(contactName.isNotEmpty ? contactName : phoneNumber),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Phone Number', phoneNumber),
              _buildDetailRow('Call Type', type.toUpperCase()),
              _buildDetailRow('Date & Time', _formatDetailTimestamp(timestamp)),
              _buildDetailRow('Duration', duration),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleCallBack(call);
              },
              child: const Text('Call Back'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDetailTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Today ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  void _handleExportCall(Map<String, dynamic> call) {
    final contactName = call['contactName'] as String? ?? '';
    final phoneNumber = call['phoneNumber'] as String? ?? '';
    final csvContent = 'Contact Name,Phone Number,Call Type,Date,Duration\n'
        '"${contactName.isNotEmpty ? contactName : 'Unknown'}",$phoneNumber,${call['type']},${_formatDetailTimestamp(call['timestamp'])},${call['duration']}';

    _downloadFile(csvContent, 'call_${call['id']}.csv');
  }

  void _handleShareCall(Map<String, dynamic> call) {
    final contactName = call['contactName'] as String? ?? '';
    final phoneNumber = call['phoneNumber'] as String? ?? '';
    final shareText = 'Call Details:\n'
        'Contact: ${contactName.isNotEmpty ? contactName : 'Unknown'}\n'
        'Phone: $phoneNumber\n'
        'Type: ${(call['type'] as String).toUpperCase()}\n'
        'Date: ${_formatDetailTimestamp(call['timestamp'])}\n'
        'Duration: ${call['duration']}';

    Fluttertoast.showToast(
      msg: "Call details copied to clipboard",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showBulkExportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ExportDialogWidget(
          onExport: _handleBulkExport,
        );
      },
    );
  }

  void _handleBulkExport(String format, DateTimeRange? dateRange) {
    List<Map<String, dynamic>> callsToExport = _getFilteredCalls();

    if (dateRange != null) {
      callsToExport = callsToExport.where((call) {
        final callDate = call['timestamp'] as DateTime;
        return callDate
                .isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
            callDate.isBefore(dateRange.end.add(const Duration(days: 1)));
      }).toList();
    }

    if (format == 'CSV') {
      _exportToCSV(callsToExport);
    } else {
      _exportToPDF(callsToExport);
    }
  }

  void _exportToCSV(List<Map<String, dynamic>> calls) {
    final StringBuffer csvBuffer = StringBuffer();
    csvBuffer
        .writeln('Contact Name,Phone Number,Call Type,Date & Time,Duration');

    for (final call in calls) {
      final contactName = call['contactName'] as String? ?? '';
      final phoneNumber = call['phoneNumber'] as String? ?? '';
      final type = call['type'] as String? ?? '';
      final timestamp = call['timestamp'] as DateTime? ?? DateTime.now();
      final duration = call['duration'] as String? ?? '0:00';

      csvBuffer.writeln(
          '"${contactName.isNotEmpty ? contactName : 'Unknown'}",$phoneNumber,$type,${_formatDetailTimestamp(timestamp)},$duration');
    }

    _downloadFile(csvBuffer.toString(),
        'call_history_${DateTime.now().millisecondsSinceEpoch}.csv');
  }

  void _exportToPDF(List<Map<String, dynamic>> calls) {
    final StringBuffer pdfContent = StringBuffer();
    pdfContent.writeln('CALL HISTORY REPORT');
    pdfContent
        .writeln('Generated on: ${DateTime.now().toString().split('.')[0]}');
    pdfContent.writeln('Total Calls: ${calls.length}');
    pdfContent.writeln('');
    pdfContent.writeln('CALL DETAILS:');
    pdfContent.writeln('=' * 50);

    for (final call in calls) {
      final contactName = call['contactName'] as String? ?? '';
      final phoneNumber = call['phoneNumber'] as String? ?? '';
      final type = call['type'] as String? ?? '';
      final timestamp = call['timestamp'] as DateTime? ?? DateTime.now();
      final duration = call['duration'] as String? ?? '0:00';

      pdfContent.writeln(
          'Contact: ${contactName.isNotEmpty ? contactName : 'Unknown'}');
      pdfContent.writeln('Phone: $phoneNumber');
      pdfContent.writeln('Type: ${type.toUpperCase()}');
      pdfContent.writeln('Date: ${_formatDetailTimestamp(timestamp)}');
      pdfContent.writeln('Duration: $duration');
      pdfContent.writeln('-' * 30);
    }

    _downloadFile(pdfContent.toString(),
        'call_history_${DateTime.now().millisecondsSinceEpoch}.txt');
  }

  Future<void> _downloadFile(String content, String filename) async {
    try {
      if (kIsWeb) {
        final bytes = utf8.encode(content);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", filename)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsString(content);
      }

      Fluttertoast.showToast(
        msg: "File exported successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Export failed. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final filteredCalls = _getFilteredCalls();
    final groupedCalls = _groupCallsByDate(filteredCalls);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Call History'),
        leading: IconButton(
          onPressed: () => Navigator.pushNamed(context, '/main-dashboard'),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: isDarkMode
                ? AppTheme.textPrimaryDark
                : AppTheme.textPrimaryLight,
            size: 6.w,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showBulkExportDialog,
            icon: CustomIconWidget(
              iconName: 'file_download',
              color: isDarkMode
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimaryLight,
              size: 6.w,
            ),
            tooltip: 'Export History',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                RefreshIndicator(
                  onRefresh: _refreshCallHistory,
                  child: Column(
                    children: [
                      SearchBarWidget(
                        searchQuery: _searchQuery,
                        onSearchChanged: (query) {
                          setState(() {
                            _searchQuery = query;
                          });
                        },
                        onClearSearch: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
                      SizedBox(height: 1.h),
                      FilterChipsWidget(
                        selectedFilter: _selectedFilter,
                        onFilterChanged: (filter) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                      ),
                      SizedBox(height: 1.h),
                      Expanded(
                        child: filteredCalls.isEmpty
                            ? EmptyStateWidget(
                                message: _searchQuery.isNotEmpty ||
                                        _selectedFilter != 'all'
                                    ? 'No calls found'
                                    : 'No calls yet',
                                actionText: _searchQuery.isEmpty &&
                                        _selectedFilter == 'all'
                                    ? 'Make your first call'
                                    : null,
                                onActionPressed: _searchQuery.isEmpty &&
                                        _selectedFilter == 'all'
                                    ? () => Navigator.pushNamed(
                                        context, '/main-dashboard')
                                    : null,
                                isSearchResult: _searchQuery.isNotEmpty ||
                                    _selectedFilter != 'all',
                              )
                            : ListView(
                                children: [
                                  if (groupedCalls['Today']!.isNotEmpty)
                                    CallSectionWidget(
                                      sectionTitle: 'Today',
                                      calls: groupedCalls['Today']!,
                                      searchQuery: _searchQuery,
                                      onCallBack: _handleCallBack,
                                      onAddToContacts: _handleAddToContacts,
                                      onBlockNumber: _handleBlockNumber,
                                      onDelete: _handleDeleteCall,
                                      onCallDetails: _handleCallDetails,
                                      onExport: _handleExportCall,
                                      onShare: _handleShareCall,
                                    ),
                                  if (groupedCalls['Yesterday']!.isNotEmpty)
                                    CallSectionWidget(
                                      sectionTitle: 'Yesterday',
                                      calls: groupedCalls['Yesterday']!,
                                      searchQuery: _searchQuery,
                                      onCallBack: _handleCallBack,
                                      onAddToContacts: _handleAddToContacts,
                                      onBlockNumber: _handleBlockNumber,
                                      onDelete: _handleDeleteCall,
                                      onCallDetails: _handleCallDetails,
                                      onExport: _handleExportCall,
                                      onShare: _handleShareCall,
                                    ),
                                  if (groupedCalls['This Week']!.isNotEmpty)
                                    CallSectionWidget(
                                      sectionTitle: 'This Week',
                                      calls: groupedCalls['This Week']!,
                                      searchQuery: _searchQuery,
                                      onCallBack: _handleCallBack,
                                      onAddToContacts: _handleAddToContacts,
                                      onBlockNumber: _handleBlockNumber,
                                      onDelete: _handleDeleteCall,
                                      onCallDetails: _handleCallDetails,
                                      onExport: _handleExportCall,
                                      onShare: _handleShareCall,
                                    ),
                                  if (groupedCalls['Earlier']!.isNotEmpty)
                                    CallSectionWidget(
                                      sectionTitle: 'Earlier',
                                      calls: groupedCalls['Earlier']!,
                                      searchQuery: _searchQuery,
                                      onCallBack: _handleCallBack,
                                      onAddToContacts: _handleAddToContacts,
                                      onBlockNumber: _handleBlockNumber,
                                      onDelete: _handleDeleteCall,
                                      onCallDetails: _handleCallDetails,
                                      onExport: _handleExportCall,
                                      onShare: _handleShareCall,
                                    ),
                                  SizedBox(height: 10.h),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: filteredCalls.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showBulkExportDialog,
              tooltip: 'Export All',
              child: CustomIconWidget(
                iconName: 'file_download',
                color: Colors.white,
                size: 6.w,
              ),
            )
          : null,
    );
  }
}
