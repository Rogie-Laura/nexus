import 'package:flutter/material.dart';

bool areFieldsValid({
  required BuildContext context,
  required String token,
  required String deployment,
  FocusNode? tokenFocusNode,
  FocusNode? deploymentFocusNode,
}) {
  FocusScope.of(context).unfocus();

  String message = '';

  if (token.trim().isEmpty) {
    message = '⚠️ Token is required';
    tokenFocusNode?.requestFocus(); // ✅ Focus safely
  } else if (deployment.trim().isEmpty) {
    message = '⚠️ Deployment ID is required';
    deploymentFocusNode?.requestFocus(); // ✅ Focus safely
  }

  if (message.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 80, left: 16, right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
    return false;
  }

  return true;
}
