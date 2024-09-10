// Define Classes Events
import 'package:equatable/equatable.dart';

abstract class ClassesEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchClasses extends ClassesEvent {}

class AddClass extends ClassesEvent {
  final String name;
  final int price;
  final String type;

  AddClass({required this.name, required this.price, required this.type});

  @override
  List<Object> get props => [name, price, type];
}

