"""Extract the supplied Coody Sketch resources without changing the Pixso file."""
import io
import json
import re
import sys
import zipfile
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]


def point(value, width, height):
    x, y = map(float, re.findall(r'[-\d.eE]+', value))
    return f'{x * width:.4f},{y * height:.4f}'


def svg_node(node):
    f = node['frame']
    w, h = f['width'], f['height']
    fills = [p for p in node.get('style', {}).get('fills', []) if p.get('isEnabled')]
    color = fills[0].get('color') if fills else None
    fill = ('#' + ''.join(f'{round(color[k] * 255):02x}' for k in ('red', 'green', 'blue'))) if color else 'none'
    content = ''
    if node['_class'] == 'shapePath' and node.get('points'):
        ps = node['points']
        content = f'M {point(ps[0]["point"], w, h)} '
        for i in range(1, len(ps) + int(node.get('isClosed', False))):
            a, b = ps[(i-1) % len(ps)], ps[i % len(ps)]
            if a.get('hasCurveFrom') or b.get('hasCurveTo'):
                content += f'C {point(a["curveFrom"],w,h)} {point(b["curveTo"],w,h)} {point(b["point"],w,h)} '
            else:
                content += f'L {point(b["point"],w,h)} '
        if node.get('isClosed'): content += 'Z'
        content = f'<path d="{content}" fill="{fill}"/>'
    elif node['_class'] == 'rectangle' and fill != 'none':
        radius = max([p.get('cornerRadius', 0) for p in node.get('points', [])] or [0])
        content = f'<rect width="{w}" height="{h}" rx="{radius}" fill="{fill}"/>'
    elif node['_class'] == 'oval':
        content = f'<ellipse cx="{w/2}" cy="{h/2}" rx="{w/2}" ry="{h/2}" fill="{fill}"/>'
    content += ''.join(svg_node(c) for c in node.get('layers', []))
    return f'<g transform="translate({f["x"]} {f["y"]})">{content}</g>'


def main(source):
    with zipfile.ZipFile(source) as outer:
        sketch = zipfile.ZipFile(io.BytesIO(outer.read(next(n for n in outer.namelist() if n.endswith('.sketch')))))
        design = next(json.loads(sketch.read(n)) for n in sketch.namelist() if n.startswith('pages/') and json.loads(sketch.read(n)).get('name') == 'Design')
        refs = json.loads((ROOT / 'tool/image-index.json').read_text(encoding='utf-8'))
        for entry in refs:
            im = Image.open(io.BytesIO(sketch.read(entry['ref'])))
            im.thumbnail((1400, 1400))
            im.save(ROOT / f'assets/images/asset_{entry["index"]:02}.webp', quality=91)
        for board in design['layers'][:3]:
            illustration = next(n for n in board['layers'] if n['name'] == 'Illustration')
            illustration['frame']['x'] = illustration['frame']['y'] = 0
            svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 305 305">' + svg_node(illustration) + '</svg>'
            (ROOT / f'assets/images/onboarding_{board["name"][:3]}.svg').write_text(svg)
        for n in outer.namelist():
            if n.endswith(('DMSans-Regular.ttf', 'DMSans-Medium.ttf', 'DMSans-Bold.ttf')):
                (ROOT / 'assets/fonts' / Path(n).name).write_bytes(outer.read(n))
        manifest = [{'screen': a['name'].split(' - ')[0], 'name': a['name'], 'width': a['frame']['width'], 'height': a['frame']['height']} for a in design['layers']]
        (ROOT / 'docs/reference/screens.json').write_text(json.dumps(manifest, indent=2))
        doc = json.loads(sketch.read('document.json'))
        palette = []
        for style in doc['layerStyles']['objects']:
            palette.append({'name':style['name'], 'fills':style['value'].get('fills')})
        (ROOT / 'docs/reference/palette.json').write_text(json.dumps(palette,indent=2))
        print(f'Extracted {len(refs)} images, 3 illustrations, 3 fonts and {len(manifest)} screens.')


if __name__ == '__main__':
    main(sys.argv[1])
