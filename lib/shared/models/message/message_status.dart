enum MessageStatus {
  unsent(1), // 未发送
  sending(2), // 发送中
  completed(3), // 发送成功
  failed(4), // 发送失败
  cancel(5); // 用户取消

  final int value;

  const MessageStatus(this.value);
}