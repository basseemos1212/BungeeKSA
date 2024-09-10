import 'package:bloc/bloc.dart';
import 'package:bungee_ksa/blocs/events/classes_event.dart';
import 'package:bungee_ksa/blocs/states/classes_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';



// Define the ClassesBloc
class ClassesBloc extends Bloc<ClassesEvent, ClassesState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ClassesBloc() : super(ClassesInitial()) {
    on<FetchClasses>(_onFetchClasses);
    on<AddClass>(_onAddClass);
  }

  void _onFetchClasses(FetchClasses event, Emitter<ClassesState> emit) async {
    emit(ClassesLoading());

    try {
      // Set up Firestore stream for real-time updates
      _firestore.collection('classes').snapshots().listen((snapshot) {
        emit(ClassesLoaded(snapshot.docs));
      });
    } catch (e) {
      emit(ClassesError('Failed to fetch classes.'));
    }
  }

  void _onAddClass(AddClass event, Emitter<ClassesState> emit) async {
    try {
      await _firestore.collection('classes').add({
        'name': event.name,
        'price': event.price,
        'type': event.type,
      });
    } catch (e) {
      emit(ClassesError('Failed to add class.'));
    }
  }
}
