import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/profile/profile_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/profile/profile_screen.dart';

import 'change_password_screen.dart';

class PersonalInformation extends StatelessWidget {
  PersonalInformation({super.key});
  String _toCamelCase(String input) {
    if (input.isEmpty) return '';
    return input
        .split(' ')
        .map((word) =>
    word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<ProfileProvider>(
      initState: (context,provider,ref){},
      provider: profileProvider,
      builder: (context, provider, ref) => Column(
        children: [
          Stack(
            alignment: Alignment.topLeft,
            children: [
              const CurvedHeader(),
              Positioned(
                top: 0,
                left: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: CircularBackButton(
                    onTap: () => GoRouter.of(context).pop(),
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 20),
          Text(
            _toCamelCase(provider.userName),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                const SectionTitle(title: "PERSONAL INFORMATION"),
                const SizedBox(height: 14),
                InfoRow(label: "Name", value: provider.userName),
                EditableInfoRow(label: "Login name", value: provider.loginName,onSubmit: (name)async{
                        provider.updateUserName(name);
                  },
                ),
                InfoRow(label: "Email", value: provider.userEmailId),
                InfoRow(label: "Department", value: provider.departmentName),
                InfoRow(label: "Phone", value: provider.phoneNo),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Divider(
          color: Theme.of(context).primaryColor.withOpacity(0.6),
          thickness: 1,
        ),
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.trim().isEmpty) {
      return const SizedBox.shrink(); // 👈 Don't show anything if empty
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(

              ),
            ),
          ),
          Expanded(
            child: Text(
              value!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500

              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditableInfoRow extends StatefulWidget {
  final String label;
  final String? value;
  final Future<void> Function(String newValue)? onSubmit;

  const EditableInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.onSubmit,
  });

  @override
  State<EditableInfoRow> createState() => _EditableInfoRowState();
}

class _EditableInfoRowState extends State<EditableInfoRow> {
  bool isEditing = false;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value ?? "");
  }

  @override
  Widget build(BuildContext context) {
    if (widget.value == null || widget.value!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LABEL
          SizedBox(
            width: 110,
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(

              ),
            ),
          ),

          // VALUE or TEXT FIELD
          Expanded(
            child: isEditing ? _buildEditingField() : _buildValueText(),
          ),
        ],
      ),
    );
  }

  Widget _buildValueText() {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.value!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500
            ),
          ),
        ),

        // EDIT ICON
        GestureDetector(
          onTap: () {
            setState(() => isEditing = true);
          },
          child: const Icon(Icons.edit, size: 18),
        ),
      ],
    );
  }

  Widget _buildEditingField() {
    return TextFormField(
      controller: controller,
      autofocus: true,

      style:Theme.of(context).textTheme.titleSmall,
      decoration: InputDecoration(
        labelStyle: Theme.of(context).textTheme.titleMedium,
        hintStyle:  Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).disabledColor,
        ),
        isDense: true,
        suffixIcon: IconButton(
          icon: const Icon(Icons.check),
          onPressed: _submit,
        ),
      ),
      onFieldSubmitted: (_) => _submit(),
    );
  }

  Future<void> _submit() async {
    final newVal = controller.text.trim();

    if (widget.onSubmit != null) {
      await widget.onSubmit!(newVal); // API call
    }

    setState(() {
      isEditing = false;
    });
  }
}
