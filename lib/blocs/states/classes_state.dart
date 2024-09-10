// Define Classes State
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class ClassesState extends Equatable {
  @override
  List<Object> get props => [];
}

class ClassesInitial extends ClassesState {}

class ClassesLoading extends ClassesState {}

class ClassesLoaded extends ClassesState {
  final List<DocumentSnapshot> classes;
  
  ClassesLoaded(this.classes);

  @override
  List<Object> get props => [classes];
}

class ClassesError extends ClassesState {
  final String message;
  
  ClassesError(this.message);
  
  @override
  List<Object> get props => [message];
}