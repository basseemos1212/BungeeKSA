import 'package:bloc/bloc.dart';
import 'package:bungee_ksa/data/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../events/auth_event.dart';
import '../states/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthBloc() : super(AuthInitial()) {
    on<SignUpRequested>(_onSignUpRequested);
    on<LoginRequested>(_onLoginRequested);
    on<FetchUserDataRequested>(_onFetchUserDataRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatusRequested>(_onCheckAuthStatusRequested);
  }

  // Handle Sign-Up Request
  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // Create a UserModel and store it in Firestore
      UserModel newUser = UserModel(
        name: event.name,
        email: event.email,
        phoneNumber: event.phoneNumber,
        profileImageUrl: "", // Profile image is empty or null at sign-up
      );
      await _firestore.collection('users').doc(userCredential.user?.uid).set(newUser.toMap());

      // Save session info in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userCredential.user!.uid);

      emit(const AuthSuccess(message: "Sign up successful!"));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  // Handle Login Request
  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // Save session info in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userCredential.user!.uid);

      emit(const AuthSuccess(message: "Login successful!"));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  // Handle Fetching User Data Request
  Future<void> _onFetchUserDataRequested(FetchUserDataRequested event, Emitter<AuthState> emit) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await _firestore.collection('users').doc(event.uid).get();

      if (docSnapshot.exists) {
        UserModel user = UserModel.fromMap(docSnapshot.data()!);
        emit(UserDataSuccess(user));
      } else {
        emit(const UserDataFailure('User data not found.'));
      }
    } catch (e) {
      emit(UserDataFailure(e.toString()));
    }
  }

  // Handle Logout Request and remove from SharedPreferences
  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await _auth.signOut(); // Log out from Firebase
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId'); // Clear the stored user session

      emit(AuthLoggedOut()); // Emit logged-out state
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  // Check if the user is already logged in via SharedPreferences
  Future<void> _onCheckAuthStatusRequested(CheckAuthStatusRequested event, Emitter<AuthState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId != null) {
        // Fetch user data and emit success
        add(FetchUserDataRequested(userId));
      } else {
        emit(AuthLoggedOut()); // Emit logged-out state if no session found
      }
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }
}
