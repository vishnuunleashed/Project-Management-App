
class ScheduleProject {
  final String name;
  final String reportingToYN;
  final int totalTasksOpen;
  final int totalPending;

  final int projectId;
  final int delayedTasks;
  final int inProgressTasks;
  final int supportRequestsToOvercomeDelay;
  final int total;

  ScheduleProject({
    required this.projectId,
    required this.name,
    required this.reportingToYN,
    required this.totalTasksOpen,
    required this.delayedTasks,
    required this.inProgressTasks,
    required this.supportRequestsToOvercomeDelay,
    required this.totalPending,
    required this.total,
  });

  int get subtotal => totalPending;
}
