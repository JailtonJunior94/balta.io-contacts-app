import 'dart:io';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:path_provider/path_provider.dart';

class CropPictureView extends StatefulWidget {
  final String path;
  CropPictureView({@required this.path});

  @override
  _CropPictureViewState createState() => _CropPictureViewState();
}

class _CropPictureViewState extends State<CropPictureView> {
  final cropKey = GlobalKey<CropState>();

  Future<String> save() async {
    try {
      final uuid = Uuid();
      final documents = await getApplicationDocumentsDirectory();

      final fileName = "${uuid.v4()}.jpg";
      final path = join(documents.path, fileName);

      final croppedFile = await ImageCrop.cropImage(
        file: File(widget.path),
        area: cropKey.currentState.area,
      );

      final bytes = await croppedFile.readAsBytes();
      final buffer = bytes.buffer;

      File(path).writeAsBytes(
        buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );

      return path;
    } catch (error) {
      print(error);
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recortar Image"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Crop(
        key: cropKey,
        image: FileImage(
          File(widget.path),
        ),
        aspectRatio: 1 / 1,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {
          save().then((path) {
            Navigator.pop(context, path);
          });
        },
      ),
    );
  }
}
