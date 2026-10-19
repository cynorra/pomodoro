"""Build the Play Console "release notes" block for every locale.

Run:  python scripts/store-listing/release_notes.py
Output: store-assets/release-notes-all-locales.txt  (paste into the release notes box;
format <locale> ... </locale>, en-US first, then the console order; max 500 chars each).

Languages without their own translation use the nearest language, same as the listing CSV.
"""
import os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from locales import ALL_LOCALES, NATIVE_OF, OWN_SHORT   # noqa: E402

ROOT = os.path.dirname(os.path.dirname(HERE))

NOTES = {
    'en': "First release of Study Cafe: a cozy Pomodoro timer with points, daily streaks, achievements and a virtual cafe you stock with treats. Available in English and Turkish.",
    'tr': "Study Cafe'nin ilk sürümü: puan, günlük seri, başarım ve ikramlarla doldurabileceğin sanal bir kafe içeren rahat bir pomodoro zamanlayıcı. Türkçe ve İngilizce dilleriyle.",
    'de': "Erste Version von Study Cafe: ein gemütlicher Pomodoro-Timer mit Punkten, täglichen Serien, Erfolgen und einem virtuellen Café, das du mit Köstlichkeiten füllst. Verfügbar auf Englisch und Türkisch.",
    'es': "Primera versión de Study Cafe: un temporizador Pomodoro acogedor con puntos, rachas diarias, logros y un café virtual que llenas de delicias. Disponible en inglés y turco.",
    'fr': "Première version de Study Cafe : un minuteur Pomodoro chaleureux avec points, séries quotidiennes, succès et un café virtuel à garnir de gourmandises. Disponible en anglais et en turc.",
    'it': "Prima versione di Study Cafe: un accogliente timer Pomodoro con punti, serie giornaliere, obiettivi e un caffè virtuale da riempire di delizie. Disponibile in inglese e turco.",
    'pt-BR': "Primeira versão do Study Cafe: um timer Pomodoro aconchegante com pontos, sequências diárias, conquistas e um café virtual que você enche de delícias. Disponível em inglês e turco.",
    'pt-PT': "Primeira versão do Study Cafe: um temporizador Pomodoro acolhedor com pontos, séries diárias, conquistas e um café virtual que enche de iguarias. Disponível em inglês e turco.",
    'ru': "Первая версия Study Cafe: уютный помодоро-таймер с очками, ежедневными сериями, достижениями и виртуальным кафе, которое вы наполняете угощениями. Доступно на английском и турецком языках.",
    'uk': "Перша версія Study Cafe: затишний помодоро-таймер з балами, щоденними серіями, досягненнями та віртуальним кафе, яке ви наповнюєте смаколиками. Доступно англійською та турецькою.",
    'pl': "Pierwsza wersja Study Cafe: przytulny timer Pomodoro z punktami, codziennymi seriami, osiągnięciami i wirtualną kawiarnią, którą zapełniasz przysmakami. Dostępna po angielsku i turecku.",
    'nl': "Eerste versie van Study Cafe: een gezellige Pomodoro-timer met punten, dagelijkse reeksen, prestaties en een virtueel café dat je vult met lekkernijen. Beschikbaar in het Engels en Turks.",
    'sv': "Första versionen av Study Cafe: en mysig Pomodoro-timer med poäng, dagliga streaks, prestationer och ett virtuellt kafé som du fyller med godsaker. Finns på engelska och turkiska.",
    'da': "Første version af Study Cafe: en hyggelig Pomodoro-timer med point, daglige serier, præstationer og en virtuel café, du fylder med lækkerier. Fås på engelsk og tyrkisk.",
    'no': "Første versjon av Study Cafe: en koselig Pomodoro-timer med poeng, daglige rekker, prestasjoner og en virtuell kafé du fyller med godsaker. Tilgjengelig på engelsk og tyrkisk.",
    'fi': "Study Cafen ensimmäinen versio: viihtyisä Pomodoro-ajastin, jossa on pisteitä, päivittäisiä putkia, saavutuksia ja virtuaalinen kahvila, jonka täytät herkuilla. Saatavilla englanniksi ja turkiksi.",
    'cs': "První verze Study Cafe: útulný časovač Pomodoro s body, denními sériemi, úspěchy a virtuální kavárnou, kterou plníš pochoutkami. K dispozici v angličtině a turečtině.",
    'hu': "A Study Cafe első verziója: hangulatos Pomodoro időzítő pontokkal, napi sorozatokkal, eredményekkel és egy virtuális kávézóval, amelyet finomságokkal töltesz meg. Angolul és törökül érhető el.",
    'ro': "Prima versiune Study Cafe: un temporizator Pomodoro primitor cu puncte, serii zilnice, realizări și o cafenea virtuală pe care o umpli cu bunătăți. Disponibilă în engleză și turcă.",
    'el': "Πρώτη έκδοση του Study Cafe: ένα ζεστό χρονόμετρο Pomodoro με πόντους, καθημερινά σερί, επιτεύγματα και ένα εικονικό καφέ που γεμίζεις με λιχουδιές. Διαθέσιμο στα αγγλικά και τα τουρκικά.",
    'bg': "Първа версия на Study Cafe: уютен помодоро таймер с точки, ежедневни серии, постижения и виртуално кафене, което пълниш с вкусотии. Налично на английски и турски.",
    'hr': "Prva verzija Study Cafea: ugodan Pomodoro timer s bodovima, dnevnim nizovima, postignućima i virtualnim kafićem koji puniš đakonijama. Dostupno na engleskom i turskom.",
    'ar': "الإصدار الأول من Study Cafe: مؤقت بومودورو دافئ مع نقاط وتتابع يومي وإنجازات ومقهى افتراضي تملؤه بالأطايب. متوفر بالإنجليزية والتركية.",
    'fa': "نسخه‌ی اول Study Cafe: یک تایمر پومودورو دنج با امتیاز، تداوم روزانه، دستاوردها و یک کافه‌ی مجازی که با خوراکی‌ها پرش می‌کنی. به زبان‌های انگلیسی و ترکی.",
    'he': "הגרסה הראשונה של Study Cafe: טיימר פומודורו חמים עם נקודות, רצפים יומיים, הישגים ובית קפה וירטואלי שממלאים בפינוקים. זמין באנגלית ובטורקית.",
    'hi': "Study Cafe का पहला संस्करण: पॉइंट, रोज़ाना स्ट्रीक, उपलब्धियों और ऐसे वर्चुअल कैफ़े वाला आरामदायक पोमोडोरो टाइमर, जिसे आप स्वादिष्ट चीज़ों से भरते हैं। अंग्रेज़ी और तुर्की में उपलब्ध।",
    'bn': "Study Cafe-এর প্রথম সংস্করণ: পয়েন্ট, দৈনিক স্ট্রিক, অর্জন এবং খাবারে ভরানো ভার্চুয়াল ক্যাফেসহ আরামদায়ক পোমোডোরো টাইমার। ইংরেজি ও তুর্কি ভাষায় পাওয়া যায়।",
    'ur': "Study Cafe کا پہلا ورژن: پوائنٹس، روزانہ اسٹریک، کامیابیوں اور ایسے ورچوئل کیفے کے ساتھ آرام دہ پومودورو ٹائمر جسے آپ لذیذ چیزوں سے بھرتے ہیں۔ انگریزی اور ترکی میں دستیاب۔",
    'id': "Rilis pertama Study Cafe: timer Pomodoro yang nyaman dengan poin, streak harian, pencapaian, dan kafe virtual yang kamu isi dengan sajian. Tersedia dalam bahasa Inggris dan Turki.",
    'ms': "Keluaran pertama Study Cafe: pemasa Pomodoro yang selesa dengan mata, streak harian, pencapaian dan kafe maya yang anda isi dengan hidangan. Tersedia dalam bahasa Inggeris dan Turki.",
    'vi': "Phiên bản đầu tiên của Study Cafe: bộ hẹn giờ Pomodoro ấm cúng với điểm, chuỗi ngày, thành tích và quán cà phê ảo bạn lấp đầy bằng món ngon. Có tiếng Anh và tiếng Thổ Nhĩ Kỳ.",
    'th': "Study Cafe เวอร์ชันแรก: ตัวจับเวลาโพโมโดโรแสนอบอุ่น มีแต้ม สตรีครายวัน ความสำเร็จ และคาเฟ่เสมือนที่คุณเติมเต็มด้วยของอร่อย มีภาษาอังกฤษและตุรกี",
    'fil': "Unang release ng Study Cafe: maaliwalas na Pomodoro timer na may points, araw-araw na streak, achievements, at virtual cafe na pupunuin mo ng pagkain. Available sa English at Turkish.",
    'ja': "Study Cafeの初回リリース：ポイント、毎日の連続記録、実績、そしておいしいものを並べるバーチャルカフェを備えた、居心地のよいポモドーロタイマーです。英語とトルコ語に対応。",
    'ko': "Study Cafe 첫 출시: 포인트, 매일 연속 기록, 업적, 맛있는 메뉴로 채우는 가상 카페를 갖춘 아늑한 포모도로 타이머입니다. 영어와 터키어를 지원합니다.",
    'zh-CN': "Study Cafe 首次发布：温馨的番茄钟，包含积分、每日连续记录、成就，以及可用美食装满的虚拟咖啡馆。支持英语和土耳其语。",
    'zh-TW': "Study Cafe 首次發布：溫馨的番茄鐘，包含積分、每日連續紀錄、成就，以及可用美食裝滿的虛擬咖啡館。支援英文與土耳其文。",
}


def note_for(loc):
    if loc in NATIVE_OF:
        return NOTES[NATIVE_OF[loc]]
    return NOTES[OWN_SHORT[loc][1]]       # nearest language, as for the full description


def main():
    order = ['en-US'] + [l for l in ALL_LOCALES if l != 'en-US']     # the console lists en-US first
    blocks = []
    for loc in order:
        text = note_for(loc)
        assert 0 < len(text) <= 500, (loc, len(text))
        blocks.append('<%s>\n%s\n</%s>' % (loc, text, loc))
    out = os.path.join(ROOT, 'store-assets', 'release-notes-all-locales.txt')
    open(out, 'w', encoding='utf-8', newline='\n').write('\n'.join(blocks) + '\n')
    print('wrote', out, len(blocks), 'blocks, longest', max(len(note_for(l)) for l in order), 'chars')


if __name__ == '__main__':
    main()
