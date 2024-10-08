import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../pick_export/pick_image_export.dart';

import '../header_footer_drawer/footer.dart';
import 'register_model.dart';
import 'dart:typed_data';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key:key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  bool _isObscure = true;

  String _group = '';
  //エラーを表示
  String? error;
  String _grade = 'B4';
  String _gradeDisplay = 'B4';

  Uint8List? imageData;

  void _handleRadioButton(String group) =>
      setState(() {
        _group = group;
      });

  void _handleDropdownButton(String grade) =>
      setState(() {
        _grade = grade;
        _gradeDisplay = grade;
      });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RegisterModel>(
      create: (_) => RegisterModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            '新規登録',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.of(context).pop();
              },
              color: Colors.white,
          ),
        ),
        body: Consumer<RegisterModel>(builder: (context, model, child) {
          return Stack(
            children: [
              Center(
                //スクロール機能
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: Colors.white
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            //getImageFromGallery();
                            final _imageData = await PickImage().pickImage();
                            setState(() {
                              imageData = _imageData;
                            });
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 50,
                            backgroundImage: imageData != null ? Image.memory(imageData!).image : const AssetImage('assets/images/default.png'),
                          ),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: SizedBox(
                          //横長がウィンドウサイズの８割になる設定
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: TextField(
                            controller: model.emailController,
                            decoration: const InputDecoration(
                                labelText: 'New Email　　※必要',
                                //メールのアイコン
                                icon: Icon(Icons.mail),
                            ),
                            onChanged: (text) {
                              model.setEmail(text);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 700,
                        ),
                        child: SizedBox(
                          //横長がウィンドウサイズの８割になる設定
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: TextField(
                            controller: model.passwordController,
                            decoration: const InputDecoration(
                              labelText: 'New Password　　※必要',
                              //鍵のアイコン
                              icon: Icon(Icons.lock),

                            ),
                            onChanged: (text) {
                              model.setPassword(text);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 700,
                        ),
                        child: SizedBox(
                          //横長がウィンドウサイズの８割になる設定
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: TextFormField(
                            controller: model.passwordConfirmController,
                            obscureText: _isObscure,
                            decoration: InputDecoration(
                                labelText: 'Password Confirmation',
                                //鍵のアイコン
                                icon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () {
                                    setState(() {
                                      _isObscure = !_isObscure;
                                    });
                                  },
                                )
                            ),
                            onChanged: (text) {
                              model.setPassConfirm(text);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: SizedBox(
                          //横長がウィンドウサイズの８割になる設定
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: TextField(
                            controller: model.nameController,
                            decoration: const InputDecoration(
                              labelText: '名前(苗字のみ)　　※必要',
                              icon: Icon(Icons.person),
                            ),
                            onChanged: (text) {
                              model.setName(text);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        '選択した班：$_group',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Radio(
                                    activeColor: Colors.blueAccent,
                                    value: 'Web班',
                                    groupValue: _group,
                                    onChanged: (text) {
                                      _handleRadioButton(text!);
                                      model.groupController.text = _group;
                                      model.setGroup(_group);
                                    },
                                  ),
                                  const Text('Web班'),
                                ],
                              ),
                              Row(
                                children: [
                                  Radio(
                                    activeColor: Colors.blueAccent,
                                    value: 'Grid班',
                                    groupValue: _group,
                                    onChanged: (text) {
                                      _handleRadioButton(text!);
                                      model.groupController.text = _group;
                                      model.setGroup(_group);
                                    },
                                  ),
                                  const Text('Grid班'),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Radio(
                                    activeColor: Colors.blueAccent,
                                    value: 'Network班',
                                    groupValue: _group,
                                    onChanged: (text) {
                                      _handleRadioButton(text!);
                                      model.groupController.text = _group;
                                      model.setGroup(_group);
                                    },
                                  ),
                                  const Text('Network班'),
                                ],
                              ),
                              Row(
                                children: [
                                  Radio(
                                    activeColor: Colors.blueAccent,
                                    value: '教員',
                                    groupValue: _group,
                                    onChanged: (text) {
                                      _handleRadioButton(text!);
                                      model.groupController.text = _group;
                                      model.setGroup(_group);
                                    },
                                  ),
                                  const Text('教員'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        '選択した学年：$_grade',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      DropdownButton(
                          value: _gradeDisplay,
                          items: const [
                            DropdownMenuItem(
                              value: 'B4',
                              child: Text('B4'),
                            ),
                            DropdownMenuItem(
                              value: 'M1',
                              child: Text('M1'),
                            ),
                            DropdownMenuItem(
                              value: 'M2',
                              child: Text('M2'),
                            ),
                            DropdownMenuItem(
                              value: 'D1',
                              child: Text('D1'),
                            ),
                            DropdownMenuItem(
                              value: 'D2',
                              child: Text('D2'),
                            ),
                            DropdownMenuItem(
                              value: 'D3',
                              child: Text('D3'),
                            ),
                            DropdownMenuItem(
                              value: '教授',
                              child: Text('教授'),
                            ),
                          ],
                          onChanged: (text) {
                            _handleDropdownButton(text!);
                            model.gradeController.text = _grade;
                            model.setGrade(_grade);
                          }
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ConstrainedBox(
                        //ボタンの横長の最大値の設定
                        constraints: const BoxConstraints(maxWidth: 250),
                        child: SizedBox(
                          //横長がウィンドウサイズの３割になる設定
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () async {
                              model.startLoading();

                              try {
                                await model.signUp(imageData);
                                //ユーザー登録
                                //スタック内のすべての画面を削除し、新しい画面に遷移できる
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const Footer(pageNumber: 0)),
                                      (route) => false,
                                );
                              } on FirebaseAuthException catch (e) {
                                //ユーザー登録に失敗した場合
                                if (e.code == 'weak-password') {
                                  error = 'パスワードが弱いです。６文字以上を入力してください。';
                                }
                                else if (e.code == 'email-already-in-use') {
                                  error = 'すでに利用されているメールアドレス';
                                }
                                else if (e.code == 'invalid-email') {
                                  error = 'メールアドレスの形をしていません。';
                                }
                                else {
                                  error = 'アカウント作成エラー';
                                }
                                final snackBar = SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(error.toString()),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              } catch (e) {
                                final snackBar = SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(e.toString()),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              } finally {
                                model.endLoading();
                              }
                            },
                            child: const Text('登録する'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (model.isLoading)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
