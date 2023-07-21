// ignore_for_file: must_be_immutable, avoid_unnecessary_containers, library_private_types_in_public_api, non_constant_identifier_names

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../pub_DMCLcheckgia.dart';
enum AppNotifiType { dismissPopup, registerDevice, onChangeUX, asyncGetStock }

enum UXAdvanceMode { normal, advance }
class AppNotifi extends Notification {
  UXAdvanceMode? mode;
  AppNotifiType? value;

  AppNotifi({
    this.value,
    this.mode = UXAdvanceMode.normal,
  });
}
class DMCLCheckVersion extends StatefulWidget {
  int maxStep;
  Duration nextStepDuration;
  double progress;
  String? description;
  Color backgroundColor;
  Color foregroundColor;
  Widget? child;
  void Function()? onUpdateInfo;

  DMCLCheckVersion(
      {super.key,
      this.child,
      this.description = 'Updating ...',
      this.maxStep = 5,
      required this.progress,
      this.nextStepDuration = const Duration(milliseconds: 1200),
      this.backgroundColor = const Color.fromARGB(255, 188, 187, 187),
      this.foregroundColor = const Color.fromARGB(255, 188, 187, 187),
      this.onUpdateInfo});

  @override
  State<DMCLCheckVersion> createState() => _DMCLCheckVersionState();
}

class _DMCLCheckVersionState extends State<DMCLCheckVersion> {
  @override
  void initState() {
    super.initState();

    if (widget.onUpdateInfo != null) widget.onUpdateInfo!();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        DMCLProgressbar(
          progress: widget.progress,
          backgroundColor: widget.backgroundColor,
          foregroundColor: widget.foregroundColor,
        ),
        Container(
          child: widget.child,
        )
      ]),
    );
  }
}

class DMCLTextFieldPassword extends StatefulWidget {
  DMCLTextFieldPassword(this.field, {super.key});

  TextEditingController field;

  @override
  State<DMCLTextFieldPassword> createState() => _DMCLTextFieldPasswordState();
}

class _DMCLTextFieldPasswordState extends State<DMCLTextFieldPassword> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _isVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.field,
      obscureText: !_isVisible,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
          suffixIcon: IconButton(
              icon: Icon(
                _isVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isVisible = !_isVisible;
                });
              }),
          border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          filled: true,
          fillColor: HexColor.fromHex("#f6f6f7")),
    );
  }
}

class DMCLTextField extends StatelessWidget {
  TextEditingController? controller;
  String hintText;
  double bottomSpacing;
  double? height;
  DMCLTextField(
      {super.key,
      required this.hintText,
      this.controller,
      this.height = 56,
      this.bottomSpacing = 0.0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: GlobalStyles.borderColor, width: 1),
        ),
        child: Center(
          child: TextField(
            autocorrect: false,
            enableSuggestions: false,
            controller: controller,
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration(
              fillColor: Colors.red,
              hintText: hintText,
              hintStyle: TextStyle(color: GlobalStyles.textHintColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(left: 8, right: 8),
            ),
          ),
        ),
      ),
    );
  }
}

class DMCLFieldFrom extends StatelessWidget {
  TextEditingController controller;
  String? labelTitle;
  String? hintText;
  Color backgroundColor;
  double bottomSpacing;
  double width;
  double height;
  bool enableSecure;

  DMCLFieldFrom(
      {super.key,
      required this.controller,
      this.width = double.infinity,
      this.labelTitle,
      this.hintText,
      this.bottomSpacing = 0,
      this.height = 56,
      this.enableSecure = false,
      this.backgroundColor = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (labelTitle != null)
            Text(
              labelTitle!,
              style: TextStyle(
                  fontFamily: "Nunito Sans",
                  fontSize: 14,
                  color: '#8F92A1'.toColor()),
            ),
          const SizedBox(
            height: 2,
          ),
          SizedBox(
            width: width,
            // height: height,
            child: !enableSecure
                ? TextField(
                    enableSuggestions: false,
                    autocorrect: false,
                    controller: controller,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 12),
                        hintText: hintText ?? '',
                        border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0))),
                        filled: true,
                        fillColor: "#f6f6f7".toColor()),
                  )
                : DMCLTextFieldPassword(controller),
          )
        ],
      ),
    );
  }
}

class DMCLVerifySMS extends StatefulWidget {
  Future<String> Function()? onRequestCode;
  void Function(bool)? onAuthen;

  DMCLVerifySMS({super.key, this.onRequestCode, this.onAuthen});

  @override
  State<DMCLVerifySMS> createState() => _DMCLVerifySMSState();
}

class _DMCLVerifySMSState extends State<DMCLVerifySMS> {
  TextEditingController fieldCodeWeb = TextEditingController();
  var code = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12, top: 8),
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
                onPressed: () async {
                  Fluttertoast.showToast(msg: 'Gửi yêu cầu');
                  code = await widget.onRequestCode!();
                  await Future.delayed(const Duration(milliseconds: 600));

                  fieldCodeWeb.text = code;

                  setState(() {});
                },
                child: const Text(
                  'Gửi yêu cầu xem giá',
                  style: TextStyle(fontSize: 16),
                )),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 4,
                child: DMCLTextField(
                  hintText: 'Nhập mã code',
                  controller: fieldCodeWeb,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: Icon(
                  Icons.keyboard_double_arrow_right,
                  size: 26,
                  color: GlobalStyles.backgroundDisableColor,
                ),
              ),
              Flexible(
                flex: 2,
                child: DMCLButton(
                  'Xác thực',
                  onTap: () => clientVerify(),
                  backgroundColor: GlobalStyles.backgroundActiveColor,
                  fontSize: 16,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void clientVerify() async {
    var isAcceptCode = fieldCodeWeb.text == code;
    if (widget.onAuthen != null) {
      widget.onAuthen!(isAcceptCode);
    }

    Fluttertoast.showToast(
        msg: isAcceptCode ? 'Xác thực thành công' : 'Sai mã code xác thực');

    if (isAcceptCode) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }
}

class DMCLButton extends StatelessWidget {
  String title;
  Color? backgroundColor;
  Color? fontColor;
  FontWeight fontWeight;
  double fontSize;
  double height;
  void Function()? onTap;

  DMCLButton(this.title,
      {super.key,
      this.onTap,
      this.backgroundColor = Colors.transparent,
      this.fontColor = Colors.blue,
      this.fontSize = 18,
      this.height = 46,
      this.fontWeight = FontWeight.w500});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
            color: backgroundColor == Colors.transparent
                ? GlobalStyles.backgroundColorButton
                : backgroundColor,
            border: Border.all(
                width: 1,
                color: backgroundColor == Colors.transparent
                    ? GlobalStyles.backgroundColorButton
                    : backgroundColor!),
            borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: backgroundColor == Colors.transparent
                      ? fontColor
                      : GlobalStyles.getFontColorForBackground(
                          backgroundColor!),
                  fontSize: fontSize,
                  fontWeight: fontWeight),
            ),
          ),
        ),
      ),
    );
  }
}

class DMCLShadow extends StatelessWidget {
  Widget child;
  Offset direction;
  double radius;
  bool enable;
  DMCLShadow(
      {super.key,
      required this.child,
      this.direction = Offset.zero,
      this.radius = 0,
      this.enable = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          if (enable)
            BoxShadow(
              color: const Color.fromARGB(27, 0, 0, 0),
              blurRadius: 12,
              offset: direction, // Shadow position
            ),
        ],
      ),
      child: child,
    );
  }
}

class AvatarLoad extends StatelessWidget {
  // local path or url link
  String pathImage;
  double size;
  bool editAvatar;
  Function(String pathImage)? onPickerImage;

  AvatarLoad(this.pathImage,
      {super.key, this.size = 25, this.editAvatar = false, this.onPickerImage});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        radius: pathImage.isNotEmpty ? size * 1.5 : size,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            pathImage.isNotEmpty && pathImage.contains('https')
                ? CachedNetworkImage(
                    imageUrl: pathImage,
                    placeholder: (ctx, url) => const CircularProgressIndicator(
                          color: Colors.amber,
                          strokeWidth: 2,
                          backgroundColor: Colors.transparent,
                        ),
                    // errorWidget: (ctx, url, error) => SvgPicture.asset(
                    //   "assets/img/user.svg",
                    //   height: size + 5,
                    //   width: size + 5,
                    //   color: Colors.white,
                    // ),
                    errorWidget: (ctx, url, error) => const Icon(Icons.person))
                : pathImage.isNotEmpty && !pathImage.contains('https')
                    ? Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50)),
                        child: Image.file(
                          File(pathImage),
                          fit: BoxFit.contain,
                          // width: 100,
                          // height: 100,
                        ))
                    : Icon(
                        // const FaIcon(FontAwesomeIcons.user) as IconData?,
                        Icons.person,
                        size: size + 16,
                      ),
            if (editAvatar)
              Positioned(
                  bottom: -2,
                  right: -2,
                  child: GestureDetector(
                    onTap: () async {
                      var picker = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (picker != null && onPickerImage != null) {
                        onPickerImage!(picker.path);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 125, 125, 125),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                              width: 2,
                              color: GlobalStyles.backgroundActiveColor)),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.camera_alt,
                          size: pathImage.isNotEmpty ? 20 : 15,
                          color: const Color.fromARGB(255, 242, 242, 242),
                        ),
                      ),
                    ),
                  ))
          ],
        ));
  }
}

class LoadingFragment extends StatelessWidget {
  LoadingFragment({super.key, this.text = 'Đang tải dữ liệu', this.style});

  String? text;
  TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircleAvatar(
          backgroundColor: Colors.transparent,
          // backgroundColor: Color.fromARGB(128, 158, 158, 158),
          radius: 20,
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.amber,
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          text!,
          style: style ?? const TextStyle(color: Colors.grey),
        )
      ],
    ));
  }
}

Future<dynamic> showAlert(context, String title, String message,
    {List<CupertinoButton>? actions,
    List<ElevatedButton>? actionAndroids}) async {
  if (Platform.isIOS) {
    return showCupertinoDialog(
        context: context!,
        builder: (context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                if (actions != null)
                  ...actions
                else
                  CupertinoButton(
                      child: const Text('Đồng ý'),
                      onPressed: () {
                        Navigator.pop(context);
                      })
              ],
            ));
  }

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        if (actionAndroids != null)
          ...actionAndroids
        else
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Đồng ý'))
      ],
    ),
  );
}

class DMCLTitleCard extends StatelessWidget {
  String? title;
  Color borderColor;
  List<Widget> children;

  DMCLTitleCard(
      {super.key,
      this.title,
      required this.children,
      this.borderColor = Colors.blue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 8),
      decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(12)),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
            // color: Colors.yellow,
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                    color: '#f5f5f5'.toColor(),
                    backgroundBlendMode: BlendMode.multiply,
                    border: Border(
                        bottom:
                            BorderSide(color: '#dedede'.toColor(), width: 1))),
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                // direction: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DMCLCard extends StatefulWidget {
  Widget? child;
  Color? backgroundColor;
  Color? borderColor;
  double borderRadius;
  double? width;
  double borderWith;
  Duration duration;
  EdgeInsets? padding;

  /// Change color from borderColor to this
  List<Color>? animationBorderColor;

  DMCLCard({
    super.key,
    this.child,
    this.width,
    this.borderRadius = 8,
    this.backgroundColor,
    this.padding,
    this.borderColor,
    this.animationBorderColor,
    this.borderWith = 1,
    this.duration = Duration.zero,
  });

  @override
  State<DMCLCard> createState() => _DMCLCardState();
}

enum DMCLCardLabelType { normal, labelSmallValueLarge, digital }

class DMCLCardLabel extends StatelessWidget {
  String label;
  String value;
  Color? borderColor;
  DMCLCardLabelType type;
  // -1 set auto
  double width;

  DMCLCardLabel(
      {super.key,
      required this.label,
      required this.value,
      this.width = 90,
      this.borderColor = Colors.grey,
      this.type = DMCLCardLabelType.normal});

  @override
  Widget build(BuildContext context) {
    double fontNormal = 15;
    double fontLarge = 17;

    return DMCLCard(
      width: width == -1 ? null : width,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: type == DMCLCardLabelType.normal
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: type == DMCLCardLabelType.labelSmallValueLarge
                      ? fontNormal
                      : 15)),
          Text(
            value,
            style: TextStyle(
                color: Colors.black,
                fontWeight: type == DMCLCardLabelType.digital
                    ? FontWeight.w500
                    : FontWeight.normal,
                fontSize: type == DMCLCardLabelType.labelSmallValueLarge
                    ? fontLarge
                    : 15),
          )
        ],
      ),
    );
  }
}

class _DMCLCardState extends State<DMCLCard> {
  Color? fontColor;
  Timer? _timerAnimation;

  double borderWidth = 1;
  double borderWidthMax = 1.75;
  double borderWidthMin = 0.75;

  bool get enableAnimationBorder => widget.duration != Duration.zero;

  Color? animationColor;

  @override
  void initState() {
    super.initState();
    borderWidth = widget.borderWith;
    borderWidthMax = borderWidth > 0 ? borderWidth + 0.75 : 0;
    borderWidthMin = borderWidth > 0 ? borderWidth - 0.75 : 0;

    if (enableAnimationBorder) {
      animationColor = widget.animationBorderColor![0];

      _timerAnimation = Timer.periodic(widget.duration, (timer) {
        borderWidth =
            borderWidth == borderWidthMax ? borderWidthMin : borderWidthMax;
        animationColor = animationColor == widget.animationBorderColor![0]
            ? widget.animationBorderColor![1]
            : widget.animationBorderColor![0];
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timerAnimation?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AnimatedContainer(
        duration: widget.duration,
        width: widget.width,
        // height: double.maxFinite,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(
              width: enableAnimationBorder ? borderWidth : widget.borderWith,
              color: widget.animationBorderColor == null
                  ? (widget.borderColor == null
                      ? widget.backgroundColor != null
                          ? widget.backgroundColor!
                          : GlobalStyles.borderCardColor
                      : widget.borderColor!)
                  : animationColor!),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          color: widget.backgroundColor ?? GlobalStyles.backgroundCardColor,
        ),
        child: Padding(
          padding: widget.padding == null
              ? const EdgeInsets.all(8.0)
              : widget.padding!,
          child: widget.child,
        ),
      ),
    );
  }
}

class DMCLRow extends StatelessWidget {
  DMCLRow(
      {super.key,
      this.title,
      this.child,
      this.padding,
      this.spacing,
      this.height = 32,
      this.crossAxisAlignment = CrossAxisAlignment.center});

  EdgeInsets? padding;
  Widget? title;
  Widget? child;
  double? spacing;
  double? height;
  CrossAxisAlignment? crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 1),
      child: Padding(
        padding: padding == null ? const EdgeInsets.only(bottom: 0) : padding!,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: crossAxisAlignment!,
          children: [
            if (title != null) title!,
            if (spacing != null)
              SizedBox(
                width: spacing,
              ),
            if (child != null) child!
          ],
        ),
      ),
    );
  }
}

class DMCLRowText extends StatelessWidget {
  DMCLRowText(this.title, this.value,
      {super.key,
      this.styleTitle,
      this.styleValue,
      this.padding,
      this.spacing});
  String title, value;
  TextStyle? styleValue, styleTitle;
  EdgeInsets? padding;
  double? spacing;

  @override
  Widget build(BuildContext context) {
    return DMCLRow(
      spacing: spacing,
      padding: padding,
      title: Text(
        title,
        style: styleTitle ??
            TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: GlobalStyles.textColor54),
      ),
      child: Text(
        value,
        style: styleValue ??
            const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black),
      ),
    );
  }
}

class DMCLGroup extends StatelessWidget {
  String title;
  double? fontSize;
  FontWeight? fontWeight;
  Widget child;
  EdgeInsets? paddingTitle;
  EdgeInsets? paddingContent;

  DMCLGroup(
    this.title, {
    super.key,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w500,
    this.paddingTitle,
    this.paddingContent,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: paddingContent ?? const EdgeInsets.only(left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                paddingTitle ?? const EdgeInsets.only(top: 12.0, bottom: 12),
            child: Text(
              title,
              style: TextStyle(
                  fontWeight: fontWeight,
                  fontSize: fontSize,
                  color: Colors.black),
            ),
          ),
          child
        ],
      ),
    );
  }
}

class DMCLSearchBox extends StatefulWidget {
  TextEditingController? controller;
  bool isAutocomplete;
  bool enableClearButton;
  bool enableAnimationSubmit;

  int minKeywordSearch;
  Color? backgroundColor;
  String hint;
  int delayTypingSubmit;
  void Function(String)? onSubmit;
  void Function(String)? onChange;

  DMCLSearchBox(
      {super.key,
      this.hint = 'Tìm kiếm sản phẩm',
      this.onChange,
      this.onSubmit,
      this.isAutocomplete = true,
      this.minKeywordSearch = 4,
      this.delayTypingSubmit = 1200,
      this.controller,
      this.backgroundColor,
      this.enableClearButton = false,
      this.enableAnimationSubmit = false});

  @override
  State<DMCLSearchBox> createState() => _DMCLSearchBoxState();
}

class _DMCLSearchBoxState extends State<DMCLSearchBox> {
  double animationWithValue = 0;
  bool isAnimated = false;
  bool isDisplayButtonClear = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Flexible(
            child: Container(
              clipBehavior: Clip.hardEdge,
              height: 48,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? '#F7F7F7'.toColor(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 375),
                    curve: Curves.easeInCubic,
                    width: animationWithValue,
                    decoration: const BoxDecoration(
                      color: Colors.black12,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12),
                    // just removed center here
                    child: TextField(
                      autocorrect: false,
                      enableSuggestions: false,
                      onChanged: (value) => autocomplete(value, context),
                      onSubmitted: (value) {
                        onBeforeSubmit(value);
                        log('textfield.enter event');
                      },
                      textInputAction: TextInputAction.go,
                      controller: widget.controller,
                      decoration: InputDecoration(

                          // prefixIcon: Padding(
                          //   padding: const EdgeInsets.all(12.0),
                          //   child: SvgPicture.asset("assets/img/magnifier.svg"),
                          // ),]

                          suffixIconConstraints:
                              const BoxConstraints(maxWidth: 38),
                          suffixIcon: Visibility(
                            visible: isDisplayButtonClear,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: GlobalStyles.backgroundColor,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  widget.controller!.clear();
                                  isDisplayButtonClear = false;
                                  log('autoComple.text $isDisplayButtonClear');
                                  setState(() {});
                                },
                                icon: const Icon(
                                  Icons.clear,
                                  // size: 18,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          border: InputBorder.none,
                          hintText: widget.hint,
                          hintStyle: TextStyle(
                              fontSize: 16, color: GlobalStyles.textColor45)),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
                color: GlobalStyles.backgroundActiveColor,
                borderRadius: BorderRadius.circular(8)),
            child: IconButton(
              onPressed: () {
                if (widget.onSubmit != null) {
                  widget.onSubmit!(widget.controller!.text);
                }
                FocusScope.of(context).unfocus();
              },
              iconSize: 28,
              icon: const Icon(
                Icons.search,
              ),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Timer? timerAutocomplete;
  void autocomplete(String value, context) {
    if (widget.onChange != null && !widget.isAutocomplete) {
      widget.onChange!(value);
    }

    if (!widget.isAutocomplete) return;

    if (timerAutocomplete != null) {
      log('autoComple.cancel reset timer');
      timerAutocomplete!.cancel();
    }

    if ((value.isEmpty && isDisplayButtonClear ||
        value.isNotEmpty && !isDisplayButtonClear)) {
      isDisplayButtonClear = !isDisplayButtonClear;
      setState(() {});
      log('autoComple.display button clear ${isDisplayButtonClear ? 'hiển thị' : 'ẩn'}');
    }

    if (value.length < widget.minKeywordSearch) {
      return;
    }

    timerAutocomplete = Timer.periodic(
        Duration(milliseconds: widget.delayTypingSubmit), (timer) {
      log('autoComple.cancel submit text');
      onBeforeSubmit(value);

      // hidden keyboard
      FocusScope.of(context).unfocus();
      timer.cancel();
    });
  }

  void onBeforeSubmit(value) {
    needRunAnimation();
    if (widget.onSubmit != null) widget.onSubmit!(value);
  }

  void needRunAnimation() async {
    if (widget.enableAnimationSubmit) {
      animationWithValue = MediaQuery.of(context).size.width;
      isAnimated = !isAnimated;
      setState(() {});

      await Future.delayed(const Duration(milliseconds: 500));
      animationWithValue = 0;
      isAnimated = !isAnimated;
      setState(() {});
    }
  }
}

class ListPickerItem extends StatelessWidget {
  bool isSelected;
  Function()? onTap;
  String title;
  dynamic value;
  ListPickerItem(this.title,
      {super.key, this.value, this.onTap, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 16, bottom: 16, left: 8, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16),
                    ),
                    Icon(
                      Icons.check,
                      color: isSelected
                          ? GlobalStyles.activeColor
                          : Colors.transparent,
                    )
                  ],
                ),
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  toList() {}
}

class DMCLListView extends StatefulWidget {
  List<ListPickerItem> data = [];
  void Function(int index)? onItemPress;
  DMCLListView(this.data, {super.key, this.onItemPress});

  @override
  State<DMCLListView> createState() => _DMCLListViewState();
}

class _DMCLListViewState extends State<DMCLListView> {
  int currentIndex = -1;

  @override
  void initState() {
    super.initState();

    currentIndex = widget.data.indexWhere((item) => item.isSelected == true);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.data.length,
        itemBuilder: (ctx, index) => ListPickerItem(
              widget.data[index].title,
              isSelected: widget.data[index].isSelected,
              onTap: () {
                if (widget.onItemPress != null) widget.onItemPress!(index);
                if (currentIndex == -1) {
                  currentIndex = index;
                  widget.data[currentIndex].isSelected = true;
                  setState(() {});
                  return;
                }

                widget.data[currentIndex].isSelected = false;
                currentIndex = index;
                widget.data[currentIndex].isSelected = true;

                setState(() {});

                if (widget.data[index].onTap != null) {
                  widget.data[index].onTap!();
                }
              },
            ));
  }
}

class DMCLListPicker<T> extends StatefulWidget {
  BuildContext context;
  List<ListPickerItem> source;
  String? text;
  String title;
  ListPickerItem? _item;
  void Function(ListPickerItem item)? onChange;

  DMCLListPicker(
      {super.key,
      required this.context,
      required this.source,
      required this.title,
      this.text = '',
      this.onChange});

  @override
  State<DMCLListPicker<T>> createState() => _DMCLListPickerState<T>();
}

class _DMCLListPickerState<T> extends State<DMCLListPicker<T>> {
  dynamic value;

  @override
  Widget build(BuildContext context) {
    log('rebuild picker');

    return GestureDetector(
      onTap: () => onModalPop(),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: GlobalStyles.borderColor)),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 12.0, bottom: 12, left: 12, right: 12),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              widget.text!.isEmpty ? widget.title : widget.text!,
              style: TextStyle(fontSize: 18, color: GlobalStyles.textHintColor),
            ),
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.grey,
            )
          ]),
        ),
      ),
    );
  }

  void onModalPop() {
    showModalBottomSheet(
      context: widget.context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DMCLModal(
          title: widget.title,
          height: MediaQuery.of(context).size.height * 0.85,
          body: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DMCLSearchBox(),
            ),
            Expanded(
              child: DMCLListView(
                widget.source,
                onItemPress: ((index) => widget._item = widget.source[index]),
              ),
            ),
            DMCLShadow(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DMCLButton(
                  'Chọn',
                  backgroundColor: GlobalStyles.backgroundActiveColor,
                  fontColor: Colors.white,
                  onTap: () {
                    setState(() {
                      widget.text = widget._item!.title;
                    });
                    Navigator.pop(ctx);

                    if (widget.onChange != null) {
                      widget.onChange!(widget._item!);
                    }

                    log('picker : ${widget.text}');
                  },
                ),
              ),
            )
          ]),
    );
  }
}

class DMCLModal extends StatelessWidget {
  late String title;
  double height;
  Icon? leadingIcon;
  Widget? trailing;
  List<Widget>? body;

  DMCLModal(
      {super.key,
      required this.title,
      this.height = 600,
      this.leadingIcon,
      this.trailing,
      this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: IconButton(
                        iconSize: 32,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close)),
                  ),
                  Flexible(
                    flex: 3,
                    child: Text(
                      title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Flexible(
                      child: trailing ??
                          const SizedBox(
                            width: 64,
                          ))
                ],
              ),
            ),
            ...body!
          ],
        ));
  }
}

class DMCLPopUp extends StatelessWidget {
  const DMCLPopUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

Future<BuildContext?> showPopup(BuildContext context,
    {required String title, String? msg, List<ElevatedButton>? actions}) {
  return showDialog(
    context: context,
    builder: (context) => DMCLModal(
      title: title,
      body: [
        Container(child: Text(msg!)),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: actions ?? [],
          ),
        )
      ],
    ),
  );
}

BuildContext? _ctxLoading;
void dismissLoading() {
  if (_ctxLoading != null) {
    // Navigator.pop(_ctxLoading!);
    AppNotifi(value: AppNotifiType.dismissPopup).dispatch(_ctxLoading);
    // _ctxLoading = null;
  }
}

Future<BuildContext?> showLoading(BuildContext context,
    {String message = 'Đang tải'}) async {
  BuildContext? ctx;
  showDialog(
      useRootNavigator: false,
      context: context,
      builder: (ctx) {
        _ctxLoading = context;

        return NotificationListener<AppNotifi>(
          onNotification: (notification) {
            var match = notification.value == AppNotifiType.dismissPopup;
            if (match) {
              Navigator.pop(context);
            }
            return false;
          },
          child: WillPopScope(
            onWillPop: () => Future.value(false),
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration:
                    const BoxDecoration(color: Color.fromARGB(128, 0, 0, 0)),
                child: Center(
                    child: LoadingFragment(
                  text: message,
                  style: const TextStyle(color: Colors.white),
                )),
              ),
            ),
          ),
        );
      });

  // Future.delayed(const Duration(seconds: 5), () {
  //   if (ctx != null) Navigator.pop(ctx);
  //   log('pop.dismiss | reason: timeout loading');
  // });

  return ctx;
}

// Future<BuildContext?> showPopup(BuildContext context,
//     {PopupInfor? popupInfor = PopupInfor.notFound,
//     int? money,
//     String message = "",
//     String icon = ""}) {
//   if (popupInfor == PopupInfor.notFound) {
//     message = message.isEmpty
//         ? "Kháng hàng không có hóa đơn cần thanh toán"
//         : message;
//     icon = icon.isEmpty ? "assets/img/notFound.svg" : icon;
//   } else if (popupInfor == PopupInfor.wrongMoney) {
//     message = message.isEmpty
//         ? "Số tiền khách đưa không được nhỏ hơn ${money!.toCurrency()}"
//         : message;
//     icon = icon.isEmpty ? "assets/img/wrongMoney.svg" : icon;
//   } else if (popupInfor == PopupInfor.needLessMoney) {
//     message = message.isEmpty
//         ? "Số tiền khách đưa không được vượt quá ${money!.toCurrency()}"
//         : message;
//     icon = icon.isEmpty ? "assets/img/wrongMoney.svg" : icon;
//   }

//   return showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (ctx) => Container(
//       color: const Color.fromARGB(95, 0, 0, 0),
//       child: Center(
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             color: Colors.white,
//           ),
//           width: MediaQuery.of(context).size.width * 0.75,
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(width: 100, height: 100, child: Image.asset(icon)),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 Text(
//                   message,
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(
//                   height: 16,
//                 ),
//                 DMCLButton(
//                   'Đã hiểu',
//                   fontSize: 18,
//                   fontColor: Colors.white,
//                   onTap: () {
//                     if (popupInfor == PopupInfor.notFound) {
//                       Navigator.of(context).pop();
//                       Navigator.of(context).pop();
//                     } else if (popupInfor == PopupInfor.wrongMoney ||
//                         popupInfor == PopupInfor.needLessMoney) {
//                       Navigator.of(context).pop();
//                     }
//                   },
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     ),
//   );
// }

class AnimationWidget extends StatefulWidget {
  AnimationWidget(this.child, {super.key, this.duration = 2000});
  Widget child;
  int duration;

  @override
  _AnimationWidgetState createState() => _AnimationWidgetState();
}

class _AnimationWidgetState extends State<AnimationWidget>
    with TickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: widget.duration),
  )..repeat();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: RotationTransition(
          turns: controller,
          child: widget.child,
        ));
  }
}

class DMCLCardItem extends StatelessWidget {
  DMCLCardItem(
      {super.key,
      this.onTap,
      this.isSelected = false,
      required this.child,
      this.backgroundColor = Colors.transparent,
      this.backgroundSelected = Colors.redAccent,
      this.borderColor = Colors.grey,
      this.borderColorSelected = Colors.grey,
      this.width = 100,
      this.height = 60});

  double? width, height;
  Widget child;
  bool isSelected;

  Color? backgroundSelected;
  Color? backgroundColor;
  Color? borderColor;
  Color? borderColorSelected;

  void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? backgroundSelected : backgroundColor,
            border: Border.all(
                width: 1,
                color: isSelected && borderColor != Colors.transparent
                    ? borderColorSelected!
                    : borderColor!),
          ),
          width: width,
          height: height,
          child: Padding(padding: const EdgeInsets.all(8), child: child)),
    );
  }
}

Widget DMCLAppBar(context, title, siteId, {extendBody, leading}) {
  return DMCLShadow(
    direction: const Offset(0, -15),
    child: Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * .07,
          bottom: 8,
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 16, left: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: GlobalStyles.backgroundColorButton),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.place,
                            size: 20,
                            color: GlobalStyles.backgroundDisableColor,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            siteId,
                            style: TextStyle(color: GlobalStyles.textColor45),
                          ),
                        ],
                      )
                    ],
                  ),
                  if (leading != null) leading
                ],
              ),
              if (extendBody != null) extendBody
            ],
          ),
        ),
      ),
    ),
  );
}

Function debounce(int milliseconds, {Function? func}) {
  Timer? timer;
  return () {
    if (timer != null) {
      timer!.cancel();
    }

    timer = Timer(Duration(milliseconds: milliseconds), () => func!());
  };
}

class DMCLProgressbar extends StatelessWidget {
  // double width;
  double? height;
  double progress;
  Duration duration;
  BorderRadius? borderRadius;
  Color backgroundColor;
  Color foregroundColor;
  Color fontColor;

  DMCLProgressbar(
      {super.key,
      // required this.width,
      this.height = 10,
      this.duration = const Duration(milliseconds: 275),
      this.backgroundColor = const Color.fromARGB(255, 127, 127, 127),
      this.foregroundColor = Colors.amberAccent,
      this.fontColor = Colors.black,
      this.borderRadius,
      required this.progress});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius ?? BorderRadius.circular(16)),
        width: MediaQuery.of(context).size.width,
        height: height,
      ),
      AnimatedContainer(
        decoration: BoxDecoration(
            color: foregroundColor,
            borderRadius: borderRadius ?? BorderRadius.circular(16)),
        duration: duration,
        width: MediaQuery.of(context).size.width * (progress / 100),
        height: height,
      )
    ]);
  }
}

class DMCLScanQR extends StatelessWidget {
  const DMCLScanQR({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container();
  }
}
