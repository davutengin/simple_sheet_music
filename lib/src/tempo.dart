import 'package:flutter/material.dart';

/// Nota donanımının ilk ölçüsü üzerinde gösterilecek tempo işareti.
///
/// [bpm] verildiğinde ilgili tempo terimi otomatik tespit edilir.
/// [text] verilirse otomatik tespit yerine bu metin kullanılır.
/// İkisi birden verilebilir.
class Tempo {
  const Tempo({
    this.bpm,
    this.text,
    this.noteValue = TempoNoteValue.quarter,
    this.color = Colors.black87,
  }) : assert(bpm != null || text != null,
            'bpm veya text parametrelerinden en az biri verilmelidir.');

  /// Sayısal tempo değeri – ♩= 120 gibi.
  final int? bpm;

  /// Manuel metin (ör. "Andante", "Yavaş"). Boş bırakılırsa bpm'den otomatik.
  final String? text;

  /// Sayısal değeri temsil eden nota değeri.
  final TempoNoteValue noteValue;

  final Color color;

  // ─── Tüm standart tempo terimleri (BPM üst sınırı → isim) ────────────────
  // Kaynak: Harvard Dictionary of Music, Musipedia ve genel müzik teorisi.
  // MapEntry<int, String>: key = üst sınır BPM (dahil), value = terim adı.
  static const List<MapEntry<int, String>> _terms = [
    MapEntry(24,  'Larghissimo'),    // çok çok yavaş
    MapEntry(40,  'Grave'),          // ağır, ciddi
    MapEntry(45,  'Largo'),          // geniş, yavaş
    MapEntry(52,  'Lento'),          // yavaş
    MapEntry(58,  'Larghetto'),      // Largo'dan biraz hızlı
    MapEntry(66,  'Adagio'),         // sakin, yavaşça
    MapEntry(73,  'Adagietto'),      // Adagio'dan biraz hızlı
    MapEntry(76,  'Grave moderato'),
    MapEntry(83,  'Andante'),        // yürüyüş temposu
    MapEntry(92,  'Andantino'),      // Andante'den biraz hızlı
    MapEntry(100, 'Andante moderato'),
    MapEntry(108, 'Moderato'),       // orta hız
    MapEntry(112, 'Allegro moderato'),
    MapEntry(120, 'Allegretto'),     // biraz canlı
    MapEntry(132, 'Allegro'),        // hızlı, canlı
    MapEntry(140, 'Allegro assai'),  // oldukça hızlı
    MapEntry(156, 'Allegro vivace'),
    MapEntry(168, 'Vivace'),         // canlı ve hızlı
    MapEntry(176, 'Vivacissimo'),    // çok canlı
    MapEntry(184, 'Allegrissimo'),   // çok hızlı
    MapEntry(200, 'Presto'),         // çok hızlı
    // > 200 → Prestissimo
  ];

  /// BPM değerine karşılık gelen tempo terimini döndürür.
  static String termForBpm(int bpm) {
    for (final entry in _terms) {
      if (bpm <= entry.key) return entry.value;
    }
    return 'Prestissimo'; // > 200
  }

  /// Canvas'a yazılacak tam metin.
  /// Örn: "Andante  ♩= 90" veya "Allegro  ♩= 132" veya "Yavaş  ♩= 60"
  String get displayText {
    // text sağlanmamışsa bpm'den otomatik tespit et
    final termText = text ?? (bpm != null ? termForBpm(bpm!) : null);

    if (termText != null && bpm != null) {
      return '$termText  ${noteValue.symbol}= $bpm';
    } else if (termText != null) {
      return termText;
    } else if (bpm != null) {
      return '${noteValue.symbol}= $bpm';
    }
    return '';
  }
}

/// Tempoyu temsil eden nota değeri.
enum TempoNoteValue {
  /// Dörtlük nota (♩).
  quarter('♩'),

  /// Sekizlik nota (♪).
  eighth('♪');

  const TempoNoteValue(this.symbol);

  final String symbol;
}
