"""Build a verifiable Markdown index and contact sheets from emulator PNGs."""
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
FOLDER = ROOT / 'docs/screenshots'
FONT = ImageFont.truetype(str(ROOT / 'assets/fonts/DMSans-Medium.ttf'), 15)
GROUPS = {
    'auth': ('引导与身份流程', lambda n: n.startswith('1'), 5),
    'browse': ('首页、列表、筛选与搜索', lambda n: n.startswith('2') and int(n) < 213, 4),
    'ordering': ('餐厅、点餐与结算', lambda n: n.startswith('2') and int(n) >= 213, 3),
    'orders': ('发现、订单与评价', lambda n: n.startswith(('3','4')), 4),
    'profile': ('个人中心与设置', lambda n: n.startswith('5'), 5),
}


def collage(ids, filename, columns, width=210):
    height = round(width * 2340 / 1080)
    row_height = height + 38
    out = Image.new('RGB', (columns * (width + 18) + 18, ((len(ids)+columns-1)//columns)*row_height + 18), '#e7e9ee')
    draw = ImageDraw.Draw(out)
    for i, screen in enumerate(ids):
        x, y = 18 + (i % columns)*(width+18), 18 + (i//columns)*row_height
        image = Image.open(FOLDER / f'{screen}.png').convert('RGB')
        image.thumbnail((width, height), Image.Resampling.LANCZOS)
        out.paste(image,(x,y))
        draw.text((x+4,y+height+7), screen, font=FONT, fill='#091e42')
    out.save(FOLDER / filename, quality=91)


def main():
    manifest = json.loads((ROOT / 'docs/reference/screens.json').read_text())
    for row in manifest:
        if 'Rate item' in row['name']: row['screen']='404-item'
    expected = [r['screen'] for r in manifest]
    missing = [n for n in expected if not (FOLDER/f'{n}.png').exists()]
    if missing: raise RuntimeError(f'Missing screenshots: {missing}')
    text = ['# 界面清单与实际截图\n', '54 个设计状态全部有独立路由和 Android Flutter 渲染截图；相同业务页的空白/填充、列表版本及弹层由参数和本地状态复用。', '\n截图为 `1080×2340`。下列链接可查看原始 PNG；每组附一张缩略总览。\n']
    for name,(title,predicate,columns) in GROUPS.items():
        rows=[r for r in manifest if predicate(r['screen'])]
        collage([r['screen'] for r in rows],f'gallery-{name}.jpg',columns)
        text += [f'\n## {title}\n', f'![{title}](screenshots/gallery-{name}.jpg)\n', '| 路由编号 | Pixso 原页面 | 截图 |','| --- | --- | --- |']
        for row in rows:
            id=row['screen']
            text.append(f'| `/{id}` | {row["name"]} | [查看 PNG](screenshots/{id}.png) |')
    text += ['\n## 长页补充\n','主要长页面同时提供滚动后截图；与首屏配合检查菜单、结算及设置等内容。\n','| 页面 | 滚动后截图 |','| --- | --- |']
    for id,title in [('201','首页商家列表'),('213','咖啡餐厅完整菜单'),('214','披萨餐厅完整菜单'),('215','评论列表'),('218','优惠码、备注及支付方式'),('501','通知偏好及退出')]:
        text.append(f'| {title} | [查看 PNG](screenshots/{id}-bottom.png) |')
    text += ['\n## 状态说明\n','- `101–103` 为三张独立引导，`104/105`、`110/111`、`112/113` 复用表单并指定是否预填。', '- `201–203` 是同一首页数据的不同布局，`204/205` 为列表/网格，`206` 为带配送摘要的首页。', '- `207–209` 指定筛选标签，`210` 展示全部筛选项；选项会实际影响商家列表。', '- `213/214` 分别显示咖啡/披萨餐厅，`215` 打开评论；`216/217/219/221` 为商品、购物车、付款方式和成功弹层。', '- `401` 使用配送中示例状态；首次正常运行没有订单时会显示空状态。`402` 中的设计历史卡片是演示数据。', '- `403 → 404 → 404-item → 405` 为配送员、店铺、商品评价和成功反馈流程；原稿两个 `404` 已分开命名。', '- `504/505` 使用同一个付款方式组件，分别注入无卡和已添加掩码卡片的示例；`506` 为选择卡种弹层，`507` 为添加表单。', '- 测试数据在 `test/fixtures.dart` 中，与产品业务代码及真实本地数据隔离。']
    (ROOT / 'docs/界面清单.md').write_text('\n'.join(text)+'\n',encoding='utf-8')
    collage(['201','214','218','301','401','501'],'main-flow.jpg',3,320)
    print(f'Indexed {len(manifest)} screens and generated 6 galleries.')


if __name__ == '__main__': main()
