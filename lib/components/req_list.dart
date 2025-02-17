import 'package:kaouka/components/post_viwewer.dart';
import 'package:kaouka/components/tile_bottom_bar.dart';
import 'package:kaouka/pages/request_info_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifiers/person_notifier.dart';
import '../person.dart';
import 'kavatar.dart';

class ReqPersonList extends StatefulWidget {
  const ReqPersonList({super.key});

  @override
  State<ReqPersonList> createState() => _ReqPersonListState();
}

class _ReqPersonListState extends State<ReqPersonList> {
  List<ReqPerson> personList = [];
  bool collapseList = true;

  // final DatabaseHelper databaseHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> unreadMsgs = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    personList = Provider.of<PeopleNotifier>(context, listen: true).people;
    return Column(children: [
      Expanded(
        flex: 0,
        child: collapseList
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: personList.length,
                itemBuilder: (BuildContext context, int index) {
                  final person = personList[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RequestInfoPage(
                              request: person.request,
                              person: person.person,
                              isOwn: false,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  person.person.name,
                                  style: Theme.of(context).textTheme.bodySmall,
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
                          subtitle: Text(
                            person.dist,
                            // style: Theme.of(context).textTheme.bodySmall,
                          ),
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
                          request: person.request,
                          person: person.person,
                          commentNb: person.request.commentNb,
                          signalNb: person.request.signalNb,
                        ),
                        Container(color: Colors.grey, height: 1),
                      ]),
                    ),
                  );
                },
              )
            : Container(),
      )
    ]);
  }
}
