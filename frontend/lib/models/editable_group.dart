/// Mutable-by-copyWith representation of a merge group being edited by the user
/// in the tag consolidation preview screen.
class EditableGroup {
  const EditableGroup({
    required this.originalCanonical,
    required this.canonical,
    required this.selectedMerged,
    required this.isEnabled,
    required this.itemsAffected,
  });

  /// The canonical name originally suggested by the AI (preserved for hint display).
  final String originalCanonical;

  /// The (possibly user-renamed) canonical tag that merged tags will become.
  final String canonical;

  /// All merged tags keyed to whether they are selected.
  /// Using Map to preserve insertion order for consistent rendering.
  final Map<String, bool> selectedMerged;

  /// Whether the entire group is active. When false the group is skipped on apply.
  final bool isEnabled;

  /// Item count from the preview response — informational only.
  final int itemsAffected;

  /// Tags currently selected to be merged (the subset that will be sent to the backend).
  List<String> get activeMerged =>
      selectedMerged.entries.where((e) => e.value).map((e) => e.key).toList();

  /// True when this group will produce at least one merge on apply.
  bool get willApply => isEnabled && activeMerged.isNotEmpty;

  /// True when the user has changed the canonical name from the AI suggestion.
  bool get isRenamed => canonical != originalCanonical;

  EditableGroup copyWith({
    String? canonical,
    Map<String, bool>? selectedMerged,
    bool? isEnabled,
  }) =>
      EditableGroup(
        originalCanonical: originalCanonical,
        canonical: canonical ?? this.canonical,
        selectedMerged: selectedMerged ?? this.selectedMerged,
        isEnabled: isEnabled ?? this.isEnabled,
        itemsAffected: itemsAffected,
      );

  /// Serialize to the wire format consumed by ApplyConsolidateRequest.
  Map<String, dynamic> toApiJson() => {
        'canonical': canonical,
        'merged': activeMerged,
      };
}
