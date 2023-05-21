import 'dart:async';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'chatmessage.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  late OpenAI openAI;
  StreamSubscription? _subscription;
  bool _isTyping = false;

//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
// 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
  @override
  void initState() {
    super.initState();
    openAI = OpenAI.instance.build(
      token: "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",
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 10)),
      enableLog: true,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _sendMessage() async {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    ChatMessage message = ChatMessage(text: text, sender: "user");
    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });

    _controller.clear();

    final request = CompleteText(
      prompt: message.text,
      maxTokens: 200,
      model: Model.textDavinci3,
    );

    try {
      final response = await openAI.onCompletion(request: request);

      if (response!.choices != null && response.choices.isNotEmpty) {
        String reply = response.choices.first.text.trim();
        ChatMessage botMessage = ChatMessage(text: reply, sender: "bot");

        setState(() {
          _isTyping = false;
          _messages.insert(0, botMessage);
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (value) => _sendMessage(),
            decoration:
                const InputDecoration.collapsed(hintText: "Send a message"),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: _sendMessage,
        )
      ],
    ).px16();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Chatbot AI"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(8.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _messages[index];
                },
              ),
            ),
            Divider(
              height: 1.0,
            ),
            Container(
              decoration: BoxDecoration(color: context.cardColor),
              child: _buildTextComposer(),
            ),
          ],
        ),
      ),
    );
  }
}
