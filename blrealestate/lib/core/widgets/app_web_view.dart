import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../constants/app_colors.dart';

class AppWebView extends StatefulWidget {
  final String title;
  final String url;

  const AppWebView({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<AppWebView> createState() => _AppWebViewState();
}

class _AppWebViewState extends State<AppWebView> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  Timer? _safetyTimer;

  @override
  void initState() {
    super.initState();
    // Delay controller creation to ensure platform is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (_) {
                if (mounted) setState(() { _isLoading = true; _hasError = false; });
              },
              onPageFinished: (_) {
                if (mounted) setState(() => _isLoading = false);
              },
              onWebResourceError: (WebResourceError error) {
                if (error.isForMainFrame == true) {
                  if (mounted) setState(() { _isLoading = false; _hasError = true; });
                }
              },
              onNavigationRequest: (_) => NavigationDecision.navigate,
            ),
          )
          ..loadRequest(Uri.parse(widget.url));

        if (mounted) setState(() => _controller = controller);
      } catch (e) {
        if (mounted) setState(() { _isLoading = false; _hasError = true; });
      }

      // Safety timeout
      _safetyTimer = Timer(const Duration(seconds: 15), () {
        if (mounted && _isLoading) setState(() => _isLoading = false);
      });
    });
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.surfaceLight),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.surfaceLight),
        actions: [
          if (_controller != null)
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: () {
                setState(() { _isLoading = true; _hasError = false; });
                _controller!.reload();
              },
            ),
        ],
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.surfaceLight.withValues(alpha: 0.24),
                  color: AppColors.surfaceLight,
                  minHeight: 2,
                ),
              )
            : null,
      ),
      body: _hasError
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textSecondary(context)),
                  const SizedBox(height: 12),
                  Text('Could not load page', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context))),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() { _isLoading = true; _hasError = false; });
                      _controller?.reload();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surfaceLight,
                    ),
                  ),
                ],
              ),
            )
          : _controller == null
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : WebViewWidget(controller: _controller!),
    );
  }
}
