import 'package:flutter/material.dart';
import '../models/application.dart';
import '../services/sample_data.dart';
import '../utils/constants.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/application_list_card.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/kanban_view.dart';
import '../widgets/empty_state_widget.dart';
import 'add_application_screen.dart';
import 'application_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Application> _applications;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _sortBy = 'Latest Applied';
  bool _isKanbanView = false;

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _applications = List.from(sampleApplications);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Application> _getFilteredAndSortedApplications() {
    var filtered = _applications.where((app) {
      if (_selectedFilter == 'All') return true;
      return app.status == _selectedFilter;
    }).toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (app) =>
                app.companyName.toLowerCase().contains(query) ||
                app.role.toLowerCase().contains(query) ||
                app.source.toLowerCase().contains(query),
          )
          .toList();
    }

    switch (_sortBy) {
      case 'Latest Applied':
        filtered.sort((a, b) => b.dateApplied.compareTo(a.dateApplied));
        break;
      case 'Oldest Applied':
        filtered.sort((a, b) => a.dateApplied.compareTo(b.dateApplied));
        break;
      case 'Company A-Z':
        filtered.sort((a, b) => a.companyName.compareTo(b.companyName));
        break;
      case 'Company Z-A':
        filtered.sort((a, b) => b.companyName.compareTo(a.companyName));
        break;
    }

    return filtered;
  }

  Map<String, dynamic> _calculateStats() {
    final stats = <String, int>{
      'Applied': 0,
      'OA': 0,
      'Interview': 0,
      'Selected': 0,
      'Rejected': 0,
    };
    for (var app in _applications) {
      if (stats.containsKey(app.status)) {
        stats[app.status] = stats[app.status]! + 1;
      }
    }
    stats['Total'] = _applications.length;

    // Calculate response rate: (OA + Interview + Selected) / Total
    final responseCount =
        (stats['OA'] ?? 0) +
        (stats['Interview'] ?? 0) +
        (stats['Selected'] ?? 0);
    final responseRate = _applications.isEmpty
        ? 0.0
        : (responseCount / _applications.length) * 100;

    // Calculate success rate: Selected / Total
    final successRate = _applications.isEmpty
        ? 0.0
        : ((stats['Selected'] ?? 0) / _applications.length) * 100;

    return {...stats, 'responseRate': responseRate, 'successRate': successRate};
  }

  void _handleAddApplication() async {
    final result = await Navigator.push<Application>(
      context,
      MaterialPageRoute(builder: (context) => const AddApplicationScreen()),
    );
    if (result != null) {
      setState(() {
        _applications.add(result);
      });
    }
  }

  void _handleEditApplication(Application app) async {
    final result = await Navigator.push<Application>(
      context,
      MaterialPageRoute(
        builder: (context) => AddApplicationScreen(application: app),
      ),
    );
    if (result != null) {
      setState(() {
        final index = _applications.indexWhere((a) => a.id == app.id);
        if (index != -1) {
          _applications[index] = result;
        }
      });
    }
  }

  void _handleDeleteApplication(Application app) {
    setState(() {
      _applications.removeWhere((a) => a.id == app.id);
    });
  }

  void _handleStatusChanged(Application app, String newStatus) {
    setState(() {
      final index = _applications.indexWhere((a) => a.id == app.id);
      if (index != -1) {
        _applications[index] = app.copyWith(status: newStatus);
      }
    });
  }

  void _handleShowDetails(Application app) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplicationDetailsScreen(
          application: app,
          onEdit: (updated) {
            setState(() {
              final index = _applications.indexWhere((a) => a.id == app.id);
              if (index != -1) {
                _applications[index] = updated;
              }
            });
          },
          onDelete: (deleted) {
            setState(() {
              _applications.removeWhere((a) => a.id == deleted.id);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();
    final displayedApps = _getFilteredAndSortedApplications();
    final hasApplications = _applications.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Job Tracker'), elevation: 0),
      body: hasApplications
          ? Column(
              children: [
                // Dashboard Cards with Icons and Stats
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      _buildStatCard(
                        'Total',
                        stats['Total'] ?? 0,
                        Colors.indigo,
                        Icons.assignment,
                      ),
                      _buildStatCard(
                        AppConstants.getStatusLabel('Applied'),
                        stats['Applied'] ?? 0,
                        Colors.blue,
                        Icons.send,
                      ),
                      _buildStatCard(
                        AppConstants.getStatusLabel('OA'),
                        stats['OA'] ?? 0,
                        Colors.orange,
                        Icons.assignment,
                      ),
                      _buildStatCard(
                        AppConstants.getStatusLabel('Interview'),
                        stats['Interview'] ?? 0,
                        Colors.purple,
                        Icons.forum,
                      ),
                      _buildStatCard(
                        AppConstants.getStatusLabel('Selected'),
                        stats['Selected'] ?? 0,
                        Colors.green,
                        Icons.verified,
                      ),
                      _buildStatCard(
                        AppConstants.getStatusLabel('Rejected'),
                        stats['Rejected'] ?? 0,
                        Colors.red,
                        Icons.close,
                      ),
                    ],
                  ),
                ),

                // Response Rate and Success Rate Stats
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      _buildPercentageCard(
                        'Response Rate',
                        stats['responseRate'] as double,
                        Colors.blueAccent,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _buildPercentageCard(
                        'Success Rate',
                        stats['successRate'] as double,
                        Colors.greenAccent,
                      ),
                    ],
                  ),
                ),

                // Search Field
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by company, role, or source',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                    ),
                  ),
                ),

                // Filter, Sort, View Toggle
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      DropdownButton<String>(
                        value: _selectedFilter,
                        items: ['All', ...AppConstants.statuses]
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedFilter = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: AppSpacing.md),
                      DropdownButton<String>(
                        value: _sortBy,
                        items:
                            [
                                  'Latest Applied',
                                  'Oldest Applied',
                                  'Company A-Z',
                                  'Company Z-A',
                                ]
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _sortBy = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: AppSpacing.md),
                      SegmentedButton<bool>(
                        segments: const <ButtonSegment<bool>>[
                          ButtonSegment<bool>(
                            value: false,
                            icon: Icon(Icons.list),
                            label: Text('List'),
                          ),
                          ButtonSegment<bool>(
                            value: true,
                            icon: Icon(Icons.dashboard),
                            label: Text('Kanban'),
                          ),
                        ],
                        selected: <bool>{_isKanbanView},
                        onSelectionChanged: (Set<bool> newSelection) {
                          setState(() {
                            _isKanbanView = newSelection.first;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Content Area (List or Kanban)
                Expanded(
                  child: displayedApps.isEmpty
                      ? Center(
                          child: Text(
                            'No applications found',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : _isKanbanView
                      ? KanbanView(
                          applications: displayedApps,
                          onStatusChanged: _handleStatusChanged,
                          onDetails: _handleShowDetails,
                          onEdit: _handleEditApplication,
                          onDelete: _handleDeleteApplication,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: displayedApps.length,
                          itemBuilder: (context, index) {
                            final app = displayedApps[index];
                            return ApplicationListCard(
                              application: app,
                              onDetails: () => _handleShowDetails(app),
                              onStatusChanged: (newStatus) =>
                                  _handleStatusChanged(app, newStatus),
                              onEdit: () => _handleEditApplication(app),
                              onDelete: () => _handleDeleteApplication(app),
                            );
                          },
                        ),
                ),
              ],
            )
          : EmptyStateWidget(onAddPressed: _handleAddApplication),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddApplication,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: SizedBox(
        width: 110,
        height: 110,
        child: DashboardCard(
          title: title,
          count: count,
          color: color,
          icon: icon,
        ),
      ),
    );
  }

  Widget _buildPercentageCard(String title, double percentage, Color color) {
    return SizedBox(
      width: 140,
      height: 110,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
