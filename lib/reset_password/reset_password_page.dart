import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../login/login_page.dart';
import 'reset_password_model.dart';


//エラーを表示
String? error;

class ResetPasswordPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ResetPasswordModel>(
      create: (_) => ResetPasswordModel(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('パスワードリセット',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            },
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.white,
        body: Consumer<ResetPasswordModel>(builder: (context, model, child) {
          return Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: SizedBox(
                          //横長がウィンドウサイズの８割になる設定
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: TextField(
                            controller: model.emailController,
                            decoration: const InputDecoration(
                              labelText: 'Your Email',
                              icon: Icon(Icons.mail),
                            ),
                            onChanged: (text) {
                              model.setEmail(text);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 250),
                        child: SizedBox(
                          //横長がウィンドウサイズの３割になる設定
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () async {
                              model.startLoading();
                              try {
                                await model.sendPasswordResetEmail();
                                final snackBar = SnackBar(
                                  backgroundColor: Colors.blue,
                                  content: Text('${model.email}にメールを送信しました'),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                //現在の画面をナビゲーションスタックから取り除き、新しい画面をプッシュできる
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                );

                              } on FirebaseAuthException catch (e) {
                                //ユーザーログインに失敗した場合
                                if (e.code == 'user-not-found') {
                                  error = 'ユーザーは存在しません';
                                }
                                else if (e.code == 'invalid-email') {
                                  error = 'メールアドレスの形をしていません';
                                }
                                else {
                                  error = 'メールを送信できません';
                                }

                                final snackBar = SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(error.toString()),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              } finally {
                                model.endLoading();
                              }
                            },
                            child: const Text('送信'),
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
