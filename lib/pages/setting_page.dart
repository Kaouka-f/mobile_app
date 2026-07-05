import 'package:kaouka/components/custom_elevated_button.dart';
import 'package:kaouka/components/kavatar.dart';
import 'package:kaouka/pages/account_page.dart';
import 'package:kaouka/pages/politique_page.dart';
import 'package:kaouka/theme.dart';
import '../components/custom_toggle_button.dart';
import '../notifiers/visible_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/shared_data.dart';

class SettingPage extends StatefulWidget {
  final Function changed;

  const SettingPage({super.key, required this.changed});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final TextEditingController _controller = TextEditingController();
  late String id;
  String hintText = 'undefined';
  String imageUrl = "https://elaborium.site/proxy/stream/default/profile.jpg";
  double imageScale = 1.0;
  double imageSize = 200;
  Offset imageOffset = const Offset(0.0, 0.0);
  late bool isToogled;
  bool deleteCache = false;
  SharedData shared = SharedData();

  String deleteCacheTitle = "Supprimer tous les messages";
  String deleteCacheMessage =
      "En supprimant le cache, tous les messages et contact de l'application seront supprimé. Etes-vous sur de vouloir supprimer le cache ?";

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void initSharedPref() async {
    String? encodedid = shared.getId;
    String? url = shared.getImageUrl;
    double? scale = shared.getImageScale;
    double? offsetX = shared.getImageOffset.dx;
    double? offsetY = shared.getImageOffset.dy;
    bool? visible = shared.getVisible;
    String? name = shared.getName;
    setState(() {
      id = encodedid;
      imageUrl = url;
      imageScale = scale > 0.0 ? scale : 1.0;
      imageOffset = Offset(offsetX, offsetY);
      isToogled = visible;
      hintText = name;
    });
  }

  void _submit() async {
    print(imageUrl);
    hintText != shared.name ? shared.setName = hintText : "undefined";
    if (imageUrl != shared.imageUrl) shared.setImageUrl = imageUrl;
    imageScale != shared.imageScale ? shared.setImageScale = imageScale : null;
    imageOffset != shared.imageOffset
        ? shared.setImageOffset = imageOffset
        : null;
    widget.changed();
  }

  void imageChanged(String imgUrl, Offset offset) async {
    setState(() {
      imageUrl = imgUrl;
      imageOffset = offset;
    });
  }

  void _updateImageScale(double value) {
    setState(() {
      imageScale = value;
    });
  }

  void _closeKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    bool isVisible =
        Provider.of<PersistentVisibleProvider>(context).isVisibleChanged;
    return Scaffold(
      appBar: AppBar(
        title: const Text("settings"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                  // border: Border.all(color: Colors.grey),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    children: [
                      KAvatar(
                        imageAssetPath: imageUrl,
                        scale: imageScale,
                        offset: imageOffset,
                        imageChanged: imageChanged,
                        radius: 50,
                        isSetter: true,
                      ),
                      const SizedBox(height: 20.0),
                      Slider(
                        min: 0.0,
                        max: 5.0,
                        value: imageScale,
                        onChanged: _updateImageScale,
                        thumbColor: sliderThumbColor,
                        activeColor: sliderActiveColor,
                        inactiveColor: sliderInactiveColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Nom: "),
                      const SizedBox(width: 20.0),
                      Expanded(
                        child: TextField(
                          scrollPhysics: const AlwaysScrollableScrollPhysics(),
                          cursorColor: Colors.white,
                          readOnly: false,
                          controller: _controller,
                          decoration: InputDecoration(
                            constraints: const BoxConstraints(
                              maxHeight: 40.0,
                            ),
                            counterText: '',
                            hintText: hintText,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              hintText = value;
                            });
                            // hintText = value;
                            // shared.setName = value;
                          },
                          onTapOutside: (pointer) => _closeKeyboard(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isVisible ? 'visible: ' : 'invisible: ',
                        // style: const TextStyle(color: textColor, fontSize: 20),
                      ),
                      CustomToggleButton(
                        isToggled: isToogled,
                        showText: true,
                        onChanged: (value) async {
                          isToogled = value;
                          Provider.of<PersistentVisibleProvider>(context,
                                  listen: false)
                              .setVisibleChanged(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              GestureDetector(
                onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AccountPage()),
                  )
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Compte"),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              GestureDetector(
                onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PolitiquePage()),
                  )
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Politique"),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              CustomElevatedButton(onPressed: _submit, text: "Valider"),
            ],
          ),
        ),
      ),
    );
  }
}
