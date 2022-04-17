import 'package:postgrest/postgrest.dart';

class ResetHelper {
  late final PostgrestClient _postgrest;

  late final List<Map<String, dynamic>> _users;
  late final List<Map<String, dynamic>> _channels;
  late final List<Map<String, dynamic>> _messages;

  Future<void> initialize(PostgrestClient postgrest) async {
    _postgrest = postgrest;
    _users = List<Map<String, dynamic>>.from(
      (await _postgrest.from('users').select().execute()).data as List,
    );
    _channels = List<Map<String, dynamic>>.from(
      (await _postgrest.from('channels').select().execute()).data as List,
    );
    _messages = List<Map<String, dynamic>>.from(
      (await _postgrest.from('messages').select().execute()).data as List,
    );
  }

  Future<void> reset() async {
    await _postgrest.from('messages').delete().neq('message', 'dne').execute();
    await _postgrest.from('channels').delete().neq('slug', 'dne').execute();
    await _postgrest.from('users').delete().neq('username', 'dne').execute();
    try {
      await _postgrest.from('users').insert(_users).execute();
    } on PostgrestError catch (error) {
      throw 'users table was not properly reset. $error';
    }
    try {
      await _postgrest.from('channels').insert(_channels).execute();
    } on PostgrestError catch (error) {
      throw 'channels table was not properly reset. $error';
    }
    try {
      await _postgrest.from('messages').insert(_messages).execute();
    } on PostgrestError catch (error) {
      throw 'messages table was not properly reset. $error';
    }
  }
}
