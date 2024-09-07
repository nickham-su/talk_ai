import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String) onChanged;

  const CustomSearchBar({super.key, required this.onChanged});

  @override
  CustomSearchBarState createState() => CustomSearchBarState();
}

class CustomSearchBarState extends State<CustomSearchBar> {
  final inputController = TextEditingController();
  final inputFocusNode = FocusNode();
  bool showClearButton = false;

  @override
  Widget build(BuildContext context) {
    var buttons = <Widget>[];
    if (showClearButton) {
      buttons.add(
        IconButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
            minimumSize: MaterialStateProperty.all(Size.zero),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
          icon: SvgPicture.asset(
            'assets/icons/close.svg',
            width: 16,
            height: 16,
            theme: SvgTheme(
              currentColor:
                  Get.theme.colorScheme.inverseSurface.withOpacity(0.5),
            ),
          ),
          onPressed: () {
            inputController.clear();
            widget.onChanged('');
            setState(() {
              showClearButton = false;
            });
            Future.delayed(
              const Duration(milliseconds: 16),
              () => inputFocusNode.requestFocus(),
            );
          },
        ),
      );
    }

    return SearchBar(
      controller: inputController,
      focusNode: inputFocusNode,
      onChanged: (value) {
        widget.onChanged(value);
        if (value.isNotEmpty) {
          setState(() {
            showClearButton = true;
          });
        } else {
          setState(() {
            showClearButton = false;
          });
        }
      },
      trailing: buttons,
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      shadowColor: MaterialStateProperty.all(Colors.transparent),
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.focused)) {
          return Get.theme.colorScheme.inverseSurface.withOpacity(0.1);
        }
        return Get.theme.colorScheme.surface.withOpacity(0.3);
      }),
      padding:
          MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 4)),
      hintText: '搜索',
      textStyle:
          MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
        return TextStyle(
          color: Get.theme.textTheme.bodyMedium?.color,
          fontSize: 12,
          height: 1,
        );
      }),
      hintStyle:
          MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
        if (states.contains(MaterialState.focused)) {
          return TextStyle(
            color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w300,
            height: 1,
          );
        }
        return TextStyle(
          color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.w300,
          height: 1,
        );
      }),
    );
  }
}
