import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_permission_bloc.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_permission_event.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_permission_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter.baseflow.com/permissions/methods');

  void mockPermissionChannel({int checkStatus = 0, int requestStatus = 1}) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'checkPermissionStatus') {
            return checkStatus;
          }
          if (call.method == 'requestPermissions') {
            return <int, int>{13: requestStatus};
          }
          return null;
        });
  }

  setUp(() {
    mockPermissionChannel();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('starts with initial state', () {
    final bloc = SmsPermissionBloc();
    expect(bloc.state, const SmsPermissionInitial());
    bloc.close();
  });

  test('check permission emits loading then denied', () async {
    final bloc = SmsPermissionBloc();
    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([const SmsPermissionLoading(), const SmsPermissionDenied()]),
    );

    bloc.add(const CheckSmsPermission());
    await expectation;
    await bloc.close();
  });

  test('request permission emits loading then denied by default', () async {
    final bloc = SmsPermissionBloc();
    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([const SmsPermissionLoading(), const SmsPermissionDenied()]),
    );

    bloc.add(const RequestSmsPermission());
    await expectation;
    await bloc.close();
  });

  test(
    'check permission emits permanently denied when blocked forever',
    () async {
      mockPermissionChannel(checkStatus: 4);
      final bloc = SmsPermissionBloc();
      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const SmsPermissionLoading(),
          const SmsPermissionPermanentlyDenied(),
        ]),
      );

      bloc.add(const CheckSmsPermission());
      await expectation;
      await bloc.close();
    },
  );

  test('request permission emits denied when request is rejected', () async {
    mockPermissionChannel(requestStatus: 0);
    final bloc = SmsPermissionBloc();
    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([const SmsPermissionLoading(), const SmsPermissionDenied()]),
    );

    bloc.add(const RequestSmsPermission());
    await expectation;
    await bloc.close();
  });
}
