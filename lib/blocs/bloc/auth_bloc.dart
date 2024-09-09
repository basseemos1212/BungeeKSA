import 'package:bloc/bloc.dart';
import 'package:bungee_ksa/data/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../events/auth_event.dart';
import '../states/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthBloc() : super(AuthInitial()) {
    on<SignUpRequested>(_onSignUpRequested);
    on<LoginRequested>(_onLoginRequested);
    on<FetchUserDataRequested>(_onFetchUserDataRequested);
  }

  // Handle Sign-Up Request
  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Sign up with Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // Create a UserModel and store it in Firestore
      UserModel newUser = UserModel(
        name: event.name,
        email: event.email,
        phoneNumber: event.phoneNumber, // Added phone number to the user model
      );
      await _firestore.collection('users').doc(userCredential.user?.uid).set(newUser.toMap());

      emit(AuthSuccess(message: "Sign up successful!"));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  // Handle Login Request
Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
  emit(AuthLoading());
  try {
    // Login with Firebase Auth
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );

    // Emit AuthSuccess once login is successful
    emit(AuthSuccess(message: "Login successful!"));
  } catch (e) {
    emit(AuthFailure(error: e.toString()));
  }
}

  // Handle Fetching User Data Request
  Future<void> _onFetchUserDataRequested(FetchUserDataRequested event, Emitter<AuthState> emit) async {
    try {
      // Fetch the user data from Firestore
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await _firestore.collection('users').doc(event.uid).get();

      if (docSnapshot.exists) {
        UserModel user = UserModel.fromMap(docSnapshot.data()!);
        emit(UserDataSuccess(user)); // Emit success with the user data
      } else {
        emit(UserDataFailure('User data not found.'));
      }
    } catch (e) {
      emit(UserDataFailure(e.toString()));
    }
  }
}
