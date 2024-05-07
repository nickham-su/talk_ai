/// 自增id
int _listenerId = 0;

/// 监听器
class EventListener<T> {
  final int id; // 监听Id
  final T handler; // 事件处理函数

  EventListener(this.handler) : id = _listenerId++;
}
