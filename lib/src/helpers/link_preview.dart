import 'dart:async';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';

import 'link_analyzer.dart';

class AnyLinkPreview extends StatefulWidget {
  final String link;
  final Map<String, String>? headers;
  final String? proxyUrl;
  
  final Widget Function(
    BuildContext context,
    Metadata? info,
    ConnectionState state,
  ) builder;

  AnyLinkPreview({
    Key? key,
    required this.link,
    this.headers,
    this.proxyUrl,
    required this.builder,
  }) : super(key: key);

  @override
  AnyLinkPreviewState createState() => AnyLinkPreviewState();
}

class AnyLinkPreviewState extends State<AnyLinkPreview> {
  Future<BaseMetaInfo?> fetch(String link) async {
    return await _getMetadata(
      link,
      cache: const Duration(days: 1),
      headers: widget.headers,
    );
  }

  Future<Metadata?>? _getMetadata(
    String link, {
    Duration? cache = const Duration(days: 1),
    Map<String, String>? headers,
  }) async {
    try {
      var info = await LinkAnalyzer.getInfo(
        link,
        cache: cache,
        headers: headers ?? {},
      );
      if (info == null || info.hasData == false) {
        // if info is null or data is empty try to read url metadata from client side
        info = await LinkAnalyzer.getInfoClientSide(
          link,
          cache: cache,
          headers: headers ?? {},
        );
      }
      return info;
    } catch (error) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BaseMetaInfo?>(
      future: fetch(widget.link),
      builder: (context, snapshot) {
        return widget.builder(
          context,
          snapshot.hasData ? snapshot.data as Metadata? : null,
          snapshot.connectionState,
        );
      },
    );
  }
}
