import 'package:kaouka/components/post_viwewer.dart';
import 'package:kaouka/components/tile_bottom_bar.dart';
import 'package:kaouka/http/routes/post/delete_req.dart';

import 'package:kaouka/pages/request_info_page.dart';
import 'package:flutter/material.dart';
import '../models/person.dart';
import '../core/shared_data.dart';
import '../utils.dart';
import 'kavatar.dart';

// ignore: must_be_immutable
class ReqPersonList extends StatefulWidget {
  final List<ReqPerson> personList;
  final Function? refresh;
  Function onDeletion;
  ReqPersonList(
      {super.key,
      required this.personList,
      this.refresh,
      this.onDeletion = deleteReq});

  @override
  State<ReqPersonList> createState() => _ReqPersonListState();
}

class _ReqPersonListState extends State<ReqPersonList> {
  bool collapseList = true;
  late String id;
  SharedData shared = SharedData();

  @override
  void initState() {
    super.initState();
    id = shared.getId;
  }

  @override
  void dispose() {
    super.dispose();
  }

  String getDist(String dist) {
    if (dist.isEmpty) return "";
    if (double.parse(dist) < 1000) {
      return "< 1km";
    } else {
      return "< ${int.parse(dist[0]) + 1} km";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          flex: 0,
          child: collapseList
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.personList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final person = widget.personList[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RequestInfoPage(
                                request: person.request,
                                person: person.person,
                                isOwn: (person.person.id == decodeId1(id))
                                    ? true
                                    : false,
                                isRequest: true,
                                changed: () {},
                              ),
                            ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(children: [
                          ListTile(
                            title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    person.person.name,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 2.9,
                                    child: person.request.request.isNotEmpty
                                        ? Text(
                                            person.request.request,
                                            maxLines: 1,
                                          )
                                        : Container(),
                                  ),
                                ]),
                            subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getDist(person.dist),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    timestampUnixToDate(person.request.reqTime),
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ]),
                            leading: KAvatar(
                              imageAssetPath: person.person.img,
                              scale: person.person.scale == 0.0
                                  ? 1.0
                                  : person.person.scale,
                              offset: Offset(person.person.offsetX / 1.9,
                                  person.person.offsetY / 2.1),
                              radius: 28,
                              borderSize: 2,
                              connected: person.person.connected,
                            ),
                            //   trailing: (unReadMsg > 0)
                            //       ? Container(
                            //           decoration: const BoxDecoration(
                            //             color: Colors.blue,
                            //             shape: BoxShape.circle,
                            //           ),
                            //           padding: const EdgeInsets.all(8),
                            //           child: Text(
                            //             '$unReadMsg',
                            //             style: const TextStyle(color: Colors.white),
                            //           ),
                            //         )
                            //       : const Icon(
                            //           Icons.arrow_forward,
                            //         ),
                          ),
                          person.request.media.isNotEmpty
                              ? PostViewer(
                                  media: person.request.media,
                                  isFeed: true,
                                  isPost: true,
                                )
                              : Container(),
                          const SizedBox(height: 1.0),
                          TileBottomBar(
                            refresh: widget.refresh,
                            request: person.request,
                            person: person.person,
                            commentNb: person.request.commentNb,
                            signalNb: person.request.signalNb,
                            onDeletion: widget.onDeletion,
                            isOwn: (person.person.id == decodeId1(id))
                                ? true
                                : false,
                          ),
                          Container(color: Colors.grey, height: 1),
                        ]),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text(
                      "Il n'y a pas encore d'utilisateur autour de vous, balader vous pour en trouver."),
                ))
    ]);
  }
}
