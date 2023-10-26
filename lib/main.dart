import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /* binding : 연결시킨다(우리가 어떤 파일을 실행했을때 해당 파일이 자동적으로 특정 애플리케이션과 연결 및 실행),
     ensureInitialized : 초기상태 보장, 앱 바인딩 초기화되었는지 확인
     종류 : WidgetsFlutterBinding( 애플리케이션 UI 렌더링 가능 ) vs ServiceBinding(Flutter 서비에서 대한 바인딩 실시)
   */

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

/* 비동기 async/await ' 사용을 통해 초기화하고 'MyApp클래스 인스턴스 생성하고 애플리케이션 실행
   main.dart 파일에 firebase 초기화 코드 작성(void main 함수) */

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthenticationScreen(),
    );
  }
}

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /* final을 통해서 다른 인스턴스로 가는것을 방지하지만, 참조하는 TextEditingController의 인스턴스를
     통해 TextField 내용을 수정 및 초기화가 가능해진다 */

  Future<void> signUp() async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      )
          .then((value) {
        if (value.user!.email != null) {
          print(value.user!.email);
        }
        return value;
      });
    } on FirebaseAuthException catch (e) {
      if (e.message!.contains('weak-password')) {
        print('weak-password');
      } else if (e.message!.contains('email-already-in-use')) {
        print('email-already-in-use');
      } else {
        print(e.message!);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      )
          .then((value) {
        if (value.user!.email != null) {
          print(value.user!.email);
        }
        return value;
      });
    } on FirebaseAuthException catch (e) {
      if (e.message!.contains('user-not-found')) {
        print('user-not-found');
      } else if (e.message!.contains('wrong-password')) {
        print('wrong-password');
      } else {
        print(e.message!);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> signOut() async{
    await _auth.signOut().then((value){
      print('signout');
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Auth Demo'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 400,
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                /* flutter 내부에서 제공하는 기본적인 구성요소인 controller를 통하여 아이디, 비밀번호 등 수정가능한
                부분에 할당하여 TextField의 유효성 검사를 수행, 혹은 입력값을 서버로 보내기위해 -> controller 사용
                 */
              ),
              Container(
                width: 400,
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 42),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: signUp,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('Sign up',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      )),
                  SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: signIn,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('Sign In',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      )),
                  SizedBox(width: 10),

                  ElevatedButton(
                      onPressed: signOut,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('Sign Out',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
