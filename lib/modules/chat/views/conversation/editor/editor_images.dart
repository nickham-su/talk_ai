import 'package:TalkAI/modules/chat/controllers/editor_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class EditorImages extends StatelessWidget {
  const EditorImages({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditorController>(
      id: 'editor_images',
      builder: (controller) {
        if (controller.files.isEmpty) {
          return const SizedBox();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.only(left: 14),
          height: 66,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.files.length,
            itemBuilder: (context, index) {
              final file = controller.files[index];
              return Container(
                margin: const EdgeInsets.only(right: 8),
                width: 66,
                height: 66,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Get.theme.colorScheme.primaryContainer,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.file(
                            file,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Get.theme.colorScheme.primaryContainer,
                            ),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          icon: SvgPicture.asset(
                            'assets/icons/close.svg',
                            width: 14,
                            height: 14,
                            theme: SvgTheme(
                              currentColor:
                                  Get.theme.colorScheme.inverseSurface,
                            ),
                          ),
                          onPressed: () {
                            controller
                              ..removeFile(file)
                              ..focus();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
