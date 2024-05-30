import 'package:markdown/markdown.dart' as m;

/// 自定义markdown图片解析语法
class CustomImageSyntax extends m.InlineSyntax {
  CustomImageSyntax() : super(r'!\[([^\]]+)\]\(([^)\s]+)(?:\s+"([^"]+)")?\)');

  @override
  bool onMatch(m.InlineParser parser, Match match) {
    final alt = match.group(1);
    final src = match.group(2);
    final title = match.group(3);
    m.Element el = m.Element.withTag('img');
    el.attributes['alt'] = alt ?? '';
    el.attributes['src'] = src ?? '';
    el.attributes['title'] = title ?? '';
    parser.addNode(el);
    return true;
  }
}
