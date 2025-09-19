import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import '../controller/event_comment_controller.dart';
import '../controller/user_controller.dart';
import '../controller/auth_controller.dart';
import '../model/event_model.dart';
import '../model/event_comment_model.dart';
import '../utils/time_helper.dart';

class EventCommentsPage extends StatefulWidget {
  final Event event;

  const EventCommentsPage({super.key, required this.event});

  @override
  State<EventCommentsPage> createState() => _EventCommentsPageState();
}

class _EventCommentsPageState extends State<EventCommentsPage> with TickerProviderStateMixin {
  late EventCommentController _commentController;
  late UserController _userController;
  late TabController _tabController;
  final TextEditingController _commentTextController = TextEditingController();
  final TextEditingController _announcementTextController = TextEditingController();
  final ScrollController _commentsScrollController = ScrollController();
  final ScrollController _announcementsScrollController = ScrollController();
  Worker? _commentsWorker;
  Worker? _announcementsWorker;
  Timer? _poller;

  @override
  void initState() {
    super.initState();
    _commentController = Get.put(EventCommentController());
    _userController = Get.find<UserController>();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        _scrollToBottomDeferred();
      } else if (_tabController.index == 1) {
        _scrollAnnouncementsBottomDeferred();
      }
    });
    
    // Load comments when page opens
    _commentController.loadEventComments(widget.event.id);

    // Start background polling for real-time updates
    _poller = Timer.periodic(const Duration(seconds: 7), (_) {
      _commentController.loadEventComments(widget.event.id, silent: true);
    });

    // Auto-scroll to bottom whenever the comments list changes
    _commentsWorker = ever(_commentController.comments, (_) {
      _scrollToBottomDeferred();
    });

    // Auto-scroll to bottom for announcements as well
    _announcementsWorker = ever(_commentController.comments, (_) {
      _scrollAnnouncementsBottomDeferred();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentTextController.dispose();
    _announcementTextController.dispose();
    _commentsWorker?.dispose();
    _announcementsWorker?.dispose();
    _commentsScrollController.dispose();
    _announcementsScrollController.dispose();
    _poller?.cancel();
    super.dispose();
  }

  bool get isEventCreator {
    return _userController.currentUser.value?.userId == widget.event.createdBy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1E33),
        title: Text(
          '${widget.event.title} - Discussion',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFEB1555),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Comments'),
            Tab(text: 'Announcements'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCommentsTab(),
          _buildAnnouncementsTab(),
        ],
      ),
    );
  }

  Widget _buildCommentsTab() {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (_commentController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final comments = _commentController.getCommentsByType('comment');
            
            if (comments.isEmpty) {
              return const Center(
                child: Text(
                  'No comments yet. Be the first to comment!',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              controller: _commentsScrollController,
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return _buildCommentCard(comments[index]);
              },
            );
          }),
        ),
        _buildCommentInput(),
      ],
    );
  }

  Widget _buildAnnouncementsTab() {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (_commentController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final announcements = _commentController.getCommentsByType('announcement');
            
            if (announcements.isEmpty) {
              return Center(
                child: Text(
                  isEventCreator 
                      ? 'No announcements yet. Post the first announcement!'
                      : 'No announcements from the event organizer yet.',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              controller: _announcementsScrollController,
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                return _buildAnnouncementCard(announcements[index]);
              },
            );
          }),
        ),
        if (isEventCreator) _buildAnnouncementInput(),
      ],
    );
  }

  Widget _buildCommentCard(EventComment comment) {
    final isOwner = _userController.currentUser.value?.userId == comment.userId;
    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser.value?.userId;
    final isCurrentUser = currentUserId == comment.userId;
    
    return Container(
      margin: EdgeInsets.only(
        bottom: 12,
        left: isCurrentUser ? 40 : 0,
        right: isCurrentUser ? 0 : 40,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser ? const Color(0xFF2A2D47) : const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser 
            ? const Color(0xFFEB1555).withValues(alpha: 0.3)
            : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isCurrentUser 
                  ? const Color(0xFFEB1555) 
                  : const Color(0xFF4A4A4A),
                child: Text(
                  comment.user.name.isNotEmpty ? comment.user.name[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (isCurrentUser)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEB1555),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'You',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      _formatDateTime(comment.createdAt),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOwner || isEventCreator)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) {
                    if (value == 'edit' && isOwner) {
                      _showEditCommentDialog(comment);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(comment);
                    }
                  },
                  itemBuilder: (context) => [
                    if (isOwner)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment.content,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          if (comment.updatedAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Edited',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(EventComment announcement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEB1555).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign, color: Color(0xFFEB1555), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Announcement',
                style: TextStyle(
                  color: Color(0xFFEB1555),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                _formatDateTime(announcement.createdAt),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              if (isEventCreator)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditAnnouncementDialog(announcement);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(announcement);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            announcement.content,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          if (announcement.updatedAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Edited',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentTextController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFFEB1555)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _postComment,
            icon: const Icon(Icons.send, color: Color(0xFFEB1555)),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _announcementTextController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Post an announcement...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFFEB1555)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _postAnnouncement,
            icon: const Icon(Icons.campaign, color: Color(0xFFEB1555)),
          ),
        ],
      ),
    );
  }

  void _postComment() async {
    if (_commentTextController.text.trim().isEmpty) return;

    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser.value?.userId ?? _userController.currentUser.value?.userId;
    if (currentUserId == null || currentUserId.isEmpty) {
      // Still proceed; backend will try to infer or use default, but log for debugging
      // ignore: avoid_print
      print('[CommentsPage] Warning: currentUserId is null/empty when posting comment');
    }

    final request = EventCommentCreateRequest(
      eventId: widget.event.id,
      content: _commentTextController.text.trim(),
      commentType: 'comment',
      userId: currentUserId,
    );

    // ignore: avoid_print
    print('[CommentsPage] Posting comment: eventId=${widget.event.id}, userId=$currentUserId');
    final success = await _commentController.createComment(request);
    if (success) {
      _commentTextController.clear();
      _scrollToBottomDeferred();
    }
  }

  void _postAnnouncement() async {
    if (_announcementTextController.text.trim().isEmpty) return;

    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser.value?.userId ?? _userController.currentUser.value?.userId;
    if (currentUserId == null || currentUserId.isEmpty) {
      // ignore: avoid_print
      print('[CommentsPage] Warning: currentUserId is null/empty when posting announcement');
    }

    final request = EventCommentCreateRequest(
      eventId: widget.event.id,
      content: _announcementTextController.text.trim(),
      commentType: 'announcement',
      userId: currentUserId,
    );

    // ignore: avoid_print
    print('[CommentsPage] Posting announcement: eventId=${widget.event.id}, userId=$currentUserId');
    final success = await _commentController.createComment(request);
    if (success) {
      _announcementTextController.clear();
      _scrollAnnouncementsBottomDeferred();
    }
  }

  void _showEditCommentDialog(EventComment comment) {
    final editController = TextEditingController(text: comment.content);
    
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        title: const Text('Edit Comment', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: editController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Edit your comment...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
          ),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
            if (editController.text.trim().isNotEmpty) {
              final request = EventCommentUpdateRequest(content: editController.text.trim());
              final success = await _commentController.updateComment(comment.id, request);
              if (!context.mounted) return;
              if (success) {
                Navigator.pop(context);
              }
            }
          },
            child: const Text('Save', style: TextStyle(color: Color(0xFFEB1555))),
          ),
        ],
      ),
    );
  }

  void _showEditAnnouncementDialog(EventComment announcement) {
    final editController = TextEditingController(text: announcement.content);
    
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        title: const Text('Edit Announcement', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: editController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Edit your announcement...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
          ),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
            if (editController.text.trim().isNotEmpty) {
              final request = EventCommentUpdateRequest(content: editController.text.trim());
              final success = await _commentController.updateComment(announcement.id, request);
              if (!context.mounted) return;
              if (success) {
                Navigator.pop(context);
              }
            }
          },
            child: const Text('Save', style: TextStyle(color: Color(0xFFEB1555))),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(EventComment comment) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        title: Text(
          'Delete ${comment.commentType == 'announcement' ? 'Announcement' : 'Comment'}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete this ${comment.commentType}?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
            final success = await _commentController.deleteComment(comment.id);
            if (!context.mounted) return;
            if (success) {
              Navigator.pop(context);
            }
          },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return TimeHelper.getTimeAgo(dateTime);
  }

  void _scrollToBottomDeferred() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_commentsScrollController.hasClients) return;
      final position = _commentsScrollController.position;
      _commentsScrollController.animateTo(
        position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _scrollAnnouncementsBottomDeferred() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_announcementsScrollController.hasClients) return;
      final position = _announcementsScrollController.position;
      _announcementsScrollController.animateTo(
        position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }
}
