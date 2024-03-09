import 'package:callup247/src/responsive_text_styles.dart';
import 'package:flutter/material.dart';

class SocialMediaLinkEntry extends StatefulWidget {
  final String platform;
  final String link;
  final Function(String) onDelete;

  const SocialMediaLinkEntry({
    required this.platform,
    required this.link,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  _SocialMediaLinkEntryState createState() => _SocialMediaLinkEntryState();
}

class _SocialMediaLinkEntryState extends State<SocialMediaLinkEntry> {
  // bool _showTextField = false;
  final TextEditingController _linkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: const Color(0xFFF0F1F6),
          title: Text(
            widget.platform,
            style: responsiveTextStyle(
                context, 14, const Color(0xFF383636), FontWeight.w500),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Color(0xFF000000),
                  size: 16,
                ),
                onPressed: () {
                  widget.onDelete(widget.platform);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 4)
      ],
    );
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }
}
