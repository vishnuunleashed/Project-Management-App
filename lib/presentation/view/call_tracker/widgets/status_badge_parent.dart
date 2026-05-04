// Status Badge Widget - Automatic Status Selection
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';

/// A unified widget that automatically displays the correct status badge
/// based on the provided status string.
class StatusBadge extends StatelessWidget {
  final String status;
  final StatusButtonSize size;

  const StatusBadge({
    super.key,
    required this.status,
    this.size = StatusButtonSize.standard,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.toLowerCase().trim();

    switch (normalizedStatus) {

      case 'assignment pending':
      case 'pending assignment':
      case 'assignmentpending':
        return _buildBadge(
          'PENDING',
          const Color(0xFFFF8C00),
          size,
        );

      case 'assigned':
        return _buildBadge(
          'ASSIGNED',
          Color(0xFF1E88E5),
          size,
        );

      case 'in progress':
      case 'inprogress':
      case 'progress':
      case 'ongoing':
        return _buildBadge(
          'IN PROGRESS',
          Color(0xFFF97316),
          size,
        );

      case 'submitted':
      case 'submit':
        return _buildBadge(
          'SUBMITTED',
          Color(0xFF2196F3),
          size,
        );

      case 'reviewed':
      case 'review':
        return _buildBadge(
          'REVIEWED',
          Color(0xFF2E7D32),
          size,
        );

      case 'accepted':   //  ADDED
      case 'accept':
        return _buildBadge(
          'ACCEPTED',
          Color(0xFF4CAF50),
          size,
        );

      case 'closed':
        return _buildBadge(
          'CLOSED',
          Color(0xFF4CAF50), // same success tone
          size,
        );

      case 'send back':
      case 'sendback':
      case 'returned':
      case 'revision':
        return _buildBadge(
          'REJECTED',
          bayaInfraRed,
          size,
        );

      case 'rejected':
        return _buildBadge(
          'REJECTED',
          Color(0xFFF44336),
          size,
        );

      case 'reopened':
        return _buildBadge(
          'REOPENED',
          Color(0xFFE91E63),
          size,
        );
      case 'Cancelled'||'cancelled'||'CANCELLED':
        return _buildBadge(
          'CANCELLED',
          Color(0xFFF44336),
          size,
        );
      default:
        return _buildBadge(
          status.toUpperCase(),
          Color(0xFF6B7280),
          size,
        );
    }
  }

  Widget _buildBadge(String label, Color color, StatusButtonSize size) {
    final dimensions = _getDimensions(size);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions['paddingH']!,
        vertical: dimensions['paddingV']!,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: dimensions['fontSize']!,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Map<String, double> _getDimensions(StatusButtonSize size) {
    switch (size) {
      case StatusButtonSize.compact:
        return {
          'paddingH': 12.0,
          'paddingV': 6.0,
          'fontSize': 11.0,
        };
      case StatusButtonSize.large:
        return {
          'paddingH': 16.0,
          'paddingV': 10.0,
          'fontSize': 14.0,
        };
      default:
        return {
          'paddingH': 14.0,
          'paddingV': 8.0,
          'fontSize': 12.0,
        };
    }
  }
}

/// Status button size options
enum StatusButtonSize {
  compact,
  standard,
  large,
}

/// Enum for all available assignment statuses
enum AssignmentStatus {
  assignmentPending,
  assigned,
  inProgress,
  submitted,
  reviewed,
  closed,
  sendBack;

  String get displayName {
    switch (this) {
      case AssignmentStatus.assignmentPending:
        return 'Assignment Pending';
      case AssignmentStatus.assigned:
        return 'Assigned';
      case AssignmentStatus.inProgress:
        return 'In Progress';
      case AssignmentStatus.submitted:
        return 'Submitted';
      case AssignmentStatus.reviewed:
        return 'Reviewed';
      case AssignmentStatus.closed:
        return 'Closed';
      case AssignmentStatus.sendBack:
        return 'Send Back';
    }
  }

  Widget toBadge({
    StatusButtonSize size = StatusButtonSize.standard,
  }) {
    return StatusBadge(
      status: displayName,
      size: size,
    );
  }
}