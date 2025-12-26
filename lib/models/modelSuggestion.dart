
 import 'dart:core';
import 'package:flutter/material.dart';
 class Suggestion {
   String idNumber;
   String objet;
   String message;
   Suggestion(this.idNumber, this.objet, this.message);

   String get getIdNumber {
     return idNumber;
   }

   set setIdNumber(String newIdNumber) {
     idNumber = newIdNumber;
   }

 }
