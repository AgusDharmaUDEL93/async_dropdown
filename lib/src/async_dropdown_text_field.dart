import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dropdown_container_decoration.dart';

class AsyncDropdownTextField<T> extends StatefulWidget {
  const AsyncDropdownTextField({
    super.key,

    // --- Custom Widgets / Data ---

    // This params is use to define the dropdown container children widget
    required this.childWidget,
    // This params is use to define when its no data
    this.noDataContainer,
    // This params is use to define when its still loading
    this.loadingContainer,
    required this.getItems,

    // --- Selection & Text Binding ---
    this.controller,
    required this.onSelectData,
    required this.onSetTextFieldLabel,
    this.onSetTextFieldPrefix,
    this.onErrorFetch,

    // --- TextField params (passthrough, opsional) ---
    this.decoration = const InputDecoration(
      border: OutlineInputBorder(),
      filled: true,
    ),
    this.focusNode,
    this.undoController,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = true,
    this.showCursor,
    this.autofocus = false,
    this.statesController,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onAppPrivateCommand,
    this.inputFormatters,
    this.enabled,
    this.ignorePointers,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorOpacityAnimates,
    this.cursorColor,
    this.cursorErrorColor,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection,
    this.selectionControls,
    this.mouseCursor,
    this.buildCounter,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints = const <String>[],
    this.contentInsertionConfiguration,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.scribbleEnabled = true,
    this.stylusHandwritingEnabled =
        EditableText.defaultStylusHandwritingEnabled,
    this.enableIMEPersonalizedLearning = true,
    this.contextMenuBuilder = _defaultContextMenuBuilder,
    this.canRequestFocus = true,
    this.spellCheckConfiguration,
    this.magnifierConfiguration,

    // --- Dropdown Container ---
    this.dropdownContainerDecoration,
    this.dropdownContainerMinWidth,
    this.dropdownContainerMaxWidth,
    this.dropdownContainerMinHeight,
    this.dropdownContainerMaxHeight = 300.0, // default cap 300 px
  });

  // ==================== Custom ====================
  final Widget Function(T data) childWidget;
  final Widget? noDataContainer;
  final Widget? loadingContainer;

  final Future<List<T>> Function(String keyword) getItems;

  final TextEditingController? controller;
  final void Function(T selectedData) onSelectData;
  final String Function(T data) onSetTextFieldLabel;
  final Widget Function(T data)? onSetTextFieldPrefix;
  final void Function(Object e)? onErrorFetch;

  // ==================== TextField Props ====================
  final InputDecoration decoration;
  final FocusNode? focusNode;
  final UndoHistoryController? undoController;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;
  final bool readOnly;
  final bool? showCursor;
  final bool autofocus;
  final WidgetStatesController? statesController;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final void Function(String)? onChanged;
  final void Function()? onEditingComplete;
  final void Function(String)? onSubmitted;
  final void Function(String, Map<String, dynamic>)? onAppPrivateCommand;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final bool? ignorePointers;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final bool? cursorOpacityAnimates;
  final Color? cursorColor;
  final Color? cursorErrorColor;
  final ui.BoxHeightStyle selectionHeightStyle;
  final ui.BoxWidthStyle selectionWidthStyle;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final DragStartBehavior dragStartBehavior;
  final bool? enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final MouseCursor? mouseCursor;
  final Widget? Function(
    BuildContext, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  })?
  buildCounter;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  final Iterable<String>? autofillHints;
  final ContentInsertionConfiguration? contentInsertionConfiguration;
  final Clip clipBehavior;
  final String? restorationId;
  final bool scribbleEnabled;
  final bool stylusHandwritingEnabled;
  final bool enableIMEPersonalizedLearning;
  final Widget Function(BuildContext, EditableTextState)? contextMenuBuilder;
  final bool canRequestFocus;
  final SpellCheckConfiguration? spellCheckConfiguration;
  final TextMagnifierConfiguration? magnifierConfiguration;

  // ==================== Dropdown Container ====================
  final DropdownContainerDecoration? dropdownContainerDecoration;
  final double? dropdownContainerMinWidth;
  final double? dropdownContainerMaxWidth;
  final double? dropdownContainerMinHeight;
  final double? dropdownContainerMaxHeight;

  @override
  State<AsyncDropdownTextField<T>> createState() =>
      _AsyncDropdownTextFieldState<T>();
}

class _AsyncDropdownTextFieldState<T> extends State<AsyncDropdownTextField<T>>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final GlobalKey _textFieldKey = GlobalKey();

  late final TextEditingController _internalController;
  TextEditingController get _controller =>
      widget.controller ?? _internalController;

  bool _isLoading = false;
  List<T> _items = [];
  String? _selectedTempLabel;
  Widget? _selectedPrefixWidget;
  Widget? _selectedTempPrefixWidget;

  late AnimationController _animationController;
  late Animation<double> _contentAnimation;
  late Animation<double> _iconRotation;

  static const double bottomNavBarHeightEstimate = 80;

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _contentAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _iconRotation = Tween<double>(
      begin: 1,
      end: 0.5,
    ).animate(_contentAnimation);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    _removeOverlay();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await widget.getItems(_controller.text);
      if (!mounted) return;
      setState(() {
        _items = data;
        _overlayEntry?.markNeedsBuild();
      });
    } catch (e) {
      if (!mounted) return;
      if (widget.onErrorFetch != null) widget.onErrorFetch!(e);
      setState(() => _removeOverlay());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    _animationController.forward();

    final renderBox =
        _textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final textFieldSize = renderBox.size;
    final textFieldOffset = renderBox.localToGlobal(Offset.zero);
    final textFieldOnBottom = (textFieldOffset.dy) + (textFieldSize.height);

    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow =
        screenHeight - textFieldOnBottom - bottomNavBarHeightEstimate;

    bool isAbove = spaceBelow < 200;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final screenPadding = MediaQuery.of(context).padding;
        return Positioned(
          top: screenPadding.top,
          left: 0,
          right: 0,
          bottom: screenPadding.bottom,
          child: Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (_selectedTempLabel != null) {
                    setState(() {
                      _controller.text = _selectedTempLabel!;
                      _selectedPrefixWidget = _selectedTempPrefixWidget;
                    });
                  }
                  _removeOverlay();
                },
              ),
              CompositedTransformFollower(
                link: _layerLink,
                targetAnchor: isAbove
                    ? Alignment.topLeft
                    : Alignment.bottomLeft,
                followerAnchor: isAbove
                    ? Alignment.bottomLeft
                    : Alignment.topLeft,
                offset: const Offset(0, 0),
                showWhenUnlinked: false,
                child: Material(
                  elevation: widget.dropdownContainerDecoration?.elevation ?? 4,
                  color: widget.dropdownContainerDecoration?.color,
                  shadowColor: widget.dropdownContainerDecoration?.shadowColor,
                  borderRadius:
                      widget.dropdownContainerDecoration?.borderRadius,
                  shape: widget.dropdownContainerDecoration?.shape,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: widget.dropdownContainerMinHeight ?? 0,
                      maxHeight: widget.dropdownContainerMaxHeight ?? 200,
                      minWidth:
                          widget.dropdownContainerMinWidth ??
                          textFieldSize.width,
                      maxWidth:
                          widget.dropdownContainerMaxWidth ?? double.infinity,
                    ),
                    child: _isLoading
                        ? (widget.loadingContainer ??
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [CircularProgressIndicator()],
                                ),
                              ))
                        : _items.isEmpty
                        ? (widget.noDataContainer ??
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [Text("No Data")],
                                ),
                              ))
                        : SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: _items.map((e) {
                                return InkWell(
                                  onTap: () {
                                    widget.onSelectData(e);
                                    final label = widget.onSetTextFieldLabel(e);
                                    setState(() {
                                      _controller.text = label;
                                      _selectedTempLabel = label;
                                      if (widget.onSetTextFieldPrefix != null) {
                                        _selectedPrefixWidget =
                                            widget.onSetTextFieldPrefix!(e);
                                        _selectedTempPrefixWidget =
                                            widget.onSetTextFieldPrefix!(e);
                                      }
                                    });
                                    _removeOverlay();
                                  },
                                  child: SizedBox(
                                    width:
                                        widget.dropdownContainerMinWidth ??
                                        textFieldSize.width,
                                    child: widget.childWidget(e),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (_overlayEntry == null) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    _animationController.reverse();
    _items = [];
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        key: _textFieldKey,
        controller: _controller,
        focusNode: widget.focusNode,
        undoController: widget.undoController,
        decoration: widget.decoration.copyWith(
          prefix: _selectedPrefixWidget,
          suffixIcon: RotationTransition(
            turns: _iconRotation,
            child: Icon(Icons.arrow_drop_down, size: 32),
          ),
        ),
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        style: widget.style,
        strutStyle: widget.strutStyle,
        textAlign: widget.textAlign,
        textAlignVertical: widget.textAlignVertical,
        textDirection: widget.textDirection,
        readOnly: widget.readOnly,
        showCursor: widget.showCursor,
        autofocus: widget.autofocus,
        statesController: widget.statesController,
        obscuringCharacter: widget.obscuringCharacter,
        obscureText: widget.obscureText,
        autocorrect: widget.autocorrect,
        smartDashesType: widget.smartDashesType,
        smartQuotesType: widget.smartQuotesType,
        enableSuggestions: widget.enableSuggestions,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        expands: widget.expands,
        maxLength: widget.maxLength,
        maxLengthEnforcement: widget.maxLengthEnforcement,
        onChanged: widget.onChanged,
        onEditingComplete: widget.onEditingComplete,
        onSubmitted: widget.onSubmitted,
        onAppPrivateCommand: widget.onAppPrivateCommand,
        inputFormatters: widget.inputFormatters,
        enabled: widget.enabled,
        cursorWidth: widget.cursorWidth,
        cursorHeight: widget.cursorHeight,
        cursorRadius: widget.cursorRadius,
        cursorOpacityAnimates: widget.cursorOpacityAnimates,
        cursorColor: widget.cursorColor,
        cursorErrorColor: widget.cursorErrorColor,
        selectionHeightStyle: widget.selectionHeightStyle,
        selectionWidthStyle: widget.selectionWidthStyle,
        keyboardAppearance: widget.keyboardAppearance,
        scrollPadding: widget.scrollPadding,
        dragStartBehavior: widget.dragStartBehavior,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        selectionControls: widget.selectionControls,
        onTap: () {
          if (_overlayEntry == null) {
            _showOverlay();
            setState(() {
              _controller.text = "";
              _selectedPrefixWidget = null;
            });
            _fetchData();
          } else {
            _removeOverlay();
          }
        },

        mouseCursor: widget.mouseCursor,
        buildCounter: widget.buildCounter,
        scrollController: widget.scrollController,
        scrollPhysics: widget.scrollPhysics,
        autofillHints: widget.autofillHints,
        contentInsertionConfiguration: widget.contentInsertionConfiguration,
        clipBehavior: widget.clipBehavior,
        restorationId: widget.restorationId,
        stylusHandwritingEnabled: widget.stylusHandwritingEnabled,
        enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
        contextMenuBuilder: widget.contextMenuBuilder,
        canRequestFocus: widget.canRequestFocus,
        spellCheckConfiguration: widget.spellCheckConfiguration,
        magnifierConfiguration: widget.magnifierConfiguration,
      ),
    );
  }
}

// Default context menu (remains as default TextField)
Widget _defaultContextMenuBuilder(
  BuildContext context,
  EditableTextState editableTextState,
) {
  return AdaptiveTextSelectionToolbar.editableText(
    editableTextState: editableTextState,
  );
}
