import 'package:aws_s3_upload_lite/aws_s3_upload_lite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearmessageapp/services/general/imageUpload.dart';
import 'package:nearmessageapp/services/general/localstorage.dart';

class Profilepage extends StatefulWidget {
  final String userId;
  const Profilepage({super.key, required this.userId});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  Uint8List? profilePic;
  String? username;

  void selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);
    setState(() {
      profilePic = img;
    });
    if (img != null) {
      AwsS3.uploadUint8List(
        accessKey: "",
        secretKey: "",
        file: img,
        bucket: "hotzone-talwar",
        region: "eu-central-1",
        destDir: "profilePics",
        filename: "${widget.userId}.png",
      );
      saveDataToLocalStorage("profilePicURL", "https://hotzone-talwar.s3.eu-central-1.amazonaws.com/profilePics/${widget.userId}.png");
    }
  }

  @override
  Widget build(BuildContext context) {
    readDataFromLocalStorage("username").then((data) {
      setState(() {
        username = data;
      });
    });
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: const Color.fromARGB(255, 0, 34, 255),
        title: const Text("Profile Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  )),
              child: OutlinedButton(
                  style: OutlinedButton.styleFrom(side: BorderSide.none),
                  onPressed: () {
                    selectImage();
                  },
                  child: Stack(children: [
                    profilePic == null
                        ? const CircleAvatar(
                            radius: 64,
                            backgroundImage: NetworkImage(
                                "https://hotzone-talwar.s3.eu-central-1.amazonaws.com/istockphoto-1130884625-612x612.jpg"),
                          )
                        : CircleAvatar(
                            radius: 64,
                            backgroundImage: MemoryImage(profilePic!))
                  ])),
            ),
          ],
        ),
      ),
    );
  }
}
