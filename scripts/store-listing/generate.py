"""Build the Play Console multi-language listing CSV.

Run:  python scripts/store-listing/generate.py
Output: store-assets/play-listing-all-locales.csv
Format rules: see ~/.claude/play-store-listing-csv-format.md
(header Language,Title,Short description,Full description; UTF-8 without BOM; CRLF rows;
limits in code points: title 30, short 80, full 4000; en-US required; Hebrew is iw-IL).
"""
import csv, io, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from content_native import NATIVE          # noqa: E402
from locales import ALL_LOCALES, NATIVE_OF, OWN_SHORT, SHORT_FIX   # noqa: E402

ROOT = os.path.dirname(os.path.dirname(HERE))
SA = os.path.join(ROOT, 'store-assets')
EMAIL = 'eren.gp54@gmail.com'
PRIV = 'https://cynorra.github.io/studycafe/privacy.html'
PRIV_TR = 'https://cynorra.github.io/studycafe/privacy-tr.html'
ENGLISH_TITLE = 'Study Cafe: Pomodoro Timer'
LIMITS = (30, 80, 4000)


def read_listing(name):
    """Parse the hand-tuned TITLE / SHORT / FULL file of en-US or tr-TR."""
    text = open(os.path.join(SA, name), encoding='utf-8').read().replace('\r\n', '\n')
    head, rest = text.split('\n\nSHORT\n', 1)
    short, full = rest.split('\n\nFULL\n', 1)
    return head.replace('TITLE\n', '', 1).strip(), short.strip(), full.strip()


def assemble(e, url):
    bullets = '\n'.join('- ' + b for b in e['f'])
    return '\n\n'.join([
        e['intro'],
        e['how_h'] + '\n' + e['how'],
        e['feat_h'] + '\n' + bullets,
        e['note'],
        '%s: %s\n%s: %s' % (e['priv'], url, e['contact'], EMAIL),
    ])


def build():
    en = read_listing('listing-en-US.txt')
    tr = read_listing('listing-tr-TR.txt')
    entries = {'en': dict(title=en[0], short=en[1], full=en[2]),
               'tr': dict(title=tr[0], short=tr[1], full=tr[2])}
    for key, e in NATIVE.items():
        entries[key] = dict(title=e['title'], short=SHORT_FIX.get(key, e['short']),
                            full=assemble(e, PRIV_TR if key == 'tr' else PRIV))

    rows, notes = [], []
    for loc in ALL_LOCALES:
        if loc in NATIVE_OF:
            e = entries[NATIVE_OF[loc]]
            rows.append((loc, e['title'], e['short'], e['full']))
        else:
            short, fallback = OWN_SHORT[loc]
            short = SHORT_FIX.get(loc, short)
            full = entries[fallback]['full']
            rows.append((loc, ENGLISH_TITLE, short, full))
            notes.append('%s: own short, full text from %s' % (loc, fallback))
    return rows, notes


def validate(rows):
    seen = set()
    problems = []
    for loc, t, s, f in rows:
        if loc in seen:
            problems.append('duplicate ' + loc)
        seen.add(loc)
        for label, val, lim in (('title', t, LIMITS[0]), ('short', s, LIMITS[1]), ('full', f, LIMITS[2])):
            if len(val) > lim:
                problems.append('%s %s is %d > %d' % (loc, label, len(val), lim))
            if not val.strip():
                problems.append('%s %s is empty' % (loc, label))
    if set(seen) != set(ALL_LOCALES):
        problems.append('locale set mismatch: %s' % (set(ALL_LOCALES) ^ set(seen)))
    if 'en-US' not in seen:
        problems.append('en-US row missing')
    if 'he' in seen or 'iw-IL' not in seen:
        problems.append('Hebrew must be iw-IL')
    return problems


def main():
    rows, notes = build()
    problems = validate(rows)
    if problems:
        print('\n'.join(problems))
        sys.exit(1)
    buf = io.StringIO(newline='')
    w = csv.writer(buf, lineterminator='\r\n', quoting=csv.QUOTE_MINIMAL)
    w.writerow(['Language', 'Title', 'Short description', 'Full description'])
    for loc, t, s, f in rows:
        w.writerow([loc, t, s, f.replace('\r\n', '\n').replace('\n', '\r\n')])
    data = buf.getvalue().encode('utf-8')          # no BOM
    assert not data.startswith(b'\xef\xbb\xbf')
    out = os.path.join(SA, 'play-listing-all-locales.csv')
    open(out, 'wb').write(data)
    print('wrote', out, len(rows), 'locales,', len(data) // 1024, 'KB')
    print('locales with a fallback full text:', len(notes))


if __name__ == '__main__':
    main()
