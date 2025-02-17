// import '../pages/payment_page.dart';
import 'package:kaouka/components/post_viwewer.dart';
import 'package:kaouka/components/request_card.dart';
import 'package:flutter/material.dart';
import 'package:kaouka/components/selector_button.dart';
import '../components/kavatar.dart';
import '../database.dart';
import '../http_manager.dart';
import '../message.dart';
import '../person.dart';
import '../request.dart';
import '../shared_data.dart';
import '../utils.dart';

class RequestInfoPage extends StatefulWidget {
  final Request request;
  final Person person;
  final Function() changed;
  final bool isOwn;
  final bool isRequest;
  const RequestInfoPage({
    super.key,
    required this.request,
    required this.person,
    required this.changed,
    required this.isOwn,
    this.isRequest = false,
  });

  @override
  State<RequestInfoPage> createState() => _RequestInfoPageState();
}

class _RequestInfoPageState extends State<RequestInfoPage> {
  List<ReqPerson> comments = [];
  List<ReqPerson> posts = [];
  List<CustomMessage> messages = [];
  SharedData shared = SharedData();
  late String id;
  // List<Person> persons = [];
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> unreadMsgs = [];
  bool isPostSelected = false;
  final ScrollController _scrollController = ScrollController();
  bool hasTriggerUp = false;
  bool hasTriggerDown = false;

  Future<void> getCmts() async {
    final comments = await getComments(widget.request.reqId, "");
    setState(() {
      this.comments = comments;
    });
  }

  Future<void> getPosts() async {
    final posts = await getAllReqs(widget.person, '');
    setState(() {
      this.posts = posts;
    });
  }

  selectComments() async {
    setState(() {
      isPostSelected = false;
      hasTriggerUp = true;
    });
    await getCmts();
    setState(() {
      hasTriggerUp = false;
    });
  }

  selectPosts() async {
    setState(() {
      isPostSelected = true;
      hasTriggerUp = true;
    });
    await getPosts();
    setState(() {
      hasTriggerUp = false;
    });
  }

  @override
  void initState() {
    super.initState();
    id = shared.getId;
    setState(() {
      hasTriggerUp = true;
    });
    getCmts();
    setState(() {
      hasTriggerUp = false;
    });
    // getUnreadMsg();
    // scroll pagination listener
    _scrollController.addListener(() async {
      double scrollOffset = _scrollController.offset;
      if (scrollOffset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange &&
          hasTriggerDown == false) {
        _loadMoreData();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadMoreData() async {
    setState(() {
      hasTriggerDown = true;
    });
    if (isPostSelected) {
      List<ReqPerson> comments = await getComments(
          widget.request.reqId, this.comments.last.request.reqId);
      setState(() {
        this.comments.addAll(comments);
      });
    } else {
      final posts =
          await getAllReqs(widget.person, this.posts.last.request.reqId);
      setState(() {
        this.posts.addAll(posts);
      });
    }
    setState(() {
      hasTriggerDown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   getUnreadMsg();
    // });
    return Scaffold(
      appBar: AppBar(title: Text("Post")),
      body: Column(
        children: [
          Expanded(
            // padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 46.0),
                  RequestCard(
                      person: widget.person,
                      request: widget.request,
                      isOwn: widget.isOwn),
                  const SizedBox(height: 10.0),
                  widget.isRequest
                      ? SelectorButton(
                          texts: const ["commentaires", "posts"],
                          functions: [selectComments, selectPosts])
                      : Container(),
                  hasTriggerUp
                      ? const Center(
                          child: RefreshProgressIndicator(
                            backgroundColor: Colors.black,
                            color: Colors.white,
                          ),
                        )
                      : Container(),
                  const SizedBox(height: 10.0),
                  Expanded(
                    flex: 0,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          isPostSelected ? posts.length : comments.length,
                      itemBuilder: (BuildContext context, int index) {
                        final commentOrRequest =
                            isPostSelected ? posts[index] : comments[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RequestInfoPage(
                                    request: commentOrRequest.request,
                                    person: commentOrRequest.person,
                                    changed: () {},
                                    isOwn: (commentOrRequest.person.id ==
                                            decodeId1(id))
                                        ? true
                                        : false,
                                  ),
                                ));
                          },
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: ListTile(
                                  title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          commentOrRequest.person.name,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.8,
                                          child: Text(
                                            commentOrRequest.request.request,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ]),
                                  // subtitle: Text(person.dist),
                                  leading: KAvatar(
                                    imageAssetPath: commentOrRequest.person.img,
                                    scale: commentOrRequest.person.scale,
                                    offset: Offset(
                                        commentOrRequest.person.offsetX / 1.9,
                                        commentOrRequest.person.offsetY / 2.1),
                                    radius: 28,
                                    connected: false,
                                  ),
                                ),
                              ),
                              commentOrRequest.request.media.isNotEmpty
                                  ? PostViewer(
                                      media: commentOrRequest.request.media,
                                      isFeed: true,
                                      isPost: true,
                                    )
                                  : Container(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  comments.isEmpty && !isPostSelected
                      ? const Center(
                          child: Text(
                            "Pas de commentaire",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : Container(),
                  posts.isEmpty && isPostSelected
                      ? const Center(
                          child: Text(
                            "Pas de posts",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: PostBottomBar(
          //     reqId: widget.request.reqId,
          //     personId: widget.person.id,
          //     isOwn: widget.isOwn,
          //   ),
          // )
        ],
      ),
    );
  }
}
