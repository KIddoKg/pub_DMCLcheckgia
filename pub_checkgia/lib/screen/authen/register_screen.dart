 import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';
 
 import 'package:pub_dmclcheckgia/pub_DMCLcheckgia.dart';
import 'package:flutter/material.dart';

class ResigterScreen extends StatefulWidget {
  const ResigterScreen({super.key});

  @override
  State<ResigterScreen> createState() => _ResigterScreenState();
}

class _ResigterScreenState extends State<ResigterScreen> {
  TextEditingController fieldEmployerCode = TextEditingController();
  TextEditingController fieldNumberPhone = TextEditingController();
  TextEditingController fieldEMEI = TextEditingController();
  TextEditingController fieldPass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalStyles.primaryColor,
      appBar: AppBar(
        title: const Text('Đăng ký'),
        backgroundColor: HexColor.fromHex("025ca6"),
      ),
      body: Container(
          decoration: BoxDecoration(
              color: HexColor.fromHex("025ca6"),
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 16),
            child: Column(
              children: [
                Image.asset(
                  "assets/img/logo.png",
                  width: MediaQuery.of(context).size.width * .9,
                  height: MediaQuery.of(context).size.height * .1,
                ),
                const SizedBox(
                  height: 32,
                ),
                DMCLCard(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 16.0, bottom: 16, left: 18, right: 18),
                    child: Column(
                      children: [
                        DMCLFieldFrom(
                          labelTitle: 'Tên nhân viên',
                          controller: fieldEmployerCode,
                          bottomSpacing: 8,
                        ),
                        DMCLFieldFrom(
                          labelTitle: 'Số điện thoại',
                          controller: fieldNumberPhone,
                          bottomSpacing: 8,
                        ),
                        DMCLFieldFrom(
                          labelTitle: 'Mật khẩu',
                          controller: fieldPass,
                          bottomSpacing: 8,
                        ),
                        const SizedBox(
                          height: 28,
                        ),
                        DMCLButton(
                          'Đăng ký',
                          fontColor: Colors.white,
                          onTap: () {
                            // Fluttertoast.showToast(msg: 'Đăng ký');
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }

  List<String> checkValidate() {
    return [];
  }

  void onRegister() {}
}
