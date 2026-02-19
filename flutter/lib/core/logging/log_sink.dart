abstract class LogSink {
  Future<void> write(String line);

  Future<void> dispose();
}
