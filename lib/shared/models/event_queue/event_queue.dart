import 'event.dart';
import 'event_listener.dart';

/// 事件队列
/// T: 事件数据，如果不需要事件数据，可以使用void
class EventQueue<T> {
  final channels = <dynamic, List<EventListener<void Function(Event<T>)>>>{};

  /// 添加监听器
  /// channel: 事件通道
  /// callback: 事件处理函数
  /// 返回值: 监听器
  EventListener addListener(dynamic channel, void Function(Event<T>) callback) {
    if (!channels.containsKey(channel)) {
      channels[channel] = [];
    }
    final listener = EventListener<void Function(Event<T>)>(
        channel, callback, _removeListener);
    channels[channel]!.add(listener);
    return listener;
  }

  /// 移除监听器
  void _removeListener(EventListener listener) {
    channels[listener.channel]
        ?.removeWhere((element) => element.id == listener.id);
  }

  /// 发送事件
  /// channel: 事件通道
  /// event: 事件
  void emit(dynamic channel, Event<T> event) {
    Future.delayed(Duration.zero, () {
      channels[channel]?.forEach((listener) {
        try {
          listener.handler(event);
        } catch (e) {}
      });
    });
  }

  /// 清除监听器
  void clear({dynamic channel}) {
    Future.delayed(Duration.zero, () {
      if (channel == null) {
        channels.clear();
      } else if (channels.containsKey(channel)) {
        channels.remove(channel);
      }
    });
  }
}
