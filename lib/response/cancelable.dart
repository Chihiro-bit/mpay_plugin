typedef WeChatResponseSubscriber = void Function(Map event);

mixin FluwxCancelable {
  void cancel();
}

class FluwxCancelableImpl implements FluwxCancelable {
  final Function onCancel;

  FluwxCancelableImpl({required this.onCancel});

  @override
  void cancel() {
    onCancel();
  }
}
