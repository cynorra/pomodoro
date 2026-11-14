import 'dart:ui' show PlatformDispatcher;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Every text a notification can show, per language. Notifications are built
/// outside the widget tree (often while the app is closed), so they cannot use
/// the ARB files; English is the default and the fallback.
class NotificationTexts {
  final String focusDone;
  final String breakDone;
  final String timerFocus;
  final String timerBreak;

  /// Body of the running-timer notification; `{n}` is the session minutes.
  final String running;
  final String channelTimer;
  final String channelReminder;
  final List<String> reminders;

  const NotificationTexts({
    required this.focusDone,
    required this.breakDone,
    required this.timerFocus,
    required this.timerBreak,
    required this.running,
    required this.channelTimer,
    required this.channelReminder,
    required this.reminders,
  });

  String runningBody(int minutes) => running.replaceAll('{n}', '$minutes');

  /// The reminder for the [index]th day, cycling through the list.
  String reminder(int index) => reminders[index % reminders.length];

  static const fallbackLanguage = 'en';

  static Iterable<String> get languages => _all.keys;

  /// The texts for [languageCode]; unknown languages get English.
  static NotificationTexts forLanguage(String? languageCode) =>
      _all[languageCode] ?? _all[fallbackLanguage]!;

  /// The language the user picked in the app, otherwise the device language.
  static Future<String> resolveLanguage() async {
    try {
      final chosen =
          await const FlutterSecureStorage().read(key: 'selected_locale');
      if (chosen != null && _all.containsKey(chosen)) return chosen;
    } catch (_) {}
    final device = PlatformDispatcher.instance.locale.languageCode;
    return _all.containsKey(device) ? device : fallbackLanguage;
  }

  static Future<NotificationTexts> load() async =>
      forLanguage(await resolveLanguage());

  static const _all = <String, NotificationTexts>{
    'en': NotificationTexts(
      focusDone: 'Focus session done, time for a break! ☕',
      breakDone: 'Break is over, time to focus!',
      timerFocus: 'Focus time 🍅',
      timerBreak: 'Break time ☕',
      running: '{n} min session. Stay with it!',
      channelTimer: 'Running timer',
      channelReminder: 'Daily study reminders',
      reminders: [
        'Time to study! One Pomodoro is all it takes to get started. 🍅',
        'Your cafe is waiting. Come focus for a session! ☕',
        'Keep your streak alive: one focus session today? 🔥',
        'A small step today, a big win tomorrow. Start the timer!',
        'Grab a drink, open your books and start a session. 🍵',
      ],
    ),
    'tr': NotificationTexts(
      focusDone: 'Odak seansı bitti, mola zamanı! ☕',
      breakDone: 'Mola bitti, odaklanma zamanı!',
      timerFocus: 'Odak zamanı 🍅',
      timerBreak: 'Mola zamanı ☕',
      running: "{n} dk'lık seans. Devam et!",
      channelTimer: 'Çalışan zamanlayıcı',
      channelReminder: 'Günlük ders çalışma hatırlatıcıları',
      reminders: [
        'Ders çalışma zamanı! Başlamak için tek bir Pomodoro yeter. 🍅',
        'Kafen seni bekliyor. Gel, bir seans odaklanalım! ☕',
        'Serini koru: bugün bir odak seansı yapalım mı? 🔥',
        'Bugün küçük bir adım, yarın büyük bir başarı. Zamanlayıcıyı başlat!',
        'Bir içecek al, kitaplarını aç ve seansı başlat. 🍵',
      ],
    ),
    'de': NotificationTexts(
      focusDone: 'Fokus-Sitzung beendet, Zeit für eine Pause! ☕',
      breakDone: 'Pause vorbei, Zeit zum Fokussieren!',
      timerFocus: 'Fokuszeit 🍅',
      timerBreak: 'Pausenzeit ☕',
      running: '{n}-Min-Sitzung. Bleib dran!',
      channelTimer: 'Laufender Timer',
      channelReminder: 'Tägliche Lernerinnerungen',
      reminders: [
        'Zeit zum Lernen! Ein Pomodoro reicht für den Anfang. 🍅',
        'Dein Café wartet. Starte eine Fokus-Sitzung! ☕',
        'Halte deine Serie am Leben: heute eine Sitzung? 🔥',
        'Ein kleiner Schritt heute, ein großer Erfolg morgen. Starte den Timer!',
        'Hol dir ein Getränk, schlag die Bücher auf und starte eine Sitzung. 🍵',
      ],
    ),
    'es': NotificationTexts(
      focusDone: '¡Sesión de enfoque terminada, hora de descansar! ☕',
      breakDone: '¡El descanso terminó, hora de concentrarse!',
      timerFocus: 'Hora de concentrarse 🍅',
      timerBreak: 'Hora del descanso ☕',
      running: 'Sesión de {n} min. ¡Sigue así!',
      channelTimer: 'Temporizador en marcha',
      channelReminder: 'Recordatorios diarios de estudio',
      reminders: [
        '¡Hora de estudiar! Un Pomodoro basta para empezar. 🍅',
        'Tu café te espera. ¡Ven a concentrarte una sesión! ☕',
        'Mantén tu racha: ¿una sesión hoy? 🔥',
        'Un pequeño paso hoy, un gran logro mañana. ¡Inicia el temporizador!',
        'Prepara una bebida, abre tus libros y empieza una sesión. 🍵',
      ],
    ),
    'fr': NotificationTexts(
      focusDone:
          'Session de concentration terminée, c’est l’heure de la pause ! ☕',
      breakDone: 'La pause est finie, au travail !',
      timerFocus: 'Temps de concentration 🍅',
      timerBreak: 'Temps de pause ☕',
      running: 'Session de {n} min. Tiens bon !',
      channelTimer: 'Minuteur en cours',
      channelReminder: 'Rappels d’étude quotidiens',
      reminders: [
        'C’est l’heure d’étudier ! Un seul Pomodoro suffit pour commencer. 🍅',
        'Ton café t’attend. Viens te concentrer le temps d’une session ! ☕',
        'Garde ta série : une session aujourd’hui ? 🔥',
        'Un petit pas aujourd’hui, une grande victoire demain. Lance le minuteur !',
        'Prends une boisson, ouvre tes livres et lance une session. 🍵',
      ],
    ),
    'pt': NotificationTexts(
      focusDone: 'Sessão de foco concluída, hora da pausa! ☕',
      breakDone: 'A pausa acabou, hora de focar!',
      timerFocus: 'Hora de focar 🍅',
      timerBreak: 'Hora da pausa ☕',
      running: 'Sessão de {n} min. Continue assim!',
      channelTimer: 'Temporizador em andamento',
      channelReminder: 'Lembretes diários de estudo',
      reminders: [
        'Hora de estudar! Um Pomodoro basta para começar. 🍅',
        'Seu café está esperando. Venha focar numa sessão! ☕',
        'Mantenha sua sequência: uma sessão hoje? 🔥',
        'Um pequeno passo hoje, uma grande vitória amanhã. Inicie o timer!',
        'Pegue uma bebida, abra os livros e comece uma sessão. 🍵',
      ],
    ),
    'it': NotificationTexts(
      focusDone: 'Sessione di concentrazione finita, è ora della pausa! ☕',
      breakDone: 'La pausa è finita, è ora di concentrarsi!',
      timerFocus: 'Tempo di concentrazione 🍅',
      timerBreak: 'Tempo di pausa ☕',
      running: 'Sessione da {n} min. Tieni duro!',
      channelTimer: 'Timer in corso',
      channelReminder: 'Promemoria di studio giornalieri',
      reminders: [
        'È ora di studiare! Basta un Pomodoro per iniziare. 🍅',
        'Il tuo caffè ti aspetta. Vieni a concentrarti per una sessione! ☕',
        'Mantieni la tua serie: una sessione oggi? 🔥',
        'Un piccolo passo oggi, un grande successo domani. Avvia il timer!',
        'Prendi una bevanda, apri i libri e inizia una sessione. 🍵',
      ],
    ),
    'nl': NotificationTexts(
      focusDone: 'Focussessie klaar, tijd voor een pauze! ☕',
      breakDone: 'De pauze is voorbij, tijd om te focussen!',
      timerFocus: 'Focustijd 🍅',
      timerBreak: 'Pauzetijd ☕',
      running: 'Sessie van {n} min. Hou vol!',
      channelTimer: 'Lopende timer',
      channelReminder: 'Dagelijkse studieherinneringen',
      reminders: [
        'Tijd om te studeren! Eén Pomodoro is genoeg om te beginnen. 🍅',
        'Je café wacht op je. Kom een sessie focussen! ☕',
        'Houd je reeks vol: vandaag één sessie? 🔥',
        'Een kleine stap vandaag, een grote winst morgen. Start de timer!',
        'Pak een drankje, open je boeken en start een sessie. 🍵',
      ],
    ),
    'pl': NotificationTexts(
      focusDone: 'Sesja skupienia zakończona, czas na przerwę! ☕',
      breakDone: 'Przerwa skończona, czas się skupić!',
      timerFocus: 'Czas skupienia 🍅',
      timerBreak: 'Czas przerwy ☕',
      running: 'Sesja {n} min. Tak trzymaj!',
      channelTimer: 'Działający licznik',
      channelReminder: 'Codzienne przypomnienia o nauce',
      reminders: [
        'Czas na naukę! Jedno Pomodoro wystarczy, by zacząć. 🍅',
        'Twoja kawiarnia czeka. Wpadnij na sesję skupienia! ☕',
        'Utrzymaj swoją serię: jedna sesja dziś? 🔥',
        'Mały krok dziś, duży sukces jutro. Włącz licznik!',
        'Weź napój, otwórz książki i zacznij sesję. 🍵',
      ],
    ),
    'ru': NotificationTexts(
      focusDone: 'Сессия фокуса завершена, пора на перерыв! ☕',
      breakDone: 'Перерыв закончился, пора сосредоточиться!',
      timerFocus: 'Время фокуса 🍅',
      timerBreak: 'Время перерыва ☕',
      running: 'Сессия {n} мин. Так держать!',
      channelTimer: 'Работающий таймер',
      channelReminder: 'Ежедневные напоминания об учёбе',
      reminders: [
        'Пора учиться! Для начала достаточно одного помидора. 🍅',
        'Твоё кафе ждёт. Приходи сосредоточиться на одну сессию! ☕',
        'Сохрани серию: одна сессия сегодня? 🔥',
        'Маленький шаг сегодня — большая победа завтра. Запусти таймер!',
        'Налей напиток, открой книги и начни сессию. 🍵',
      ],
    ),
    'uk': NotificationTexts(
      focusDone: 'Сесію фокусу завершено, час на перерву! ☕',
      breakDone: 'Перерва закінчилась, час зосередитися!',
      timerFocus: 'Час фокусу 🍅',
      timerBreak: 'Час перерви ☕',
      running: 'Сесія {n} хв. Так тримати!',
      channelTimer: 'Таймер працює',
      channelReminder: 'Щоденні нагадування про навчання',
      reminders: [
        'Час вчитися! Для початку досить одного помідора. 🍅',
        'Твоя кав’ярня чекає. Заходь зосередитися на одну сесію! ☕',
        'Збережи серію: одна сесія сьогодні? 🔥',
        'Маленький крок сьогодні — велика перемога завтра. Запусти таймер!',
        'Візьми напій, відкрий книжки й почни сесію. 🍵',
      ],
    ),
    'ar': NotificationTexts(
      focusDone: 'انتهت جلسة التركيز، حان وقت الاستراحة! ☕',
      breakDone: 'انتهت الاستراحة، حان وقت التركيز!',
      timerFocus: 'وقت التركيز 🍅',
      timerBreak: 'وقت الاستراحة ☕',
      running: 'جلسة مدتها {n} دقيقة. واصل!',
      channelTimer: 'المؤقت قيد التشغيل',
      channelReminder: 'تذكيرات المذاكرة اليومية',
      reminders: [
        'حان وقت المذاكرة! جلسة بومودورو واحدة تكفي للبدء. 🍅',
        'مقهاك في انتظارك. تعال وركّز في جلسة! ☕',
        'حافظ على سلسلتك: جلسة واحدة اليوم؟ 🔥',
        'خطوة صغيرة اليوم، إنجاز كبير غدًا. ابدأ المؤقت!',
        'حضّر مشروبًا، افتح كتبك وابدأ جلسة. 🍵',
      ],
    ),
    'hi': NotificationTexts(
      focusDone: 'फ़ोकस सेशन पूरा हुआ, ब्रेक का समय! ☕',
      breakDone: 'ब्रेक खत्म, अब फ़ोकस करने का समय!',
      timerFocus: 'फ़ोकस का समय 🍅',
      timerBreak: 'ब्रेक का समय ☕',
      running: '{n} मिनट का सेशन। लगे रहो!',
      channelTimer: 'चल रहा टाइमर',
      channelReminder: 'रोज़ाना पढ़ाई के रिमाइंडर',
      reminders: [
        'पढ़ाई का समय! शुरू करने के लिए एक पोमोडोरो काफ़ी है। 🍅',
        'आपका कैफ़े इंतज़ार कर रहा है। आइए, एक सेशन फ़ोकस करें! ☕',
        'अपनी स्ट्रीक बनाए रखें: आज एक सेशन? 🔥',
        'आज एक छोटा कदम, कल बड़ी जीत। टाइमर शुरू करें!',
        'कोई ड्रिंक लें, किताबें खोलें और सेशन शुरू करें। 🍵',
      ],
    ),
    'id': NotificationTexts(
      focusDone: 'Sesi fokus selesai, saatnya istirahat! ☕',
      breakDone: 'Istirahat selesai, saatnya fokus!',
      timerFocus: 'Waktu fokus 🍅',
      timerBreak: 'Waktu istirahat ☕',
      running: 'Sesi {n} menit. Semangat!',
      channelTimer: 'Timer berjalan',
      channelReminder: 'Pengingat belajar harian',
      reminders: [
        'Waktunya belajar! Satu Pomodoro cukup untuk memulai. 🍅',
        'Kafemu menunggu. Ayo fokus satu sesi! ☕',
        'Jaga streak-mu: satu sesi hari ini? 🔥',
        'Langkah kecil hari ini, kemenangan besar besok. Mulai timer!',
        'Ambil minuman, buka bukumu, dan mulai sesi. 🍵',
      ],
    ),
    'ja': NotificationTexts(
      focusDone: '集中セッション完了、休憩の時間です！☕',
      breakDone: '休憩終了、集中の時間です！',
      timerFocus: '集中タイム 🍅',
      timerBreak: '休憩タイム ☕',
      running: '{n}分のセッション。その調子！',
      channelTimer: '実行中のタイマー',
      channelReminder: '毎日の勉強リマインダー',
      reminders: [
        '勉強の時間です！まずは1ポモドーロから始めましょう。🍅',
        'あなたのカフェが待っています。1セッション集中しませんか？☕',
        '連続記録を守ろう：今日は1セッションどうですか？🔥',
        '今日の小さな一歩が、明日の大きな成果に。タイマーをスタート！',
        '飲み物を用意して、本を開いて、セッションを始めましょう。🍵',
      ],
    ),
    'ko': NotificationTexts(
      focusDone: '집중 세션 완료, 휴식 시간이에요! ☕',
      breakDone: '휴식이 끝났어요, 집중할 시간이에요!',
      timerFocus: '집중 시간 🍅',
      timerBreak: '휴식 시간 ☕',
      running: '{n}분 세션. 힘내세요!',
      channelTimer: '실행 중인 타이머',
      channelReminder: '매일 공부 알림',
      reminders: [
        '공부할 시간이에요! 시작하는 데는 뽀모도로 하나면 충분해요. 🍅',
        '카페가 기다리고 있어요. 한 세션 집중하러 오세요! ☕',
        '연속 기록을 지켜요: 오늘 한 세션 어때요? 🔥',
        '오늘의 작은 걸음이 내일의 큰 성과가 돼요. 타이머를 시작하세요!',
        '음료를 준비하고 책을 펴서 세션을 시작해 보세요. 🍵',
      ],
    ),
    'zh': NotificationTexts(
      focusDone: '专注时段结束，该休息了！☕',
      breakDone: '休息结束，该专注了！',
      timerFocus: '专注时间 🍅',
      timerBreak: '休息时间 ☕',
      running: '{n}分钟的时段。加油！',
      channelTimer: '运行中的计时器',
      channelReminder: '每日学习提醒',
      reminders: [
        '该学习啦！一个番茄钟就足以开始。🍅',
        '你的咖啡馆在等你，来专注一个时段吧！☕',
        '保持连续记录：今天来一个时段吧？🔥',
        '今天迈出一小步，明天收获一大步。开始计时吧！',
        '拿杯饮料，翻开书本，开始一个时段。🍵',
      ],
    ),
    'vi': NotificationTexts(
      focusDone: 'Phiên tập trung kết thúc, đến giờ nghỉ rồi! ☕',
      breakDone: 'Hết giờ nghỉ, đến lúc tập trung!',
      timerFocus: 'Giờ tập trung 🍅',
      timerBreak: 'Giờ nghỉ ☕',
      running: 'Phiên {n} phút. Cố lên!',
      channelTimer: 'Đồng hồ đang chạy',
      channelReminder: 'Nhắc nhở học tập hằng ngày',
      reminders: [
        'Đến giờ học rồi! Chỉ cần một Pomodoro là đủ để bắt đầu. 🍅',
        'Quán cà phê của bạn đang chờ. Hãy tập trung một phiên nhé! ☕',
        'Giữ chuỗi ngày của bạn: hôm nay một phiên nhé? 🔥',
        'Một bước nhỏ hôm nay, thành công lớn ngày mai. Bắt đầu hẹn giờ nào!',
        'Pha đồ uống, mở sách và bắt đầu một phiên. 🍵',
      ],
    ),
  };
}
