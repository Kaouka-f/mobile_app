import 'package:flutter/material.dart';
// import 'package:kaouka/components/post_viwewer.dart';

import 'package:kaouka/core/shared_data.dart';
import 'package:kaouka/http/routes/get/get_feed.dart';

class ExtraPage extends StatefulWidget {
  const ExtraPage({super.key});

  @override
  State<ExtraPage> createState() => _ExtraPageState();
}

class _ExtraPageState extends State<ExtraPage> {
  final ScrollController _scrollController = ScrollController();
  bool hasTriggerUp = false;
  bool hasTriggerDown = false;
  List<String> medias = [];
  SharedData sharedData = SharedData();
  late String id;

  getMedias() async {
    dynamic res = await getFeed(id);
    await Future.delayed(const Duration(seconds: 2));
    for (var i = 0; i < res['feed'].length; i++) {
      setState(() {
        medias.add(res['feed'][i]);
      });
    }
  }

  downListener() async {
    double scrollOffset = _scrollController.offset;
    if (scrollOffset > _scrollController.position.maxScrollExtent + 150 &&
        hasTriggerDown == false) {
      setState(() {
        hasTriggerDown = true;
      });
      await getMedias();
      setState(() {
        hasTriggerDown = false;
      });
    }
  }

  upListener() async {
    double scrollOffset = _scrollController.offset;
    if (scrollOffset < _scrollController.position.minScrollExtent - 150 &&
        hasTriggerUp == false) {
      setState(() {
        hasTriggerUp = true;
      });
      setState(() {
        medias.clear();
      });
      await getMedias();
      setState(() {
        hasTriggerUp = false;
      });
    }
  }

  initMedia() async {
    setState(() {
      hasTriggerUp = true;
    });
    // await getMedias();
    setState(() {
      hasTriggerUp = false;
    });
  }

  @override
  void initState() {
    super.initState();
    id = sharedData.getId;
    _scrollController.addListener(downListener);
    _scrollController.addListener(upListener);
    initMedia();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Bientot disponible'));
    // return SingleChildScrollView(
    //   controller: _scrollController,
    //   physics: const AlwaysScrollableScrollPhysics(),

    // child: const Column(
    // mainAxisAlignment: MainAxisAlignment.center,
    // children: [
    //   SizedBox(
    //     height: 20,
    //   ),
    // hasTriggerUp
    //     ? const RefreshProgressIndicator(
    //         backgroundColor: Colors.black,
    //         color: Colors.white,
    //       )
    //     : Container(),
    // ListView.builder(
    //   shrinkWrap: true,
    //   physics: const NeverScrollableScrollPhysics(),
    //   itemCount: medias.length,
    //   itemBuilder: (BuildContext context, int index) {
    //     return Container(
    //       margin: const EdgeInsets.all(10),
    //       child: PostViewer(
    //         media: medias[index],
    //         isFeed: true,
    //       ),
    //     );
    //   },
    // ),
    // hasTriggerDown
    //     ? const RefreshProgressIndicator(
    //         backgroundColor: Colors.black,
    //         color: Colors.white,
    //       )
    //     : Container(),
    // ],
    // ),
    // );
  }
}
