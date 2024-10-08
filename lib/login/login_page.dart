import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';

import '../header_footer_drawer/footer.dart';
import '../register/register_page.dart';
import '../reset_password/reset_password_page.dart';
import 'login_model.dart';

//エラーを表示
String? error;

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginModel>(
      create: (_) => LoginModel(),
      child: PopScope(
       canPop: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
                'Labmaid(ログイン)',
                style: TextStyle(
                  color: Colors.white,
                ),
            ),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black,
          ),
          body: Consumer<LoginModel>(builder: (context, model, child) {
              return Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ConstrainedBox(
                            //横長の最大値の設定
                            constraints: const BoxConstraints(maxWidth: 700),
                            child: SizedBox(
                              //横長がウィンドウサイズの８割になる設定
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: TextField(
                                controller: model.emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
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
                            //横長の最大値の設定
                            constraints: const BoxConstraints(maxWidth: 700),
                            child: SizedBox(
                              //横長がウィンドウサイズの８割になる設定
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: TextField(
                                controller: model.passwordController,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  //鍵のアイコン
                                  icon: Icon(Icons.lock),
                                  //目隠しのアイコン
                                  suffixIcon: Icon(Icons.visibility_off)
                                ),
                                onChanged: (text) {
                                  model.setPassword(text);
                                },
                                obscureText: true,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ConstrainedBox(
                            //横長の最大値の設定
                            constraints: const BoxConstraints(maxWidth: 250),
                            child: SizedBox(
                              //横長がウィンドウサイズの３割になる設定
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: 40,
                              //変更点
                              //Googleのボタンになる
                              child: SignInButton(
                                Buttons.Google,
                                onPressed: () async {
                                  model.startLoading();
                                  //追加の処理
                                  try {
                                    await model.login();
                                    //現在の画面をナビゲーションスタックから取り除き、新しい画面をプッシュできる
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const Footer(pageNumber: 0)),
                                    );
                                  } on FirebaseAuthException catch (e) {
                                    //ユーザーログインに失敗した場合
                                    if (e.code == 'user-not-found') {
                                      error = 'ユーザーは存在しません';
                                    } else if (e.code == 'invalid-email') {
                                      error = 'メールアドレスの形をしていません';
                                    } else if (e.code == 'wrong-password') {
                                      error = 'パスワードが間違っています';
                                    } else {
                                      error = 'ログインエラー';
                                    }
                                    final snackBar = SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(error.toString()),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } finally {
                                    model.endLoading();
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextButton(
                            onPressed: () async {
                              //画面遷移
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                  fullscreenDialog: true,
                                ),
                              );
                            },
                            child: const Text('新規登録の方はこちら'),
                          ),
                          //iOS, Androidならば
                          TextButton(
                            onPressed: () async {
                              //画面遷移
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ResetPasswordPage(),
                                  fullscreenDialog: true,
                                ),
                              );
                            },
                            child: const Text('パスワードを忘れた場合はこちら'),
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
        ),
    );
  }

}
