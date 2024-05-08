/// 自增id
int _listenerId = 0;

/// 监听器
class EventListener<T> {
  final dynamic channel; // 事件通道
  final int id; // 监听Id
  final T handler; // 事件处理函数
  final Function(EventListener) onCancel; // 取消事件处理函数

  EventListener(this.channel, this.handler, this.onCancel) : id = _listenerId++;

  void cancel() {
    onCancel(this);
  }
}
