import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'controllers/post_card_controller.dart';
import '../utilities/constants.dart' as c;
import '../models/post_handler.dart' show Post;
import 'package:provider/provider.dart';
import 'profile_picture_loading.dart';
import 'package:intl/intl.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final bool isPreview;

  const PostCard({super.key, required this.post, this.isPreview = false});

  String formatTime(String time) {
    DateTime parsedTime = DateTime.parse(time);
    DateTime localTime = parsedTime.toLocal();
    String formattedTime = DateFormat('hh:mm a').format(localTime);
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: PostCardController(post: post, context: context),
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: InkWell(
            onTap: () => isPreview
                ? null
                : Provider.of<PostCardController>(context, listen: false)
                    .postPressed(),
            onDoubleTap: () => isPreview
                ? null
                : Provider.of<PostCardController>(context, listen: false)
                    .likePressed(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Divider(
                    color: Color.fromARGB(255, 112, 112, 112),
                    height: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: c.postPaddingHoriz,
                    vertical: c.postPaddingVert,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display the profile picture as a CircleAvatar
                      IconButton(
                        onPressed: () => isPreview
                            ? null
                            : Provider.of<PostCardController>(context,
                                    listen: false)
                                .avatarPressed(),
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        icon: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.115,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: post.author.profilePicture,
                              placeholder: (context, url) =>
                                  const LoadingProfileImage(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "@${post.author.username}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                  ),
                                ),
                                Text(
                                  formatTime(post.time),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            if (post.title != null)
                              Text(
                                post.title!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                              ),
                            if (post.gifURL != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  post.gifURL!,
                                  fit: BoxFit.fill,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return
                                        // ClipRRect(
                                        //   borderRadius: BorderRadius.circular(10),
                                        //   child: Shimmer.fromColors(
                                        //     baseColor: const Color.fromARGB(
                                        //         100, 130, 131, 130),
                                        //     highlightColor: Colors.white,
                                        //     child: Container(
                                        //       width: 200,
                                        //       height: 150,
                                        //       color: Colors.amber,
                                        //     ),
                                        //   ),
                                        // );
                                        Container(
                                      alignment: Alignment.center,
                                      width: 200,
                                      height: 150,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            if (post.body != null)
                              Text(
                                post.body!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: c.postPaddingHoriz,
                    //vertical: c.postPaddingVert-8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () => isPreview
                            ? null
                            : Provider.of<PostCardController>(context,
                                    listen: false)
                                .commentPressed(),
                        icon: Row(
                          children: [
                            Icon(
                              Icons.comment,
                              color: Theme.of(context).colorScheme.onBackground,
                              size: c.postIconSize,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${Provider.of<PostCardController>(context, listen: true).comments}',
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => isPreview
                            ? null
                            : Provider.of<PostCardController>(context,
                                    listen: false)
                                .likePressed(),
                        icon: Row(
                          children: [
                            Icon(
                              (Provider.of<PostCardController>(context,
                                          listen: true)
                                      .liked)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Theme.of(context).colorScheme.onBackground,
                              size: c.postIconSize,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${Provider.of<PostCardController>(context, listen: true).likes}',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => isPreview ? null : {},
                        icon: Row(
                          children: [
                            IconButton(
                              onPressed: () => isPreview
                                  ? null
                                  : Provider.of<PostCardController>(context,
                                          listen: false)
                                      .sharePressed(),
                              icon: Icon(
                                Icons.share,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                size: c.postIconSize,
                              ),
                            ),

                            const SizedBox(width: 5),
                            // Text(
                            //   '0',
                            //   style: TextStyle(
                            //       color:
                            //           Theme.of(context).colorScheme.onBackground),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
