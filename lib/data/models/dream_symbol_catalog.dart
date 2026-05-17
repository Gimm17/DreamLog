class DreamSymbolDefinition {
  const DreamSymbolDefinition({
    required this.name,
    required this.icon,
    required this.meaning,
    required this.aliases,
  });

  final String name;
  final String icon;
  final String meaning;
  final List<String> aliases;
}

const dreamSymbolCatalog = [
  DreamSymbolDefinition(
    name: 'Water',
    icon: 'water',
    meaning: 'Emotional depth, memory, and the movement of the subconscious.',
    aliases: ['water', 'air', 'laut', 'ocean', 'sea', 'danau', 'lake'],
  ),
  DreamSymbolDefinition(
    name: 'River',
    icon: 'river',
    meaning:
        'A transition, life flow, or feeling carried from one phase to another.',
    aliases: ['river', 'sungai', 'stream', 'arus'],
  ),
  DreamSymbolDefinition(
    name: 'Rain/Storm',
    icon: 'storm',
    meaning:
        'Emotional release, pressure, cleansing, or unsettled inner weather.',
    aliases: ['rain', 'storm', 'hujan', 'badai', 'petir', 'thunder'],
  ),
  DreamSymbolDefinition(
    name: 'Fire',
    icon: 'fire',
    meaning: 'Intensity, anger, transformation, desire, or urgent change.',
    aliases: ['fire', 'api', 'burn', 'terbakar', 'flame', 'asap'],
  ),
  DreamSymbolDefinition(
    name: 'Moon',
    icon: 'moon',
    meaning: 'Intuition, hidden cycles, and feelings that appear gradually.',
    aliases: ['moon', 'bulan', 'lunar', 'purnama'],
  ),
  DreamSymbolDefinition(
    name: 'Sun/Light',
    icon: 'sun',
    meaning: 'Clarity, hope, visibility, awareness, or a new direction.',
    aliases: ['sun', 'matahari', 'light', 'cahaya', 'lampu', 'terang'],
  ),
  DreamSymbolDefinition(
    name: 'Sky/Clouds',
    icon: 'clouds',
    meaning:
        'Perspective, imagination, uncertainty, or thoughts above daily life.',
    aliases: ['sky', 'cloud', 'awan', 'langit', 'kabut', 'fog'],
  ),
  DreamSymbolDefinition(
    name: 'House',
    icon: 'house',
    meaning:
        'The self, personal safety, family memory, or private emotional space.',
    aliases: ['house', 'home', 'rumah', 'apartemen', 'apartment'],
  ),
  DreamSymbolDefinition(
    name: 'Room',
    icon: 'room',
    meaning:
        'A specific part of the self, privacy, boundaries, or hidden emotions.',
    aliases: ['room', 'kamar', 'ruangan', 'bedroom', 'bathroom'],
  ),
  DreamSymbolDefinition(
    name: 'Door',
    icon: 'door',
    meaning: 'A threshold, choice, opportunity, or transition between states.',
    aliases: ['door', 'pintu', 'gate', 'gerbang', 'portal'],
  ),
  DreamSymbolDefinition(
    name: 'Window',
    icon: 'window',
    meaning:
        'A point of view, observation, longing, or a glimpse into another possibility.',
    aliases: ['window', 'jendela', 'balcony', 'balkon'],
  ),
  DreamSymbolDefinition(
    name: 'Key/Lock',
    icon: 'key',
    meaning:
        'Access, permission, secrets, protection, or something that must be unlocked.',
    aliases: ['key', 'kunci', 'lock', 'locked', 'unlock', 'gembok', 'terkunci'],
  ),
  DreamSymbolDefinition(
    name: 'Road/Path',
    icon: 'path',
    meaning:
        'Direction, progress, uncertainty, or the route toward a personal goal.',
    aliases: [
      'road',
      'path',
      'jalan',
      'jalur',
      'rute',
      'track',
      'lorong',
      'hallway'
    ],
  ),
  DreamSymbolDefinition(
    name: 'Bridge',
    icon: 'bridge',
    meaning:
        'Connection, transition, reconciliation, or crossing into a new phase.',
    aliases: ['bridge', 'jembatan', 'menyeberang', 'crossing'],
  ),
  DreamSymbolDefinition(
    name: 'Stairs',
    icon: 'stairs',
    meaning:
        'Growth, difficulty, ambition, or moving between emotional levels.',
    aliases: ['stairs', 'stair', 'tangga', 'elevator', 'lift', 'eskalator'],
  ),
  DreamSymbolDefinition(
    name: 'City',
    icon: 'city',
    meaning:
        'Social life, ambition, complexity, and the pressure of many possibilities.',
    aliases: ['city', 'kota', 'street', 'jalanan', 'gedung', 'building'],
  ),
  DreamSymbolDefinition(
    name: 'Garden/Flowers',
    icon: 'flower',
    meaning:
        'Growth, tenderness, healing, beauty, or something emotionally blooming.',
    aliases: ['garden', 'flower', 'bunga', 'taman', 'kebun', 'sunflower'],
  ),
  DreamSymbolDefinition(
    name: 'Tree/Forest',
    icon: 'tree',
    meaning: 'Roots, growth, ancestry, instinct, or a larger inner world.',
    aliases: ['tree', 'forest', 'pohon', 'hutan', 'akar', 'root'],
  ),
  DreamSymbolDefinition(
    name: 'Mountain',
    icon: 'mountain',
    meaning:
        'Challenge, perspective, endurance, or a goal that requires effort.',
    aliases: ['mountain', 'gunung', 'hill', 'bukit', 'cliff', 'tebing'],
  ),
  DreamSymbolDefinition(
    name: 'Train/Station',
    icon: 'train',
    meaning:
        'Timing, waiting, departure, missed chances, or structured movement.',
    aliases: ['train', 'station', 'kereta', 'stasiun', 'platform'],
  ),
  DreamSymbolDefinition(
    name: 'Vehicle',
    icon: 'vehicle',
    meaning:
        'Control, momentum, autonomy, and how life direction is being handled.',
    aliases: ['car', 'bus', 'vehicle', 'mobil', 'motor', 'bis', 'bus', 'taxi'],
  ),
  DreamSymbolDefinition(
    name: 'School/Test',
    icon: 'school',
    meaning:
        'Evaluation, learning, pressure, preparation, or fear of being judged.',
    aliases: ['school', 'test', 'exam', 'sekolah', 'ujian', 'kelas', 'class'],
  ),
  DreamSymbolDefinition(
    name: 'Work/Office',
    icon: 'work',
    meaning:
        'Responsibility, performance, career pressure, or public competence.',
    aliases: ['work', 'office', 'kerja', 'kantor', 'boss', 'atasan', 'meeting'],
  ),
  DreamSymbolDefinition(
    name: 'Phone/Message',
    icon: 'message',
    meaning: 'Communication, missed signals, connection, or unsaid feelings.',
    aliases: ['phone', 'message', 'telepon', 'hp', 'chat', 'pesan', 'call'],
  ),
  DreamSymbolDefinition(
    name: 'Mirror/Glass',
    icon: 'glass',
    meaning:
        'Self-image, reflection, fragility, transparency, or distorted perception.',
    aliases: ['mirror', 'glass', 'cermin', 'kaca', 'refleksi', 'reflection'],
  ),
  DreamSymbolDefinition(
    name: 'Clock/Time',
    icon: 'clock',
    meaning: 'Urgency, timing, deadlines, age, or anxiety about change.',
    aliases: ['clock', 'time', 'jam', 'waktu', 'deadline', 'late', 'terlambat'],
  ),
  DreamSymbolDefinition(
    name: 'Stranger',
    icon: 'person',
    meaning:
        'An unknown part of the self, unfamiliar desire, or social uncertainty.',
    aliases: [
      'stranger',
      'unknown person',
      'orang asing',
      'perempuan asing',
      'pria asing'
    ],
  ),
  DreamSymbolDefinition(
    name: 'Family',
    icon: 'family',
    meaning:
        'Attachment, belonging, old patterns, protection, or inherited emotions.',
    aliases: [
      'family',
      'mother',
      'father',
      'sibling',
      'keluarga',
      'ibu',
      'ayah',
      'saudara'
    ],
  ),
  DreamSymbolDefinition(
    name: 'Child/Baby',
    icon: 'child',
    meaning:
        'Vulnerability, new beginnings, innocence, or a young part of the self.',
    aliases: ['child', 'baby', 'anak', 'bayi', 'kid'],
  ),
  DreamSymbolDefinition(
    name: 'Animal',
    icon: 'animal',
    meaning:
        'Instinct, impulse, emotion, protection, or a natural part of the self.',
    aliases: ['animal', 'hewan', 'binatang'],
  ),
  DreamSymbolDefinition(
    name: 'Dog',
    icon: 'dog',
    meaning: 'Loyalty, protection, companionship, or instinctive trust.',
    aliases: ['dog', 'puppy', 'anjing'],
  ),
  DreamSymbolDefinition(
    name: 'Cat',
    icon: 'cat',
    meaning:
        'Independence, intuition, boundaries, or quiet emotional sensitivity.',
    aliases: ['cat', 'kitten', 'kucing'],
  ),
  DreamSymbolDefinition(
    name: 'Bird',
    icon: 'bird',
    meaning:
        'Freedom, distance, messages, perspective, or a wish to rise above.',
    aliases: ['bird', 'burung', 'wings', 'sayap'],
  ),
  DreamSymbolDefinition(
    name: 'Snake',
    icon: 'snake',
    meaning:
        'Fear, transformation, hidden tension, healing, or instinctive alertness.',
    aliases: ['snake', 'ular'],
  ),
  DreamSymbolDefinition(
    name: 'Chase/Running',
    icon: 'running',
    meaning:
        'Avoidance, urgency, fear, pursuit, or pressure that feels close behind.',
    aliases: [
      'chase',
      'running',
      'run',
      'chased',
      'lari',
      'dikejar',
      'mengejar'
    ],
  ),
  DreamSymbolDefinition(
    name: 'Flying',
    icon: 'flying',
    meaning: 'Freedom, ambition, escape, or a wider sense of possibility.',
    aliases: ['flying', 'fly', 'terbang', 'melayang'],
  ),
  DreamSymbolDefinition(
    name: 'Falling',
    icon: 'falling',
    meaning: 'Loss of control, insecurity, surrender, or fear of failure.',
    aliases: ['falling', 'fall', 'jatuh', 'terjatuh'],
  ),
  DreamSymbolDefinition(
    name: 'Lost/Search',
    icon: 'search',
    meaning: 'Confusion, longing, missing direction, or searching for meaning.',
    aliases: ['lost', 'search', 'looking for', 'hilang', 'tersesat', 'mencari'],
  ),
  DreamSymbolDefinition(
    name: 'Money',
    icon: 'money',
    meaning: 'Value, security, self-worth, exchange, or practical concern.',
    aliases: ['money', 'cash', 'uang', 'dompet', 'wallet'],
  ),
  DreamSymbolDefinition(
    name: 'Clothes',
    icon: 'clothes',
    meaning:
        'Identity, presentation, vulnerability, or how the self is shown publicly.',
    aliases: ['clothes', 'shirt', 'dress', 'baju', 'pakaian', 'gaun'],
  ),
  DreamSymbolDefinition(
    name: 'Food',
    icon: 'food',
    meaning:
        'Nourishment, need, comfort, appetite, or emotional replenishment.',
    aliases: ['food', 'eat', 'meal', 'makanan', 'makan', 'minum'],
  ),
  DreamSymbolDefinition(
    name: 'Death',
    icon: 'death',
    meaning:
        'Ending, transformation, grief, release, or a major psychological shift.',
    aliases: ['death', 'dead', 'die', 'mati', 'kematian', 'meninggal'],
  ),
  DreamSymbolDefinition(
    name: 'Party/Celebration',
    icon: 'party',
    meaning:
        'Recognition, belonging, social energy, or a need to celebrate change.',
    aliases: [
      'party',
      'celebration',
      'festival',
      'pesta',
      'perayaan',
      'parade'
    ],
  ),
  DreamSymbolDefinition(
    name: 'Self/Identity',
    icon: 'self',
    meaning:
        'Identity, self-perception, hidden potential, or becoming more integrated.',
    aliases: ['identity', 'self', 'diri', 'nama', 'wajah', 'face'],
  ),
  DreamSymbolDefinition(
    name: 'Memory',
    icon: 'memory',
    meaning:
        'Nostalgia, unfinished emotion, past relationships, or old meaning resurfacing.',
    aliases: [
      'memory',
      'memories',
      'nostalgia',
      'kenangan',
      'masa lalu',
      'dulu'
    ],
  ),
];

const dreamSymbolCatalogPrompt = '''
Allowed symbol taxonomy (return only these exact names):
Water, River, Rain/Storm, Fire, Moon, Sun/Light, Sky/Clouds, House, Room,
Door, Window, Key/Lock, Road/Path, Bridge, Stairs, City, Garden/Flowers,
Tree/Forest, Mountain, Train/Station, Vehicle, School/Test, Work/Office,
Phone/Message, Mirror/Glass, Clock/Time, Stranger, Family, Child/Baby,
Animal, Dog, Cat, Bird, Snake, Chase/Running, Flying, Falling, Lost/Search,
Money, Clothes, Food, Death, Party/Celebration, Self/Identity, Memory.
''';

List<String> normalizeDreamSymbols(
  List<String> rawSymbols,
  String dreamText, {
  int maxSymbols = 5,
}) {
  final result = <String>[];
  for (final raw in rawSymbols) {
    final match = canonicalDreamSymbol(raw);
    if (match != null && !result.contains(match.name)) {
      result.add(match.name);
    }
  }

  if (result.length < 2) {
    for (final match in extractDreamSymbolsFromText(dreamText)) {
      if (!result.contains(match.name)) {
        result.add(match.name);
      }
      if (result.length >= maxSymbols) {
        break;
      }
    }
  }

  if (result.isEmpty) {
    result.add('Self/Identity');
  }

  return result.take(maxSymbols).toList();
}

List<DreamSymbolDefinition> extractDreamSymbolsFromText(String text) {
  final normalized = _normalizeText(text);
  final matches = <DreamSymbolDefinition>[];
  for (final symbol in dreamSymbolCatalog) {
    if (symbol.aliases.any((alias) => _containsPhrase(normalized, alias))) {
      matches.add(symbol);
    }
  }
  return matches;
}

DreamSymbolDefinition? canonicalDreamSymbol(String raw) {
  final normalized = _normalizeText(raw);
  if (normalized.isEmpty) {
    return null;
  }

  for (final symbol in dreamSymbolCatalog) {
    if (_normalizeText(symbol.name) == normalized) {
      return symbol;
    }
  }

  for (final symbol in dreamSymbolCatalog) {
    if (symbol.aliases.any((alias) => _containsPhrase(normalized, alias))) {
      return symbol;
    }
  }

  return null;
}

String dreamSymbolIcon(String symbolName) {
  return canonicalDreamSymbol(symbolName)?.icon ?? 'sparkle';
}

String dreamSymbolMeaning(String symbolName) {
  return canonicalDreamSymbol(symbolName)?.meaning ??
      'A personal symbol from this dream that may become clearer across future entries.';
}

String _normalizeText(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\u00c0-\u024f]+'), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}

bool _containsPhrase(String normalizedText, String rawAlias) {
  final alias = _normalizeText(rawAlias);
  if (alias.isEmpty) {
    return false;
  }
  return ' $normalizedText '.contains(' $alias ');
}
