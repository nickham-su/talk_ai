import 'package:flutter/material.dart';

class TagSelector extends StatefulWidget {
  @override
  _TagSelectorState createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  List<String> _tags = [];
  TextEditingController _textEditingController = TextEditingController();

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }
    _textEditingController.clear();
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Wrap(
        spacing: 4.0,
        // runSpacing: 4.0,
        children: [
          ..._tags.map((tag) => Container(
                // height: 40,
                child: Chip(
                  padding: EdgeInsets.zero,
                  label: Text(tag, style: TextStyle(fontSize: 14, height: 1)),
                  onDeleted: () => _removeTag(tag),
                ),
              )),
          Container(
            width: 100,
            height: 30,
            child: TextField(
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                height: 1,
              ),
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: '添加标签',
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 16),
              ),
              onSubmitted: _addTag,
            ),
          ),
        ],
      ),
    );
  }
}
