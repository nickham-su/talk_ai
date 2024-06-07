// 菜单类型
enum LayoutMenuType {
  chat("助理"),
  llm("模型"),
  sync("同步"),
  setting("设置");

  final String value;

  const LayoutMenuType(this.value);
}
