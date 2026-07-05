import 'package:flutter/foundation.dart';
import 'package:kaouka/components/custom_elevated_button.dart';
import 'package:kaouka/components/kavatar.dart';
import 'package:kaouka/components/req_person_list.dart';
import 'package:kaouka/components/selector_button.dart';
import 'package:kaouka/core/database.dart';

import 'package:kaouka/core/logging.dart';
import 'package:kaouka/http/routes/get/get_interressed.dart';
import 'package:kaouka/http/routes/get/get_own_reqs.dart';
import 'package:kaouka/http/routes/post/delete_interressed.dart';
import 'package:kaouka/http/routes/post/delete_req.dart';
import 'package:kaouka/pages/setting_page.dart';
import 'package:kaouka/models/person.dart';
import '../notifiers/visible_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/shared_data.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _requestController = TextEditingController();
  String hintText = 'pseudonyme';
  String imageUrl = "https://elaborium.site/proxy/stream/default/profile.jpg";
  double imageScale = 1.0;
  double imageSize = 200;
  Offset imageOffset = const Offset(0.0, 0.0);
  late bool isToogled;
  bool deleteCache = false;
  SharedData shared = SharedData();
  late String id;
  bool isSelectedOwn = true;
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;
  String deleteCacheTitle = "Supprimer tous les messages";
  String deleteCacheMessage =
      "En supprimant le cache, tous les messages et contact de l'application seront supprimé. Etes-vous sur de vouloir supprimer le cache ?";
  List<ReqPerson> requests = [];
  List<ReqPerson> requestsOfInteressed = [];
  Map<String, int> unreadComment = {};
  bool hasTriggerUp = false;
  bool hasTriggerDown = false;

  @override
  void initState() {
    super.initState();
    initSharedPref();
    setState(() {
      hasTriggerUp = true;
    });
    getOwnRequests();
    setState(() {
      hasTriggerUp = false;
    });
  }

  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
  }

  initSharedPref() async {
    id = shared.getId;
    String? url = shared.getImageUrl;
    double? scale = shared.getImageScale;
    double? offsetX = shared.getImageOffset.dx;
    double? offsetY = shared.getImageOffset.dy;
    bool? visible = shared.getVisible;
    String? name = shared.getName;
    setState(() {
      imageUrl = url;
      imageScale = scale > 0.0 ? scale : 1.0;
      imageOffset = Offset(offsetX, offsetY);
      isToogled = visible;
      hintText = name;
    });
  }

  _imageChanged() {
    initSharedPref();
  }

  Future<void> _loadMoreData() async {
    setState(() {
      hasTriggerDown = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (isSelectedOwn) {
      getOwnRequests();
    } else {
      getRequestOfInteressed();
    }
    setState(() {
      hasTriggerDown = false;
    });
  }

  getOwnRequests() async {
    try {
      List<ReqPerson> requests = await getOwnReqs(id, '');
      setState(() {
        this.requests = requests;
      });
    } catch (e) {
      LoggerManager.logInfo("failed to get own request : $e");
      if (kDebugMode) {
        print("failed to get own request : $e");
      }
    }
  }

  getRequestOfInteressed() async {
    try {
      List<ReqPerson> requests = await getInterressed(id, '');
      requestsOfInteressed = requests;
    } catch (e) {
      LoggerManager.logInfo("failed to get own request : $e");
      if (kDebugMode) {
        print("failed to get own request : $e");
      }
    }
  }

  selectOwn() async {
    await getOwnRequests();
    setState(() {
      isSelectedOwn = true;
    });
  }

  selectInteressed() async {
    await getRequestOfInteressed();
    setState(() {
      isSelectedOwn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isVisible =
        Provider.of<PersistentVisibleProvider>(context).isVisibleChanged;

    return Scaffold(
        body: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(
                  children: [
                    Center(
                      child: KAvatar(
                        imageAssetPath: imageUrl,
                        scale: imageScale,
                        offset: imageOffset,
                        radius: 53,
                        borderSize: 4,
                        connected: isVisible,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Center(
                        child: Text(
                            style: const TextStyle(fontSize: 20), hintText)),
                  ],
                ),
                GestureDetector(
                  onTap: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingPage(
                          changed: _imageChanged,
                        ),
                      ),
                    )
                  },
                  child: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ]),
              const SizedBox(height: 30.0),
              SelectorButton(
                  texts: const ["mes posts", "mes interets"],
                  functions: [selectOwn, selectInteressed]),
              const SizedBox(height: 10.0),
              hasTriggerUp
                  ? const Center(
                      child: RefreshProgressIndicator(
                        backgroundColor: Colors.black,
                        color: Colors.white,
                      ),
                    )
                  : Container(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      ReqPersonList(
                          refresh: isSelectedOwn
                              ? getOwnRequests
                              : getRequestOfInteressed,
                          onDeletion:
                              isSelectedOwn ? deleteReq : deleteInterressed,
                          personList:
                              isSelectedOwn ? requests : requestsOfInteressed),
                      hasTriggerDown
                          ? const RefreshProgressIndicator(
                              backgroundColor: Colors.black,
                              color: Colors.white,
                              // minHeight: 50,
                            )
                          : Container(),
                      requests.isEmpty && isSelectedOwn
                          ? const Center(
                              child: Text(
                                "Aucun post créé",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : Container(),
                      requestsOfInteressed.isEmpty && !isSelectedOwn
                          ? const Center(
                              child: Text(
                                "Aucun interets",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : Container(),
                      const SizedBox(height: 20.0),
                      CustomElevatedButton(
                          onPressed: () {
                            _loadMoreData();
                          },
                          text: "plus de post")
                    ],
                  ),
                ),
              ),
              // ),
            ],
          ),
        ),
      ],
      // ),
    ));
  }
}
