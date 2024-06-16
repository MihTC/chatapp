import 'dart:io';

import 'package:chatapp/consts.dart';
import 'package:chatapp/services/auth_service.dart';
import 'package:chatapp/services/media_service.dart';
import 'package:chatapp/services/navigation_service.dart';
import 'package:chatapp/services/storage_service.dart';
import 'package:chatapp/widget/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? email, password, name;
  File? selectionImage;
  bool isLoading = false;

  final GlobalKey<FormState> _registerFormKey = GlobalKey();

  final GetIt _getIt = GetIt.instance;

  late MediaService _mediaService;
  late NavigationService _navigationService;
  late AuthService _authService;
  late StorageService _storageService;

  @override
  void initState() {
    super.initState();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _storageService = _getIt.get<StorageService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20.0),
      child: Column(
        children: [
          _headerText(),
          if (!isLoading) _registerForm(),
          if (!isLoading) _loginAccountLink(),
          if (isLoading)
            const Expanded(
                child: Center(
              child: CircularProgressIndicator(),
            ))
        ],
      ),
    ));
  }

  Widget _headerText() {
    return SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: const Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Let's, get going!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            Text("Register an account using the form below",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey)),
          ],
        ));
  }

  Widget _registerForm() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.60,
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.sizeOf(context).height * 0.05),
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _pfpSelectionFiled(),
            CustomFormField(
              height: MediaQuery.sizeOf(context).height * 0.1,
              hintText: "Name",
              validationRegEx: NAME_VALIDATION_REGEX,
              onSaved: (value) {
                setState(() {
                  name = value;
                });
              },
            ),
            CustomFormField(
              height: MediaQuery.sizeOf(context).height * 0.1,
              hintText: "Email",
              validationRegEx: EMAIL_VALIDATION_REGEX,
              onSaved: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            CustomFormField(
              height: MediaQuery.sizeOf(context).height * 0.1,
              hintText: "Password",
              validationRegEx: PASSWORD_VALIDATION_REGEX,
              obscureText: true,
              onSaved: (value) {
                setState(() {
                  password = value;
                });
              },
            ),
            _registerButton()
          ],
        ),
      ),
    );
  }

  Widget _pfpSelectionFiled() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          setState(() {
            selectionImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width * 0.15,
        backgroundImage: selectionImage != null
            ? FileImage(selectionImage!)
            : const NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
      ),
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          try {
            if ((_registerFormKey.currentState?.validate() ?? false) &&
                selectionImage != null) {
              _registerFormKey.currentState?.save();
              bool result = await _authService.signup(email!, password!);
              if (result) {
                String? pfpURL = await _storageService.uploadUserPfp(
                    file: selectionImage!, uid: _authService.user!.uid);
                //_navigationService.pushReplacementNamed("/home");
              } else {
                // _alertService.showToast(
                //     text: "Failed to login, Please try again!!",
                //     icon: Icons.error);
              }
            }
          } catch (e) {
            print(e);
          }
          setState(() {
            isLoading = false;
          });
        },
        color: Theme.of(context).colorScheme.primary,
        child: const Text(
          "Register",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _loginAccountLink() {
    return Expanded(
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
          const Text("Already have an acccount? "),
          GestureDetector(
            onTap: () {
              _navigationService.goBack();
            },
            child: const Text(
              "Login",
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          )
        ]));
  }
}
