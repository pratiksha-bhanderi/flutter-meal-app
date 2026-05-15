import re
import os

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original = content

    # Add import
    if 'responsive_util.dart' not in content:
        imports = re.findall(r"import '.*';\n", content)
        if imports:
            last_import = imports[-1]
            content = content.replace(last_import, last_import + "import 'package:meal_app/core/utils/responsive_util.dart';\n")

    # 1. SizedBox
    content = re.sub(r'const SizedBox\(\s*height:\s*([\d.]+)\s*\)', r'SizedBox(height: context.h(\1))', content)
    content = re.sub(r'const SizedBox\(\s*width:\s*([\d.]+)\s*\)', r'SizedBox(width: context.w(\1))', content)

    # 2. EdgeInsets
    def repl_fromLTRB(m):
        vals = m.groups()
        out = []
        for i, v in enumerate(vals):
            if v == '0':
                out.append('0')
            else:
                if i in [0, 2]: # Left, Right
                    out.append(f'context.w({v})')
                else: # Top, Bottom
                    out.append(f'context.h({v})')
        return f"EdgeInsets.fromLTRB({out[0]}, {out[1]}, {out[2]}, {out[3]})"

    content = re.sub(r'const\s+EdgeInsets\.fromLTRB\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*\)', repl_fromLTRB, content)
    content = re.sub(r'const\s+EdgeInsets\.symmetric\(\s*horizontal:\s*([\d.]+)\s*,\s*vertical:\s*([\d.]+)\s*\)', r'EdgeInsets.symmetric(horizontal: context.w(\1), vertical: context.h(\2))', content)
    content = re.sub(r'const\s+EdgeInsets\.symmetric\(\s*horizontal:\s*([\d.]+)\s*\)', r'EdgeInsets.symmetric(horizontal: context.w(\1))', content)
    content = re.sub(r'const\s+EdgeInsets\.symmetric\(\s*vertical:\s*([\d.]+)\s*\)', r'EdgeInsets.symmetric(vertical: context.h(\1))', content)
    content = re.sub(r'const\s+EdgeInsets\.only\(\s*right:\s*([\d.]+)\s*\)', r'EdgeInsets.only(right: context.w(\1))', content)
    content = re.sub(r'const\s+EdgeInsets\.only\(\s*left:\s*([\d.]+)\s*\)', r'EdgeInsets.only(left: context.w(\1))', content)
    content = re.sub(r'const\s+EdgeInsets\.only\(\s*top:\s*([\d.]+)\s*\)', r'EdgeInsets.only(top: context.h(\1))', content)
    content = re.sub(r'const\s+EdgeInsets\.only\(\s*bottom:\s*([\d.]+)\s*\)', r'EdgeInsets.only(bottom: context.h(\1))', content)
    content = re.sub(r'const\s+EdgeInsets\.all\(\s*([\d.]+)\s*\)', r'EdgeInsets.all(context.w(\1))', content)

    # 3. font sizes
    content = re.sub(r'fontSize:\s*([\d.]+),', r'fontSize: context.sp(\1),', content)

    # 4. heights and widths
    content = re.sub(r'height:\s*170,', r'height: context.h(170),', content)
    content = re.sub(r'height:\s*130,', r'height: context.h(130),', content)
    content = re.sub(r'width:\s*130,', r'width: context.w(130),', content)
    content = re.sub(r'height:\s*90,', r'height: context.h(90),', content)
    content = re.sub(r'width:\s*44,', r'width: context.w(44),', content)
    content = re.sub(r'height:\s*44,', r'height: context.h(44),', content)
    content = re.sub(r'size:\s*20,', r'size: context.sp(20),', content)
    content = re.sub(r'width:\s*56,', r'width: context.w(56),', content)
    content = re.sub(r'height:\s*56,', r'height: context.h(56),', content)
    content = re.sub(r'size:\s*30,', r'size: context.sp(30),', content)
    content = re.sub(r'crossAxisSpacing:\s*14,', r'crossAxisSpacing: context.w(14),', content)
    content = re.sub(r'mainAxisSpacing:\s*14,', r'mainAxisSpacing: context.h(14),', content)

    # Widget passes context
    content = re.sub(r'_iconBtn\(', r'_iconBtn(\ncontext: context,', content)
    content = re.sub(r'_category\(', r'_category(context, ', content)
    content = re.sub(r'_mealCard\(', r'_mealCard(context, ', content)

    # Fix definitions
    content = re.sub(r'Widget _iconBtn\(\{', r'Widget _iconBtn({\n    required BuildContext context,', content)
    content = re.sub(r'Widget _category\(String imagePath, String label, ColorScheme cs\)', r'Widget _category(BuildContext context, String imagePath, String label, ColorScheme cs)', content)
    content = re.sub(r'Widget _mealCard\(String name, String price, String rating, String imagePath, ColorScheme cs\)', r'Widget _mealCard(BuildContext context, String name, String price, String rating, String imagePath, ColorScheme cs)', content)

    # specific to mealCard calls
    # return _mealCard(
    #    meal['name']!,
    content = re.sub(r'return _mealCard\(\n\s*meal\[\'name\'\]!,', r'return _mealCard(\ncontext,\n                          meal[\'name\']!,', content)


    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Updated {filepath}")

process_file('lib/screens/home/home_screen.dart')
