import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:mobile_client/core/di/injection.dart';
import 'package:mobile_client/core/rust/api.dart';
import 'package:mobile_client/core/rust/api/notes.dart';
import 'package:mobile_client/core/rust/dto/note.dart';
import 'package:mobile_client/core/rust/dto/query.dart';
import 'package:mobile_client/l10n/app_localizations.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  // Access NoteCore from GetIt and get the NotesApi instance[cite: 27, 28]
  late final NotesApi _notesApi = getIt<NoteCore>().notes();

  List<NoteGroupDto> _groups = [];
  List<NoteListItemDto> _notes = [];
  PlatformInt64? _selectedGroupId; // null represents "All"

  bool _isLoading = true;

  // Multi-selection state
  final Set<PlatformInt64> _selectedNoteIds = {};
  bool get _isSelecting => _selectedNoteIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Fetch groups and notes concurrently using NotesApi methods[cite: 29]
      final groups = await _notesApi.getGroups();
      
      const paginationReq = ListRequestDto(currentPage: 1, limit: 50);
      final notes = _selectedGroupId == null
          ? await _notesApi.getList(req: paginationReq)
          : await _notesApi.getListInGroup(
              req: paginationReq,
              groupId: _selectedGroupId!,
            );

      setState(() {
        _groups = groups;
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notes: $e')),
        );
      }
    }
  }

  void _onGroupSelected(PlatformInt64? groupId) {
    if (_selectedGroupId == groupId) return;
    setState(() {
      _selectedGroupId = groupId;
      _selectedNoteIds.clear();
    });
    _loadData();
  }

  void _toggleSelection(PlatformInt64 noteId) {
    setState(() {
      if (_selectedNoteIds.contains(noteId)) {
        _selectedNoteIds.remove(noteId);
      } else {
        _selectedNoteIds.add(noteId);
      }
    });
  }

  Future<void> _deleteSelectedNotes() async {
    try {
      for (var id in _selectedNoteIds) {
        await _notesApi.deleteNote(id: id); //[cite: 29]
      }
      _selectedNoteIds.clear();
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete notes: $e')),
        );
      }
    }
  }

  Future<void> _showChangeGroupDialog() async {
    final l10n = AppLocalizations.of(context)!;
    
    // Show dialog to pick a target group or remove from group (null)
    final PlatformInt64? targetGroupId = await showDialog<PlatformInt64?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.notes_select_group),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Text(l10n.notes_unassigned),
                  onTap: () => Navigator.pop(context, null),
                ),
                ..._groups.map((group) {
                  return ListTile(
                    title: Text(group.name),
                    onTap: () => Navigator.pop(context, group.id),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (targetGroupId != null || targetGroupId == null) {
      try {
        await _notesApi.addToGroup(
          groupId: targetGroupId,
          noteIds: Int64List.fromList(_selectedNoteIds.map((id) => id.toInt()).toList()),
        ); //[cite: 29]
        _selectedNoteIds.clear();
        await _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to change group: $e')),
          );
        }
      }
    }
  }

  Future<void> _createNewNote() async {
    try {
      await _notesApi.createNote(); //[cite: 29]
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create note: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _isSelecting
          ? AppBar(
              backgroundColor: colorScheme.surfaceContainerHighest,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selectedNoteIds.clear()),
              ),
              title: Text(l10n.notes_selected_count(_selectedNoteIds.length)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.drive_file_move_outline),
                  tooltip: l10n.notes_change_group,
                  onPressed: _showChangeGroupDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.notes_delete,
                  onPressed: _deleteSelectedNotes,
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          // Top Sideways Slider for Groups
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // 'All' button chip
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(l10n.notes_all),
                    selected: _selectedGroupId == null,
                    onSelected: (_) => _onGroupSelected(null),
                  ),
                ),
                // Dynamic group chips
                ..._groups.map((group) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(group.name),
                      selected: _selectedGroupId == group.id,
                      onSelected: (_) => _onGroupSelected(group.id),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.8),

          // Main View: List of Note Cards
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notes.isEmpty
                    ? Center(
                        child: Text(
                          l10n.notes_empty,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _notes.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final note = _notes[index];
                          final isSelected = _selectedNoteIds.contains(note.id);

                          return Card(
                            elevation: 0,
                            color: isSelected
                                ? colorScheme.primaryContainer.withValues(alpha: 0.4)
                                : colorScheme.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.outlineVariant.withValues(alpha: 0.5),
                              ),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                if (_isSelecting) {
                                  _toggleSelection(note.id);
                                } else {
                                  // TODO: Navigate to single note view in next message
                                }
                              },
                              onLongPress: () => _toggleSelection(note.id),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            note.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.check_circle,
                                            color: colorScheme.primary,
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      note.preview,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: 13,
                                      ),
                                    ),
                                    if (note.tags.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: note.tags.map((tag) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorScheme.secondaryContainer,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              tag.name,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: colorScheme.onSecondaryContainer,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}