import 'package:flutter/material.dart';
import '../models/application.dart';
import '../models/resume.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/application_list_card.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/kanban_view.dart';
import '../widgets/empty_state_widget.dart';
import 'add_application_screen.dart';
import 'application_details_screen.dart';
import 'resume_library_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Application> _applications = [];
  List<Resume> _resumes = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _sortBy = 'Latest Applied';
  bool _isKanbanView = false;

  final Set<String> _pendingRequestIds = {};
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Load both in parallel; resume failure is non-fatal
      final results = await Future.wait([
        ApiService.getApplications(),
        ApiService.getResumes().catchError((_) => <Resume>[]),
      ]);
      if (mounted) {
        setState(() {
          _applications = results[0] as List<Application>;
          _resumes = results[1] as List<Resume>;
        });
      }
    } catch (e) {
      debugPrint('HomeScreen load error: $e');
      if (mounted) {
        setState(() =>
            _errorMessage = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Filtering / sorting
  // ---------------------------------------------------------------------------

  List<Application> _getFilteredAndSortedApplications() {
    var filtered = _applications.where((app) {
      if (_selectedFilter == 'All') return true;
      return app.status == _selectedFilter;
    }).toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where((app) =>
              app.companyName.toLowerCase().contains(q) ||
              app.role.toLowerCase().contains(q) ||
              app.source.toLowerCase().contains(q))
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

  /// Stats keyed by Kanban column label + Total + rates + pending counts.
  Map<String, dynamic> _calculateStats() {
    final colCounts = <String, int>{
      'Applied': 0,
      'OA': 0,
      'Interview': 0,
      'Offer': 0,
      'Rejected': 0,
    };
    int pendingOA = 0;
    int pendingInterview = 0;

    for (final app in _applications) {
      final col = AppConstants.statusToKanbanColumn(app.status);
      if (colCounts.containsKey(col)) {
        colCounts[col] = colCounts[col]! + 1;
      }
      if (app.status == 'OA Completed') pendingOA++;
      if (app.status == 'Interview Completed') pendingInterview++;
    }
    colCounts['Total'] = _applications.length;

    // Response Rate: apps that reached OA or beyond (excluding Rejected)
    final responded = (colCounts['OA'] ?? 0) +
        (colCounts['Interview'] ?? 0) +
        (colCounts['Offer'] ?? 0);
    final responseRate = _applications.isEmpty
        ? 0.0
        : (responded / _applications.length) * 100;
    final successRate = _applications.isEmpty
        ? 0.0
        : ((colCounts['Offer'] ?? 0) / _applications.length) * 100;

    return {
      ...colCounts,
      'responseRate': responseRate,
      'successRate': successRate,
      'pendingOA': pendingOA,
      'pendingInterview': pendingInterview,
    };
  }

  /// Returns the resume used most across all applications, or null.
  ({Resume resume, int count})? _mostUsedResume() {
    if (_resumes.isEmpty) return null;
    final countMap = <String, int>{};
    for (final app in _applications) {
      if (app.resumeId != null) {
        countMap[app.resumeId!] = (countMap[app.resumeId!] ?? 0) + 1;
      }
    }
    if (countMap.isEmpty) return null;
    final topId =
        countMap.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    final topResume =
        _resumes.where((r) => r.id == topId).firstOrNull;
    if (topResume == null) return null;
    return (resume: topResume, count: countMap[topId]!);
  }

  // ---------------------------------------------------------------------------
  // CRUD handlers
  // ---------------------------------------------------------------------------

  void _handleAddApplication() async {
    final result = await Navigator.push<Application>(
      context,
      MaterialPageRoute(builder: (_) => const AddApplicationScreen()),
    );
    if (result != null && mounted) {
      setState(() => _applications.add(result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application created successfully')),
      );
    }
  }

  void _handleEditApplication(Application app) async {
    final result = await Navigator.push<Application>(
      context,
      MaterialPageRoute(
          builder: (_) => AddApplicationScreen(application: app)),
    );
    if (result != null && mounted) {
      setState(() {
        final idx = _applications.indexWhere((a) => a.id == result.id);
        if (idx != -1) _applications[idx] = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application updated successfully')),
      );
    }
  }

  void _handleDeleteApplication(Application app) {
    if (_pendingRequestIds.contains(app.id)) return;
    showDialog(
      context: context,
      builder: (_) => DeleteConfirmationDialog(
        companyName: app.companyName,
        onConfirm: () => _performDelete(app),
      ),
    );
  }

  Future<void> _performDelete(Application app) async {
    if (_pendingRequestIds.contains(app.id)) return;
    _pendingRequestIds.add(app.id);
    try {
      await ApiService.deleteApplication(app.id);
      if (mounted) {
        setState(() => _applications.removeWhere((a) => a.id == app.id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application deleted successfully')),
        );
      }
    } catch (e) {
      debugPrint('HomeScreen delete error: $e');
      if (mounted) {
        final msg = e.toString().contains('connect')
            ? 'Unable to connect to server'
            : 'Failed to delete application';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      _pendingRequestIds.remove(app.id);
    }
  }

  void _handleStatusChanged(Application app, String newStatus) {
    if (_pendingRequestIds.contains(app.id)) return;
    _pendingRequestIds.add(app.id);

    final updated = app.copyWith(status: newStatus);
    ApiService.updateApplication(updated).then((saved) {
      if (!mounted) return;
      _pendingRequestIds.remove(app.id);
      setState(() {
        final idx = _applications.indexWhere((a) => a.id == app.id);
        if (idx != -1) _applications[idx] = saved;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application updated successfully')),
      );
    }).catchError((e) {
      _pendingRequestIds.remove(app.id);
      debugPrint('HomeScreen status update error: $e');
      if (mounted) {
        final msg = e.toString().contains('connect')
            ? 'Unable to connect to server'
            : 'Failed to update application';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    });
  }

  void _handleShowDetails(Application app) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ApplicationDetailsScreen(
          application: app,
          onEdit: (updated) {
            if (mounted) {
              setState(() {
                final idx =
                    _applications.indexWhere((a) => a.id == updated.id);
                if (idx != -1) _applications[idx] = updated;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Application updated successfully')),
              );
            }
          },
          onDelete: (deleted) {
            if (mounted) {
              setState(() =>
                  _applications.removeWhere((a) => a.id == deleted.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Application deleted successfully')),
              );
            }
          },
        ),
      ),
    );
  }

  void _handleOpenResumeLibrary() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResumeLibraryScreen()),
    );
    // Refresh resume list when returning from library
    if (mounted) {
      final resumes = await ApiService.getResumes()
          .catchError((_) => <Resume>[]);
      if (mounted) setState(() => _resumes = resumes);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Tracker'), elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
        floatingActionButton: FloatingActionButton(
          onPressed: _handleAddApplication,
          child: const Icon(Icons.add),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Tracker'), elevation: 0),
        body: ErrorStateWidget(
          message: _errorMessage!,
          onRetry: _loadAll,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _handleAddApplication,
          child: const Icon(Icons.add),
        ),
      );
    }

    final stats = _calculateStats();
    final displayedApps = _getFilteredAndSortedApplications();
    final hasApplications = _applications.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Tracker'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Resume Library',
            onPressed: _handleOpenResumeLibrary,
          ),
        ],
      ),
      body: hasApplications
          ? Column(
              children: [
                // ── Stat cards row 1: counts ────────────────────────
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      _buildStatCard('Total', stats['Total'] ?? 0,
                          Colors.indigo, Icons.assignment),
                      _buildStatCard(
                          AppConstants.getStatusLabel('Applied'),
                          stats['Applied'] ?? 0,
                          Colors.blue,
                          Icons.send),
                      _buildStatCard(AppConstants.getStatusLabel('OA'),
                          stats['OA'] ?? 0, Colors.orange, Icons.assignment),
                      _buildStatCard(
                          AppConstants.getStatusLabel('Interview'),
                          stats['Interview'] ?? 0,
                          Colors.purple,
                          Icons.forum),
                      _buildStatCard(
                          AppConstants.getStatusLabel('Offer'),
                          stats['Offer'] ?? 0,
                          Colors.green,
                          Icons.verified),
                      _buildStatCard(
                          AppConstants.getStatusLabel('Rejected'),
                          stats['Rejected'] ?? 0,
                          Colors.red,
                          Icons.cancel),
                    ],
                  ),
                ),

                // ── Stat cards row 2: rates + pending + resume summary ──
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md),
                  child: Row(
                    children: [
                      _buildPercentageCard('Response Rate',
                          stats['responseRate'] as double, Colors.blueAccent),
                      const SizedBox(width: AppSpacing.md),
                      _buildPercentageCard('Success Rate',
                          stats['successRate'] as double, Colors.greenAccent),
                      const SizedBox(width: AppSpacing.md),
                      _buildStatCard(
                        'Pending OA\nResults',
                        stats['pendingOA'] as int,
                        Colors.deepOrange,
                        Icons.hourglass_top,
                      ),
                      _buildStatCard(
                        'Pending Interview\nResults',
                        stats['pendingInterview'] as int,
                        Colors.deepPurple,
                        Icons.hourglass_top,
                      ),
                      _buildResumeSummaryCard(),
                    ],
                  ),
                ),

                // ── Search ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search by company, role, or source',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppBorderRadius.md),
                      ),
                    ),
                  ),
                ),

                // ── Filter / sort / view toggle ──────────────────────
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      DropdownButton<String>(
                        value: _selectedFilter,
                        items: ['All', ...AppConstants.statuses]
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedFilter = v);
                        },
                      ),
                      const SizedBox(width: AppSpacing.md),
                      DropdownButton<String>(
                        value: _sortBy,
                        items: [
                          'Latest Applied',
                          'Oldest Applied',
                          'Company A-Z',
                          'Company Z-A',
                        ]
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _sortBy = v);
                        },
                      ),
                      const SizedBox(width: AppSpacing.md),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                              value: false,
                              icon: Icon(Icons.list),
                              label: Text('List')),
                          ButtonSegment(
                              value: true,
                              icon: Icon(Icons.dashboard),
                              label: Text('Kanban')),
                        ],
                        selected: {_isKanbanView},
                        onSelectionChanged: (s) =>
                            setState(() => _isKanbanView = s.first),
                      ),
                    ],
                  ),
                ),

                // ── Content area ────────────────────────────────────
                Expanded(
                  child: displayedApps.isEmpty
                      ? Center(
                          child: Text(
                            'No applications match your filters',
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
                              onStatusChanged: (s) =>
                                  _handleStatusChanged(app, s),
                              onEdit: () => _handleEditApplication(app),
                              onDelete: () =>
                                  _handleDeleteApplication(app),
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

  // ---------------------------------------------------------------------------
  // Card builders
  // ---------------------------------------------------------------------------

  Widget _buildStatCard(
      String title, int count, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: SizedBox(
        width: 110,
        height: 110,
        child: DashboardCard(title: title, count: count, color: color, icon: icon),
      ),
    );
  }

  Widget _buildPercentageCard(String title, double pct, Color color) {
    return SizedBox(
      width: 140,
      height: 110,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.2),
                color.withValues(alpha: 0.05),
              ],
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
                  '${pct.toStringAsFixed(1)}%',
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

  /// Compact resume summary dashboard card.
  Widget _buildResumeSummaryCard() {
    final theme = Theme.of(context);
    final topEntry = _mostUsedResume();
    const color = Colors.teal;

    return SizedBox(
      width: 180,
      height: 110,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md)),
        child: InkWell(
          onTap: _handleOpenResumeLibrary,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.picture_as_pdf,
                          color: color, size: 16),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Resume Library',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Total: ${_resumes.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (topEntry != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      topEntry.resume.name,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${topEntry.count} app${topEntry.count == 1 ? '' : 's'}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
