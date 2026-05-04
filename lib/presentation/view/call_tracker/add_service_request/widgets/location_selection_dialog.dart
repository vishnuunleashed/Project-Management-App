import 'package:base/presentation/views/base_text_field.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/response/call_tracker/location_address_dto.dart';

/// Location selection dialog with vertical card layout
Future<void> showLocationSelectionDialog(
    BuildContext context, {
      required List<LocationModelAddresses> locations,
      required Function(LocationModelAddresses) onSelect,
    }) {
  List<LocationModelAddresses> filteredLocations = List.from(locations);
  final TextEditingController searchController = TextEditingController();

  void filterList(String query) {
    filteredLocations = locations
        .where((location) =>
    location.site!.toLowerCase().contains(query.toLowerCase()) ||
        location.building!.toLowerCase().contains(query.toLowerCase()) ||
        location.floor!.toLowerCase().contains(query.toLowerCase()) ||
        location.address!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  return showDialog(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Theme.of(context).cardColor,
            insetPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 600,
                maxWidth: 800,
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Select Location',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // Search Field
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: BaseTextField(
                      hintText: "Search Locations",
                      hintTextNeeded: true,
                      controller: searchController,
                      maxLines: 1,
                      prefixIcon: const Icon(Icons.search),
                      onChanged: (val) {
                        setState(() {
                          filterList(val);
                        });
                      },
                    ),
                  ),

                  const Divider(height: 1),

                  // List Content
                  Expanded(
                    child: filteredLocations.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 64,
                            color: Theme.of(context).disabledColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No locations found',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    )
                        : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredLocations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final location = filteredLocations[index];
                        return _LocationCard(
                          location: location,
                          onSelect: () {
                            onSelect(location);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),

                ],
              ),
            ),
          );
        },
      );
    },
  );
}

/// Location card widget with vertical layout
class _LocationCard extends StatefulWidget {
  final LocationModelAddresses location;
  final VoidCallback onSelect;

  const _LocationCard({
    required this.location,
    required this.onSelect,
  });

  @override
  State<_LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<_LocationCard> {
  bool isHovered = false;


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {

        widget.onSelect();

      },
      onHover: (hovering) {
        setState(() => isHovered = hovering);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Site
                  _buildField(
                    context,
                    label: 'SITE',
                    value: widget.location.site??'',
                    icon: Icons.business,
                  ),
                  const SizedBox(height: 12),
                  // Building
                  _buildField(
                    context,
                    label: 'BUILDING',
                    value: widget.location.building??"",
                    icon: Icons.apartment,
                  ),
                  const SizedBox(height: 12),
                  // Floor
                  _buildField(
                    context,
                    label: 'FLOOR',
                    value: widget.location.floor??"",
                    icon: Icons.layers,
                  ),
                  const SizedBox(height: 12),
                  // Address
                  _buildField(
                    context,
                    label: 'ADDRESS',
                    value: widget.location.address??"",
                    icon: Icons.location_on,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
      BuildContext context, {
        required String label,
        required String value,
        required IconData icon,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}