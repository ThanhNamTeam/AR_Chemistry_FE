class ChemElementData {
  final String symbol;
  final String nameVi;
  final String nameEn;
  final double? atomicMass;
  final List<String> valences;
  final String atomicMassPoemLine;
  final String valencePoemLine;
  final String explanation;

  const ChemElementData({
    required this.symbol,
    required this.nameVi,
    required this.nameEn,
    this.atomicMass,
    this.valences = const [],
    this.atomicMassPoemLine = '',
    this.valencePoemLine = '',
    required this.explanation,
  });

  bool get hasAtomicMass => atomicMass != null;
  bool get hasValence => valences.isNotEmpty;
  bool get hasMultipleValences => valences.length > 1;

  String get atomicMassStr {
    if (atomicMass == null) return '';
    if (atomicMass == atomicMass!.truncateToDouble()) {
      return atomicMass!.toInt().toString();
    }
    return '35,5';
  }

  String get valenceStr => valences.join(', ');
}

class ChemistryData {
  static const List<ChemElementData> allElements = [
    // ─── Elements in BOTH poems ───
    ChemElementData(
      symbol: 'H',
      nameVi: 'Hiđro',
      nameEn: 'Hydrogen',
      atomicMass: 1,
      valences: ['I'],
      atomicMassPoemLine: 'Hiđro số 1 khởi đi',
      valencePoemLine: 'Kali, Iốt, Hiđro – hóa trị I',
      explanation: 'Hiđro là nguyên tố nhẹ nhất, số hiệu nguyên tử Z=1, khối lượng nguyên tử bằng 1 đvC, hóa trị I.',
    ),
    ChemElementData(
      symbol: 'Li',
      nameVi: 'Liti',
      nameEn: 'Lithium',
      atomicMass: 7,
      valences: ['I'],
      atomicMassPoemLine: 'Liti số 7 tiếp theo',
      valencePoemLine: 'Liti hóa trị I',
      explanation: 'Liti (Z=3) là kim loại kiềm nhẹ nhất, khối lượng nguyên tử 7 đvC, hóa trị I.',
    ),
    ChemElementData(
      symbol: 'C',
      nameVi: 'Cacbon',
      nameEn: 'Carbon',
      atomicMass: 12,
      valences: ['IV'],
      atomicMassPoemLine: 'Cacbon 12 bước vào',
      valencePoemLine: 'Cacbon, Silic hóa trị IV thôi',
      explanation: 'Cacbon (Z=6) là nền tảng của hóa học hữu cơ, khối lượng nguyên tử 12 đvC, hóa trị IV.',
    ),
    ChemElementData(
      symbol: 'N',
      nameVi: 'Nitơ',
      nameEn: 'Nitrogen',
      atomicMass: 14,
      valences: ['I', 'II', 'III', 'IV'],
      atomicMassPoemLine: 'Nitơ 14 sáng ngời',
      valencePoemLine: 'Nitơ hóa trị I đến IV',
      explanation: 'Nitơ (Z=7) chiếm 78% không khí, khối lượng nguyên tử 14 đvC, có nhiều hóa trị (I–IV).',
    ),
    ChemElementData(
      symbol: 'O',
      nameVi: 'Oxi',
      nameEn: 'Oxygen',
      atomicMass: 16,
      valences: ['II'],
      atomicMassPoemLine: 'Oxi 16 rực rỡ',
      valencePoemLine: 'Oxi hóa trị II',
      explanation: 'Oxi (Z=8) thiết yếu cho hô hấp, khối lượng nguyên tử 16 đvC, hóa trị II.',
    ),
    ChemElementData(
      symbol: 'F',
      nameVi: 'Flo',
      nameEn: 'Fluorine',
      atomicMass: 19,
      valences: ['I'],
      atomicMassPoemLine: 'Flo 19 nhẹ nhàng',
      valencePoemLine: 'Natri với Bạc, Flo hóa trị I',
      explanation: 'Flo (Z=9) là phi kim mạnh nhất, khối lượng nguyên tử 19 đvC, hóa trị I.',
    ),
    ChemElementData(
      symbol: 'Na',
      nameVi: 'Natri',
      nameEn: 'Sodium',
      atomicMass: 23,
      valences: ['I'],
      atomicMassPoemLine: 'Natri 23 xuân đầu',
      valencePoemLine: 'Kali, Iốt, Hiđro, Natri với Bạc – hóa trị I',
      explanation: 'Natri (Z=11) là kim loại kiềm quan trọng trong sinh học, khối lượng nguyên tử 23 đvC, hóa trị I.',
    ),
    ChemElementData(
      symbol: 'Mg',
      nameVi: 'Magie',
      nameEn: 'Magnesium',
      atomicMass: 24,
      valences: ['II'],
      atomicMassPoemLine: 'Magie 24 xây cầu',
      valencePoemLine: 'Bari, Kẽm với Canxi, Magie – hóa trị II',
      explanation: 'Magie (Z=12) là kim loại nhẹ, khối lượng nguyên tử 24 đvC, hóa trị II.',
    ),
    ChemElementData(
      symbol: 'Al',
      nameVi: 'Nhôm',
      nameEn: 'Aluminum',
      atomicMass: 27,
      valences: ['III'],
      atomicMassPoemLine: 'Nhôm 27 vươn cao',
      valencePoemLine: 'Nhôm, Bo hóa trị III này',
      explanation: 'Nhôm (Z=13) là kim loại phổ biến nhất trong vỏ trái đất, khối lượng nguyên tử 27 đvC, hóa trị III.',
    ),
    ChemElementData(
      symbol: 'Si',
      nameVi: 'Silic',
      nameEn: 'Silicon',
      atomicMass: 28,
      valences: ['IV'],
      atomicMassPoemLine: 'Silic 28 dẻo dai',
      valencePoemLine: 'Cacbon, Silic hóa trị IV thôi',
      explanation: 'Silic (Z=14) là chất bán dẫn quan trọng, khối lượng nguyên tử 28 đvC, hóa trị IV.',
    ),
    ChemElementData(
      symbol: 'P',
      nameVi: 'Photpho',
      nameEn: 'Phosphorus',
      atomicMass: 31,
      valences: ['III', 'V'],
      atomicMassPoemLine: 'Photpho 31 thật thà',
      valencePoemLine: 'Photpho hóa trị III và V',
      explanation: 'Photpho (Z=15) quan trọng trong phân bón và sinh học, khối lượng nguyên tử 31 đvC, hóa trị III, V.',
    ),
    ChemElementData(
      symbol: 'S',
      nameVi: 'Lưu huỳnh',
      nameEn: 'Sulfur',
      atomicMass: 32,
      valences: ['II', 'IV', 'VI'],
      atomicMassPoemLine: 'Lưu huỳnh 32 la đà',
      valencePoemLine: 'Lưu huỳnh hóa trị II, IV, VI',
      explanation: 'Lưu huỳnh (Z=16) có nhiều dạng thù hình, khối lượng nguyên tử 32 đvC, hóa trị II, IV, VI.',
    ),
    ChemElementData(
      symbol: 'Cl',
      nameVi: 'Clo',
      nameEn: 'Chlorine',
      atomicMass: 35.5,
      valences: ['I', 'III', 'V', 'VII'],
      atomicMassPoemLine: 'Clo 35,5 long lanh',
      valencePoemLine: 'Clo hóa trị I, III, V, VII',
      explanation: 'Clo (Z=17) là khí màu vàng lục có tính oxi hóa mạnh, khối lượng nguyên tử 35,5 đvC, hóa trị I, III, V, VII.',
    ),
    ChemElementData(
      symbol: 'K',
      nameVi: 'Kali',
      nameEn: 'Potassium',
      atomicMass: 39,
      valences: ['I'],
      atomicMassPoemLine: 'Kali 39 chính danh',
      valencePoemLine: 'Kali, Iốt, Hiđro – hóa trị I',
      explanation: 'Kali (Z=19) là kim loại kiềm quan trọng cho thực vật, khối lượng nguyên tử 39 đvC, hóa trị I.',
    ),
    ChemElementData(
      symbol: 'Ca',
      nameVi: 'Canxi',
      nameEn: 'Calcium',
      atomicMass: 40,
      valences: ['II'],
      atomicMassPoemLine: 'Canxi 40 tươi ngời',
      valencePoemLine: 'Bari, Kẽm với Canxi, Magie – hóa trị II',
      explanation: 'Canxi (Z=20) thiết yếu cho xương và răng, khối lượng nguyên tử 40 đvC, hóa trị II.',
    ),
    ChemElementData(
      symbol: 'Mn',
      nameVi: 'Mangan',
      nameEn: 'Manganese',
      atomicMass: 55,
      valences: ['II', 'IV', 'VII'],
      atomicMassPoemLine: 'Mangan 55 đẹp tươi',
      valencePoemLine: 'Mangan hóa trị II, IV, VII',
      explanation: 'Mangan (Z=25) quan trọng trong luyện thép, khối lượng nguyên tử 55 đvC, hóa trị II, IV, VII.',
    ),
    ChemElementData(
      symbol: 'Fe',
      nameVi: 'Sắt',
      nameEn: 'Iron',
      atomicMass: 56,
      valences: ['II', 'III'],
      atomicMassPoemLine: 'Sắt 56 cứng rắn',
      valencePoemLine: 'Sắt hóa trị II và III',
      explanation: 'Sắt (Z=26) là kim loại phổ biến nhất, khối lượng nguyên tử 56 đvC, hóa trị II, III.',
    ),
    ChemElementData(
      symbol: 'Cu',
      nameVi: 'Đồng',
      nameEn: 'Copper',
      atomicMass: 64,
      valences: ['I', 'II'],
      atomicMassPoemLine: 'Đồng 64 trung dũng',
      valencePoemLine: 'Riêng Đồng, Thủy ngân thêm hóa trị II',
      explanation: 'Đồng (Z=29) dẫn điện tốt, khối lượng nguyên tử 64 đvC, hóa trị I, II.',
    ),
    ChemElementData(
      symbol: 'Zn',
      nameVi: 'Kẽm',
      nameEn: 'Zinc',
      atomicMass: 65,
      valences: ['II'],
      atomicMassPoemLine: 'Kẽm 65 sáng ngời',
      valencePoemLine: 'Bari, Kẽm với Canxi, Magie – hóa trị II',
      explanation: 'Kẽm (Z=30) dùng mạ điện và hợp kim, khối lượng nguyên tử 65 đvC, hóa trị II.',
    ),
    ChemElementData(
      symbol: 'Ag',
      nameVi: 'Bạc',
      nameEn: 'Silver',
      atomicMass: 108,
      valences: ['I'],
      atomicMassPoemLine: 'Bạc 108 sáng lóa',
      valencePoemLine: 'Natri với Bạc, Flo hóa trị I',
      explanation: 'Bạc (Z=47) dẫn điện tốt nhất, khối lượng nguyên tử 108 đvC, hóa trị I.',
    ),
    ChemElementData(
      symbol: 'Sn',
      nameVi: 'Thiếc',
      nameEn: 'Tin',
      atomicMass: 119,
      valences: ['II', 'IV'],
      atomicMassPoemLine: 'Thiếc 119 bền vững',
      valencePoemLine: 'Chì, Thiếc hóa trị II và IV',
      explanation: 'Thiếc (Z=50) dùng mạ hộp thiếc, khối lượng nguyên tử 119 đvC, hóa trị II, IV.',
    ),
    ChemElementData(
      symbol: 'I',
      nameVi: 'Iốt',
      nameEn: 'Iodine',
      atomicMass: 127,
      valences: ['I', 'III', 'V'],
      atomicMassPoemLine: 'Iốt 127 quan trọng',
      valencePoemLine: 'Iốt hóa trị I, III, V',
      explanation: 'Iốt (Z=53) cần thiết cho tuyến giáp, khối lượng nguyên tử 127 đvC, hóa trị I, III, V.',
    ),
    ChemElementData(
      symbol: 'Ba',
      nameVi: 'Bari',
      nameEn: 'Barium',
      atomicMass: 137,
      valences: ['II'],
      atomicMassPoemLine: 'Bari 137 nặng nề',
      valencePoemLine: 'Bari, Kẽm với Canxi, Magie – hóa trị II',
      explanation: 'Bari (Z=56) là kim loại kiềm thổ, khối lượng nguyên tử 137 đvC, hóa trị II.',
    ),
    ChemElementData(
      symbol: 'Hg',
      nameVi: 'Thủy ngân',
      nameEn: 'Mercury',
      atomicMass: 201,
      valences: ['I', 'II'],
      atomicMassPoemLine: 'Thủy ngân 201 lỏng lẻo',
      valencePoemLine: 'Riêng Đồng, Thủy ngân thêm hóa trị II',
      explanation: 'Thủy ngân (Z=80) là kim loại duy nhất ở thể lỏng khi điều kiện thường, khối lượng 201 đvC, hóa trị I, II.',
    ),
    ChemElementData(
      symbol: 'Pb',
      nameVi: 'Chì',
      nameEn: 'Lead',
      atomicMass: 207,
      valences: ['II', 'IV'],
      atomicMassPoemLine: 'Chì 207 nặng nề',
      valencePoemLine: 'Chì, Thiếc hóa trị II và IV',
      explanation: 'Chì (Z=82) dùng trong ắc quy, khối lượng nguyên tử 207 đvC, hóa trị II, IV.',
    ),

    // ─── Elements ONLY in atomic mass poem ───
    ChemElementData(
      symbol: 'Cr',
      nameVi: 'Crom',
      nameEn: 'Chromium',
      atomicMass: 52,
      valences: [],
      atomicMassPoemLine: 'Crom 52 rực rỡ',
      explanation: 'Crom (Z=24) dùng mạ điện và thép không gỉ, khối lượng nguyên tử 52 đvC.',
    ),
    ChemElementData(
      symbol: 'Co',
      nameVi: 'Coban',
      nameEn: 'Cobalt',
      atomicMass: 59,
      valences: [],
      atomicMassPoemLine: 'Coban 59 bền vững',
      explanation: 'Coban (Z=27) dùng làm nam châm và hợp kim cứng, khối lượng nguyên tử 59 đvC.',
    ),
    ChemElementData(
      symbol: 'Br',
      nameVi: 'Brom',
      nameEn: 'Bromine',
      atomicMass: 80,
      valences: [],
      atomicMassPoemLine: 'Brom 80 nhẹ nhàng',
      explanation: 'Brom (Z=35) là halogen ở thể lỏng trong điều kiện thường, khối lượng nguyên tử 80 đvC.',
    ),
    ChemElementData(
      symbol: 'Sr',
      nameVi: 'Stronti',
      nameEn: 'Strontium',
      atomicMass: 88,
      valences: [],
      atomicMassPoemLine: 'Stronti 88 vươn xa',
      explanation: 'Stronti (Z=38) cho ngọn lửa màu đỏ tươi trong pháo hoa, khối lượng nguyên tử 88 đvC.',
    ),
    ChemElementData(
      symbol: 'Cd',
      nameVi: 'Cađimi',
      nameEn: 'Cadmium',
      atomicMass: 112,
      valences: [],
      atomicMassPoemLine: 'Cađimi 112 nhẹ nhàng',
      explanation: 'Cađimi (Z=48) dùng trong pin Ni-Cd, khối lượng nguyên tử 112 đvC.',
    ),
    ChemElementData(
      symbol: 'Pt',
      nameVi: 'Platin',
      nameEn: 'Platinum',
      atomicMass: 195,
      valences: [],
      atomicMassPoemLine: 'Platin 195 quý giá',
      explanation: 'Platin (Z=78) là kim loại quý dùng làm xúc tác, khối lượng nguyên tử 195 đvC.',
    ),
    ChemElementData(
      symbol: 'Au',
      nameVi: 'Vàng',
      nameEn: 'Gold',
      atomicMass: 197,
      valences: [],
      atomicMassPoemLine: 'Vàng 197 rực sáng',
      explanation: 'Vàng (Z=79) là kim loại quý không bị ăn mòn, khối lượng nguyên tử 197 đvC.',
    ),
    ChemElementData(
      symbol: 'Ra',
      nameVi: 'Radi',
      nameEn: 'Radium',
      atomicMass: 226,
      valences: [],
      atomicMassPoemLine: 'Radi 226 phóng xạ',
      explanation: 'Radi (Z=88) là nguyên tố phóng xạ, khối lượng nguyên tử 226 đvC.',
    ),
    ChemElementData(
      symbol: 'Bi',
      nameVi: 'Bitmut',
      nameEn: 'Bismuth',
      atomicMass: 209,
      valences: [],
      atomicMassPoemLine: 'Bitmut 209 cuối bảng',
      explanation: 'Bitmut (Z=83) là kim loại nặng dùng trong dược phẩm, khối lượng nguyên tử 209 đvC.',
    ),

    // ─── Elements ONLY in valence poem ───
    ChemElementData(
      symbol: 'B',
      nameVi: 'Bo',
      nameEn: 'Boron',
      atomicMass: null,
      valences: ['III'],
      valencePoemLine: 'Nhôm, Bo hóa trị III này',
      explanation: 'Bo (Z=5) là á kim, dùng trong thủy tinh và gốm sứ, hóa trị III.',
    ),
  ];

  static List<ChemElementData> get elementsWithAtomicMass =>
      allElements.where((e) => e.hasAtomicMass).toList();

  static List<ChemElementData> get elementsWithValence =>
      allElements.where((e) => e.hasValence).toList();

  static ChemElementData? findBySymbol(String symbol) {
    try {
      return allElements.firstWhere((e) => e.symbol == symbol);
    } catch (_) {
      return null;
    }
  }

  static ChemElementData? findByNameVi(String name) {
    try {
      return allElements.firstWhere((e) => e.nameVi == name);
    } catch (_) {
      return null;
    }
  }

  static const String atomicMassPoem = '''Hiđro số 1 khởi đi
Liti số 7 tiếp theo
Cacbon 12 bước vào
Nitơ 14 sáng ngời
Oxi 16 rực rỡ
Flo 19 nhẹ nhàng
Natri 23 xuân đầu
Magie 24 xây cầu
Nhôm 27 vươn cao
Silic 28 dẻo dai
Photpho 31 thật thà
Lưu huỳnh 32 la đà
Clo 35,5 long lanh
Kali 39 chính danh
Canxi 40 tươi ngời
Crom 52 rực rỡ
Mangan 55 đẹp tươi
Sắt 56 cứng rắn
Coban 59 bền vững
Đồng 64 trung dũng
Kẽm 65 sáng ngời
Brom 80 nhẹ nhàng
Stronti 88 vươn xa
Bạc 108 sáng lóa
Cađimi 112 nhẹ nhàng
Thiếc 119 bền vững
Iốt 127 quan trọng
Bari 137 nặng nề
Platin 195 quý giá
Vàng 197 rực sáng
Thủy ngân 201 lỏng lẻo
Chì 207 nặng nề
Radi 226 phóng xạ
Bitmut 209 cuối bảng''';

  static const String valencePoem = '''Kali, Iốt, Hiđro
Natri với Bạc, Flo – một loài hóa trị I
Riêng Đồng, Thủy ngân thêm hóa trị II (I và II)
Chì, Thiếc hóa trị II và IV
Bari, Kẽm với Canxi, Magie – hóa trị II
Oxi hóa trị II
Nhôm, Bo hóa trị III này
Cacbon, Silic hóa trị IV thôi
Sắt hóa trị II và III
Mangan hóa trị II, IV, VII
Photpho hóa trị III và V
Nitơ hóa trị I đến IV
Lưu huỳnh hóa trị II, IV, VI
Clo hóa trị I, III, V, VII
Iốt hóa trị I, III, V''';
}
