import 'dart:io';
import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'package:html/dom.dart' as dom; // <-- Add this import
import 'package:flutter_html/flutter_html.dart';
import '../models/book_data.dart';
import '../theme/app_theme.dart';

class EpubReaderScreen extends StatefulWidget {
  final BookData book;

  const EpubReaderScreen({
    Key? key,
    required this.book,
  }) : super(key: key);

  @override
  State<EpubReaderScreen> createState() => _EpubReaderScreenState();
}

class _EpubReaderScreenState extends State<EpubReaderScreen> {
  late EpubController _epubController;
  bool _isLoading = true;
  String _errorMessage = '';
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _loadEpub();
    // Update last read time
    widget.book.lastRead = DateTime.now();
  }

  Future<void> _loadEpub() async {
    try {
      // Ensure the file path exists before trying to open
      final file = File(widget.book.filePath);
      if (!await file.exists()) {
        throw FileSystemException(
            "ePub file not found at path", widget.book.filePath);
      }
      _epubController = EpubController(
        document: EpubDocument.openFile(file),
      );
      // It's often better to await the document loading here if needed
      // await _epubController.document;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading ePub: ${e.toString()}';
        print('Error loading ePub: $e'); // Log the error for debugging
      });
    }
  }

  @override
  void dispose() {
    // Check if _epubController was initialized before disposing
    if (!_isLoading && _errorMessage.isEmpty) {
      // Use try-catch as dispose might throw if called inappropriately
      try {
        _epubController.dispose();
      } catch (e) {
        print("Error disposing EpubController: $e");
      }
    }
    super.dispose();
  }

  // --- Helper function for custom tag styling ---
  // Widget? _customTagBuilder(dom.Element element, List<Widget> children) {
  //   final String? tag = element.localName;
  //   TextStyle? style;

  //   switch (tag) {
  //     case 'h1':
  //       style = TextStyle(
  //         fontSize: _fontSize + 6,
  //         fontWeight: FontWeight.bold,
  //         color: AppTheme.primaryPurple,
  //       );
  //       break;
  //     case 'h2':
  //       style = TextStyle(
  //         fontSize: _fontSize + 4,
  //         fontWeight: FontWeight.bold,
  //         color: AppTheme.primaryPurple,
  //       );
  //       break;
  //     case 'h3':
  //     case 'h4':
  //     case 'h5':
  //     case 'h6':
  //       style = TextStyle(
  //         fontSize: _fontSize + 2,
  //         fontWeight: FontWeight.bold,
  //         color: AppTheme.primaryPurple,
  //       );
  //       break;
  //     // Add cases for other tags if needed (e.g., 'p', 'blockquote')
  //     // case 'p':
  //     //   style = TextStyle(fontSize: _fontSize, color: AppTheme.textBrown, height: 1.3);
  //     //   break;
  //     default:
  //     // Return null to use default rendering for unspecified tags
  //       return null;
  //   }

  // Use DefaultTextStyle to apply the style to the children or Text for simple text content
  // Using Text directly often works well for headers.
  //   return Padding(
  //      padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
  //      child: Text(
  //         element.text, // Get the text content of the header
  //         style: style,
  //      ),
  //   );

  //   /* Alternatively, if the element might have complex children:
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
  //     child: DefaultTextStyle.merge(
  //       style: style,
  //       child: Column( // Or Wrap, or Row depending on expected children
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: children,
  //       ),
  //     ),
  //   );
  //   */
  // }
  // // --- End helper function ---

  @override
  Widget build(BuildContext context) {
    final Map<String, Style> htmlStyles = {
      // Style for H1 tags
      "h1": Style(
        fontSize: FontSize(_fontSize + 6), // Use FontSize object
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryPurple,
        padding: HtmlPaddings.only(
            top: 12.0, bottom: 8.0), // Apply padding via Style
        // margin: Margins.symmetric(vertical: 8), // Alternative spacing
      ),
      // Style for H2 tags
      "h2": Style(
        fontSize: FontSize(_fontSize + 4),
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryPurple,
        padding: HtmlPaddings.only(top: 12.0, bottom: 8.0),
      ),
      // Style for H3, H4, H5, H6 tags (can combine or list separately)
      "h3": Style(
        fontSize: FontSize(_fontSize + 2),
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryPurple,
        padding: HtmlPaddings.only(top: 12.0, bottom: 8.0),
      ),
      "h4": Style(
        // Copy style for other headers or customize
        fontSize: FontSize(_fontSize + 2),
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryPurple,
        padding: HtmlPaddings.only(top: 12.0, bottom: 8.0),
      ),
      "h5": Style(
        fontSize: FontSize(_fontSize + 2),
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryPurple,
        padding: HtmlPaddings.only(top: 12.0, bottom: 8.0),
      ),
      "h6": Style(
        fontSize: FontSize(_fontSize + 2),
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryPurple,
        padding: HtmlPaddings.only(top: 12.0, bottom: 8.0),
      ),
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.book.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          // Conditionally show buttons only if epub loaded successfully
          if (!_isLoading && _errorMessage.isEmpty) ...[
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                _showTableOfContents(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                _showReaderSettings(context);
              },
            ),
          ]
        ],
      ),
      body: Container(
        color: AppTheme.backgroundWhite,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
                ),
              )
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage,
                            style: const TextStyle(color: AppTheme.textBrown),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Go Back'),
                          ),
                        ],
                      ),
                    ),
                  )
                : EpubView(
                    controller: _epubController,
                    onDocumentLoaded: (document) {
                      print("Document loaded successfully");
                    },
                    builders: EpubViewBuilders<DefaultBuilderOptions>(
                      options: DefaultBuilderOptions(
                        // Default style for tags *not* in the styles map
                        textStyle: TextStyle(
                          fontSize: _fontSize,
                          color: AppTheme.textBrown,
                          // Don't set height here if you set it in 'p' style
                          // height: 1.3,
                        ),
                        // Padding applied between paragraph blocks by default
                        paragraphPadding:
                            const EdgeInsets.symmetric(vertical: 8),
                        // *** Use the 'styles' map HERE ***// <-- This is the correct place
                      ),
                      // Other builders are ok
                      chapterDividerBuilder: (_) => const Divider(),
                      // *** REMOVE the incorrect paragraphBuilder ***
                      // paragraphBuilder: (context, paragraphNode, defaultWidget) { ... }, // <-- REMOVE THIS BLOCK
                    ),
                  ),
      ),
    );
  }

  void _showTableOfContents(BuildContext context) {
    // Avoid showing TOC if controller isn't ready or has no TOC
    if (_isLoading ||
        _errorMessage.isNotEmpty ||
        _epubController.tableOfContents().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Table of Contents not available.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            final toc = _epubController.tableOfContents(); // Get TOC once
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Table of Contents',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textBrown,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: AppTheme.primaryPurple),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.primaryPurple),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: toc.length,
                      itemBuilder: (context, index) {
                        final chapter = toc[index];
                        // Use null-aware operators and provide defaults
                        final title =
                            chapter.title?.trim() ?? 'Unknown Chapter';
                        final startIndex = chapter.startIndex;

                        return ListTile(
                          title: Text(
                            title.isEmpty
                                ? 'Unnamed Chapter $index'
                                : title, // Handle empty titles
                            style: const TextStyle(
                              color: AppTheme.textBrown,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          contentPadding: const EdgeInsets.only(
                            left:
                                16.0, // Fixed indentation as chapter.level is not available
                            right: 16.0,
                          ),
                          dense: true,
                          onTap: startIndex == null
                              ? null
                              : () {
                                  // Disable tap if no startIndex
                                  _epubController.scrollTo(
                                    index: startIndex,
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                  );
                                  Navigator.pop(
                                      context); // Close the bottom sheet
                                },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showReaderSettings(BuildContext context) {
    // Temporary variable to hold slider value changes
    double tempFontSize = _fontSize;

    showDialog(
      context: context,
      builder: (context) {
        // Use StatefulBuilder only for the content that needs updating (the slider)
        return AlertDialog(
          title: const Text(
            'Reader Settings',
            style: TextStyle(
              color: AppTheme.primaryPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: StatefulBuilder(// Wrap only the changing part
              builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Font Size',
                  style: TextStyle(
                    color: AppTheme.textBrown,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Slider(
                  value: tempFontSize, // Use temporary variable
                  min: 12.0,
                  max: 24.0,
                  divisions: 12,
                  activeColor: AppTheme.accentYellow,
                  inactiveColor: AppTheme.primaryPurple.withOpacity(0.2),
                  label: tempFontSize.round().toString(),
                  onChanged: (double value) {
                    setDialogState(() {
                      // Update only the dialog's state
                      tempFontSize = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Sample Text Preview',
                  style: TextStyle(
                    fontSize:
                        tempFontSize, // Use temporary variable for preview
                    color: AppTheme.textBrown,
                    height: 1.3, // Match reader style
                  ),
                ),
              ],
            );
          }),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Apply changes by updating the main state variable
                setState(() {
                  _fontSize = tempFontSize;
                });
                Navigator.pop(context); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentYellow,
                foregroundColor: AppTheme.textBrown,
              ),
              child: const Text('Apply'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
} // End of _EpubReaderScreenState
