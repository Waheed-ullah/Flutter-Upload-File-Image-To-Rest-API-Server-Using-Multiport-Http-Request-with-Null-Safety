import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({super.key});

  @override
  State<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? image;
  final _picker = ImagePicker();
  bool showSpinner = false;
  Future getImage() async {
    //Image from Camera******ImageSource.camera
    //Image from Gallery******ImageSource.gallery

    final pickedFile =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);

    if (pickedFile != null) {
      image = File(pickedFile.path);
      setState(() {});
    } else {
      print("No Image Selected");
    }
  }

  Future<void> upload() async {
    setState(() {
      showSpinner = true;
    });
    var stream = http.ByteStream(image!.openRead());
    stream.cast();

    var length = await image!.length();

    var uri = Uri.parse("https://fakestoreapi.com/products");
    var request = http.MultipartRequest("POST", uri);
    request.fields["title"] = "Static title";
    var multipart = http.MultipartFile("image", stream, length);
    request.files.add(multipart);
    var responce = await request.send();
    print(responce.stream.toString());
    if (responce.statusCode == 200) {
      setState(() {
        showSpinner = false;
      });
      print("Image Uploaded");
    } else {
      setState(() {
        showSpinner = false;
      });
      print("Failded");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: const Text("Image Upload Screen"),
        ),
        body: Column(
          children: [
            GestureDetector(
              onTap: () {
                getImage();
              },
              child: Container(
                  width: 200,
                  color: Colors.black,
                  margin: const EdgeInsets.only(top: 20),
                  child: image == null
                      ? const Center(
                          child: Text(
                            "Pick Image",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 22),
                          ),
                        )
                      : Container(
                          child: Center(
                          child: Image.file(
                            File(image!.path).absolute,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ))),
            ),
            const SizedBox(
              height: 120,
            ),
            GestureDetector(
                onTap: () {
                  upload();
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  height: 56,
                  color: Colors.indigo,
                  child: const Center(
                    child: Text(
                      "Upload",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18),
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
