// Models (keep existing)
class Project {
  final String name;
  final String reportingToYN;
  final int open;
  final int delayed;
  final int id;
  final int total;

  // Addition for subcounts mapping specifically for "Opened" vs "Delayed"
  final int openUnassigned;
  final int openAssigned;
  final int openSubmitted;
  final int openRejected;
  final int openReassigned;
  final int openForwarded;

  final int delayedUnassigned;
  final int delayedAssigned;
  final int delayedSubmitted;
  final int delayedRejected;
  final int delayedReassigned;
  final int delayedForwarded;

  Project({
    required this.name,
    required this.reportingToYN,
    required this.open,
    required this.delayed,
    required this.id,
    required this.total,
    this.openUnassigned = 0,
    this.openAssigned = 0,
    this.openSubmitted = 0,
    this.openRejected = 0,
    this.openReassigned = 0,
    this.openForwarded = 0,
    this.delayedUnassigned = 0,
    this.delayedAssigned = 0,
    this.delayedSubmitted = 0,
    this.delayedRejected = 0,
    this.delayedReassigned = 0,
    this.delayedForwarded = 0,
    this.isExpandedOpen = false,
    this.isExpandedDelayed = false,
  });

  bool isExpandedOpen;
  bool isExpandedDelayed;

  Project copyWith({
    String? name,
    String? reportingToYN,
    int? open,
    int? delayed,
    int? id,
    int? total,
    int? openUnassigned,
    int? openAssigned,
    int? openSubmitted,
    int? openRejected,
    int? openReassigned,
    int? openForwarded,
    int? delayedUnassigned,
    int? delayedAssigned,
    int? delayedSubmitted,
    int? delayedRejected,
    int? delayedReassigned,
    int? delayedForwarded,
    bool? isExpandedOpen,
    bool? isExpandedDelayed,
  }) {
    return Project(
      name: name ?? this.name,
      reportingToYN: reportingToYN ?? this.reportingToYN,
      open: open ?? this.open,
      delayed: delayed ?? this.delayed,
      id: id ?? this.id,
      total: total ?? this.total,
      openUnassigned: openUnassigned ?? this.openUnassigned,
      openAssigned: openAssigned ?? this.openAssigned,
      openSubmitted: openSubmitted ?? this.openSubmitted,
      openRejected: openRejected ?? this.openRejected,
      openReassigned: openReassigned ?? this.openReassigned,
      openForwarded: openForwarded ?? this.openForwarded,
      delayedUnassigned: delayedUnassigned ?? this.delayedUnassigned,
      delayedAssigned: delayedAssigned ?? this.delayedAssigned,
      delayedSubmitted: delayedSubmitted ?? this.delayedSubmitted,
      delayedRejected: delayedRejected ?? this.delayedRejected,
      delayedReassigned: delayedReassigned ?? this.delayedReassigned,
      delayedForwarded: delayedForwarded ?? this.delayedForwarded,
      isExpandedOpen: isExpandedOpen ?? this.isExpandedOpen,
      isExpandedDelayed: isExpandedDelayed ?? this.isExpandedDelayed,
    );
  }

  int get subtotal => open + delayed;
}
