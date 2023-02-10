import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_sizes/file_sizes.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:fuodz/widgets/custom_grid_view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:image_picker/image_picker.dart';

class DocumentSelectionView extends StatefulWidget {
  DocumentSelectionView({
    Key key,
    this.title = "",
    this.instruction = "",
    this.max,
    this.onSelected,
  }) : super(key: key);

  final int max;
  final String title;
  final String instruction;
  final Function(List<File> documents) onSelected;
  @override
  State<DocumentSelectionView> createState() => _DocumentSelectionViewState();
}

class _DocumentSelectionViewState extends State<DocumentSelectionView> {
  //
  List<File> selectedFiles = [];
  List<PlatformFile> selectedPlatformFiles = [];
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        "${widget.title}".text.xl.semiBold.make(),
        "${widget.instruction}".text.lg.light.make(),

        //
        CustomGridView(
          dataSet: selectedPlatformFiles,
          childAspectRatio: 1.5,
          noScrollPhysics: true,
          itemBuilder: (ctx, index) {
            final platformFile = selectedPlatformFiles[index];
            return VStack(
              [
                "${platformFile.name}"
                    .text
                    .medium
                    .sm
                    .maxLines(2)
                    .ellipsis
                    .make(),
                "${FileSize.getSize(platformFile.size)}".text.sm.make(),
                "${platformFile.extension}".text.xs.italic.make(),
              ],
            )
                .p8()
                .box
                .roundedSM
                .border(color: Colors.grey.shade400)
                .make()
                .p8();
          },
          emptyWidget: "Nothing selected. Tap to select"
              .tr()
              .text
              .make()
              .centered()
              .p20(),
        )
            .box
            .border(color: Colors.grey.shade400)
            .roundedSM
            .outerShadowSm
            .make()
            .onInkTap(openFileSelector)
            .py12(),
      ],
    );
  }

  openFileSelector() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      selectedFiles = result.paths.map((path) => File(path)).toList();
      selectedPlatformFiles = result.files;
      if (selectedFiles.length > widget.max) {
        selectedFiles = selectedFiles.sublist(0, widget.max);
        selectedPlatformFiles = selectedPlatformFiles.sublist(0, widget.max);
      }

      //
      widget.onSelected(selectedFiles);
      setState(() {
        selectedFiles = selectedFiles;
        selectedPlatformFiles = selectedPlatformFiles;
      });
    } else {
      ToastService.toastError("No Document selected".tr());
    }
  }
}
