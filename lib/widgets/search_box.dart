import 'package:flutter/material.dart';

class SearchBox extends StatefulWidget {
  final Function(String)? onSearch;
  final String hintText;

  const SearchBox({
    super.key,
    this.onSearch,
    this.hintText = 'Quick Search',
  });

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(128),
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onSearch,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: const Color.fromARGB(255, 65, 80, 44).withAlpha(128)),
          prefixIcon: Icon(Icons.search, color: const Color.fromARGB(255, 170, 189, 134).withAlpha(128)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
        style: TextStyle(color: const Color.fromARGB(255, 74, 116, 44)),
      ),
    );
  }
}