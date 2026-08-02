/// Dữ liệu tĩnh 118 nguyên tố cho bảng tuần hoàn tương tác.
///
/// Nguồn: khối lượng nguyên tử theo IUPAC (làm tròn), độ âm điện thang Pauling,
/// cấu hình electron dạng rút gọn khí hiếm. Giá trị trong ngoặc đơn của khối
/// lượng là số khối đồng vị bền nhất (nguyên tố phóng xạ).
library;

enum ElementCategory {
  alkaliMetal,       // Kim loại kiềm
  alkalineEarth,     // Kim loại kiềm thổ
  transitionMetal,   // Kim loại chuyển tiếp
  postTransition,    // Kim loại yếu (sau chuyển tiếp)
  metalloid,         // Á kim
  nonmetal,          // Phi kim
  halogen,           // Halogen
  nobleGas,          // Khí hiếm
  lanthanide,        // Họ Lantan
  actinide,          // Họ Actini
  unknown,           // Chưa xác định tính chất
}

extension ElementCategoryVi on ElementCategory {
  String get viName => switch (this) {
        ElementCategory.alkaliMetal => 'Kim loại kiềm',
        ElementCategory.alkalineEarth => 'Kim loại kiềm thổ',
        ElementCategory.transitionMetal => 'Kim loại chuyển tiếp',
        ElementCategory.postTransition => 'Kim loại yếu',
        ElementCategory.metalloid => 'Á kim',
        ElementCategory.nonmetal => 'Phi kim',
        ElementCategory.halogen => 'Halogen',
        ElementCategory.nobleGas => 'Khí hiếm',
        ElementCategory.lanthanide => 'Họ Lantan',
        ElementCategory.actinide => 'Họ Actini',
        ElementCategory.unknown => 'Chưa xác định',
      };
}

class PeriodicElement {
  final int number;
  final String symbol;
  final String viName;
  final String mass;
  final ElementCategory category;
  /// Độ âm điện Pauling — null với khí hiếm nhẹ / siêu nặng chưa đo được.
  final double? electronegativity;
  final String electronConfig;
  final int period;
  /// Nhóm 1-18; null với họ Lantan/Actini (xếp hàng riêng dưới bảng).
  final int? group;

  const PeriodicElement(
    this.number,
    this.symbol,
    this.viName,
    this.mass,
    this.category,
    this.electronegativity,
    this.electronConfig,
    this.period,
    this.group,
  );
}

const _ak = ElementCategory.alkaliMetal;
const _ae = ElementCategory.alkalineEarth;
const _tm = ElementCategory.transitionMetal;
const _pt = ElementCategory.postTransition;
const _md = ElementCategory.metalloid;
const _nm = ElementCategory.nonmetal;
const _hl = ElementCategory.halogen;
const _ng = ElementCategory.nobleGas;
const _ln = ElementCategory.lanthanide;
const _ac = ElementCategory.actinide;
const _uk = ElementCategory.unknown;

/// Toàn bộ 118 nguyên tố, thứ tự theo số hiệu nguyên tử.
const List<PeriodicElement> periodicElements = [
  PeriodicElement(1, 'H', 'Hiđro', '1,008', _nm, 2.20, '1s¹', 1, 1),
  PeriodicElement(2, 'He', 'Heli', '4,003', _ng, null, '1s²', 1, 18),
  PeriodicElement(3, 'Li', 'Liti', '6,94', _ak, 0.98, '[He]2s¹', 2, 1),
  PeriodicElement(4, 'Be', 'Beri', '9,012', _ae, 1.57, '[He]2s²', 2, 2),
  PeriodicElement(5, 'B', 'Bo', '10,81', _md, 2.04, '[He]2s²2p¹', 2, 13),
  PeriodicElement(6, 'C', 'Cacbon', '12,011', _nm, 2.55, '[He]2s²2p²', 2, 14),
  PeriodicElement(7, 'N', 'Nitơ', '14,007', _nm, 3.04, '[He]2s²2p³', 2, 15),
  PeriodicElement(8, 'O', 'Oxi', '15,999', _nm, 3.44, '[He]2s²2p⁴', 2, 16),
  PeriodicElement(9, 'F', 'Flo', '18,998', _hl, 3.98, '[He]2s²2p⁵', 2, 17),
  PeriodicElement(10, 'Ne', 'Neon', '20,180', _ng, null, '[He]2s²2p⁶', 2, 18),
  PeriodicElement(11, 'Na', 'Natri', '22,990', _ak, 0.93, '[Ne]3s¹', 3, 1),
  PeriodicElement(12, 'Mg', 'Magie', '24,305', _ae, 1.31, '[Ne]3s²', 3, 2),
  PeriodicElement(13, 'Al', 'Nhôm', '26,982', _pt, 1.61, '[Ne]3s²3p¹', 3, 13),
  PeriodicElement(14, 'Si', 'Silic', '28,085', _md, 1.90, '[Ne]3s²3p²', 3, 14),
  PeriodicElement(15, 'P', 'Photpho', '30,974', _nm, 2.19, '[Ne]3s²3p³', 3, 15),
  PeriodicElement(16, 'S', 'Lưu huỳnh', '32,06', _nm, 2.58, '[Ne]3s²3p⁴', 3, 16),
  PeriodicElement(17, 'Cl', 'Clo', '35,45', _hl, 3.16, '[Ne]3s²3p⁵', 3, 17),
  PeriodicElement(18, 'Ar', 'Argon', '39,95', _ng, null, '[Ne]3s²3p⁶', 3, 18),
  PeriodicElement(19, 'K', 'Kali', '39,098', _ak, 0.82, '[Ar]4s¹', 4, 1),
  PeriodicElement(20, 'Ca', 'Canxi', '40,078', _ae, 1.00, '[Ar]4s²', 4, 2),
  PeriodicElement(21, 'Sc', 'Scanđi', '44,956', _tm, 1.36, '[Ar]3d¹4s²', 4, 3),
  PeriodicElement(22, 'Ti', 'Titan', '47,867', _tm, 1.54, '[Ar]3d²4s²', 4, 4),
  PeriodicElement(23, 'V', 'Vanađi', '50,942', _tm, 1.63, '[Ar]3d³4s²', 4, 5),
  PeriodicElement(24, 'Cr', 'Crom', '51,996', _tm, 1.66, '[Ar]3d⁵4s¹', 4, 6),
  PeriodicElement(25, 'Mn', 'Mangan', '54,938', _tm, 1.55, '[Ar]3d⁵4s²', 4, 7),
  PeriodicElement(26, 'Fe', 'Sắt', '55,845', _tm, 1.83, '[Ar]3d⁶4s²', 4, 8),
  PeriodicElement(27, 'Co', 'Coban', '58,933', _tm, 1.88, '[Ar]3d⁷4s²', 4, 9),
  PeriodicElement(28, 'Ni', 'Niken', '58,693', _tm, 1.91, '[Ar]3d⁸4s²', 4, 10),
  PeriodicElement(29, 'Cu', 'Đồng', '63,546', _tm, 1.90, '[Ar]3d¹⁰4s¹', 4, 11),
  PeriodicElement(30, 'Zn', 'Kẽm', '65,38', _tm, 1.65, '[Ar]3d¹⁰4s²', 4, 12),
  PeriodicElement(31, 'Ga', 'Gali', '69,723', _pt, 1.81, '[Ar]3d¹⁰4s²4p¹', 4, 13),
  PeriodicElement(32, 'Ge', 'Gemani', '72,630', _md, 2.01, '[Ar]3d¹⁰4s²4p²', 4, 14),
  PeriodicElement(33, 'As', 'Asen', '74,922', _md, 2.18, '[Ar]3d¹⁰4s²4p³', 4, 15),
  PeriodicElement(34, 'Se', 'Selen', '78,971', _nm, 2.55, '[Ar]3d¹⁰4s²4p⁴', 4, 16),
  PeriodicElement(35, 'Br', 'Brom', '79,904', _hl, 2.96, '[Ar]3d¹⁰4s²4p⁵', 4, 17),
  PeriodicElement(36, 'Kr', 'Kripton', '83,798', _ng, 3.00, '[Ar]3d¹⁰4s²4p⁶', 4, 18),
  PeriodicElement(37, 'Rb', 'Rubiđi', '85,468', _ak, 0.82, '[Kr]5s¹', 5, 1),
  PeriodicElement(38, 'Sr', 'Stronti', '87,62', _ae, 0.95, '[Kr]5s²', 5, 2),
  PeriodicElement(39, 'Y', 'Ytri', '88,906', _tm, 1.22, '[Kr]4d¹5s²', 5, 3),
  PeriodicElement(40, 'Zr', 'Ziriconi', '91,224', _tm, 1.33, '[Kr]4d²5s²', 5, 4),
  PeriodicElement(41, 'Nb', 'Niobi', '92,906', _tm, 1.60, '[Kr]4d⁴5s¹', 5, 5),
  PeriodicElement(42, 'Mo', 'Molipđen', '95,95', _tm, 2.16, '[Kr]4d⁵5s¹', 5, 6),
  PeriodicElement(43, 'Tc', 'Tecneti', '(98)', _tm, 1.90, '[Kr]4d⁵5s²', 5, 7),
  PeriodicElement(44, 'Ru', 'Rutheni', '101,07', _tm, 2.20, '[Kr]4d⁷5s¹', 5, 8),
  PeriodicElement(45, 'Rh', 'Rođi', '102,91', _tm, 2.28, '[Kr]4d⁸5s¹', 5, 9),
  PeriodicElement(46, 'Pd', 'Palađi', '106,42', _tm, 2.20, '[Kr]4d¹⁰', 5, 10),
  PeriodicElement(47, 'Ag', 'Bạc', '107,87', _tm, 1.93, '[Kr]4d¹⁰5s¹', 5, 11),
  PeriodicElement(48, 'Cd', 'Cađimi', '112,41', _tm, 1.69, '[Kr]4d¹⁰5s²', 5, 12),
  PeriodicElement(49, 'In', 'Inđi', '114,82', _pt, 1.78, '[Kr]4d¹⁰5s²5p¹', 5, 13),
  PeriodicElement(50, 'Sn', 'Thiếc', '118,71', _pt, 1.96, '[Kr]4d¹⁰5s²5p²', 5, 14),
  PeriodicElement(51, 'Sb', 'Antimon', '121,76', _md, 2.05, '[Kr]4d¹⁰5s²5p³', 5, 15),
  PeriodicElement(52, 'Te', 'Telu', '127,60', _md, 2.10, '[Kr]4d¹⁰5s²5p⁴', 5, 16),
  PeriodicElement(53, 'I', 'Iot', '126,90', _hl, 2.66, '[Kr]4d¹⁰5s²5p⁵', 5, 17),
  PeriodicElement(54, 'Xe', 'Xenon', '131,29', _ng, 2.60, '[Kr]4d¹⁰5s²5p⁶', 5, 18),
  PeriodicElement(55, 'Cs', 'Xesi', '132,91', _ak, 0.79, '[Xe]6s¹', 6, 1),
  PeriodicElement(56, 'Ba', 'Bari', '137,33', _ae, 0.89, '[Xe]6s²', 6, 2),
  PeriodicElement(57, 'La', 'Lantan', '138,91', _ln, 1.10, '[Xe]5d¹6s²', 6, null),
  PeriodicElement(58, 'Ce', 'Xeri', '140,12', _ln, 1.12, '[Xe]4f¹5d¹6s²', 6, null),
  PeriodicElement(59, 'Pr', 'Prazeođim', '140,91', _ln, 1.13, '[Xe]4f³6s²', 6, null),
  PeriodicElement(60, 'Nd', 'Neođim', '144,24', _ln, 1.14, '[Xe]4f⁴6s²', 6, null),
  PeriodicElement(61, 'Pm', 'Prometi', '(145)', _ln, 1.13, '[Xe]4f⁵6s²', 6, null),
  PeriodicElement(62, 'Sm', 'Samari', '150,36', _ln, 1.17, '[Xe]4f⁶6s²', 6, null),
  PeriodicElement(63, 'Eu', 'Europi', '151,96', _ln, 1.20, '[Xe]4f⁷6s²', 6, null),
  PeriodicElement(64, 'Gd', 'Gađolini', '157,25', _ln, 1.20, '[Xe]4f⁷5d¹6s²', 6, null),
  PeriodicElement(65, 'Tb', 'Tebi', '158,93', _ln, 1.20, '[Xe]4f⁹6s²', 6, null),
  PeriodicElement(66, 'Dy', 'Đysprosi', '162,50', _ln, 1.22, '[Xe]4f¹⁰6s²', 6, null),
  PeriodicElement(67, 'Ho', 'Honmi', '164,93', _ln, 1.23, '[Xe]4f¹¹6s²', 6, null),
  PeriodicElement(68, 'Er', 'Eribi', '167,26', _ln, 1.24, '[Xe]4f¹²6s²', 6, null),
  PeriodicElement(69, 'Tm', 'Tuli', '168,93', _ln, 1.25, '[Xe]4f¹³6s²', 6, null),
  PeriodicElement(70, 'Yb', 'Ytecbi', '173,05', _ln, 1.10, '[Xe]4f¹⁴6s²', 6, null),
  PeriodicElement(71, 'Lu', 'Lutexi', '174,97', _ln, 1.27, '[Xe]4f¹⁴5d¹6s²', 6, null),
  PeriodicElement(72, 'Hf', 'Hafini', '178,49', _tm, 1.30, '[Xe]4f¹⁴5d²6s²', 6, 4),
  PeriodicElement(73, 'Ta', 'Tantan', '180,95', _tm, 1.50, '[Xe]4f¹⁴5d³6s²', 6, 5),
  PeriodicElement(74, 'W', 'Vonfam', '183,84', _tm, 2.36, '[Xe]4f¹⁴5d⁴6s²', 6, 6),
  PeriodicElement(75, 'Re', 'Reni', '186,21', _tm, 1.90, '[Xe]4f¹⁴5d⁵6s²', 6, 7),
  PeriodicElement(76, 'Os', 'Osmi', '190,23', _tm, 2.20, '[Xe]4f¹⁴5d⁶6s²', 6, 8),
  PeriodicElement(77, 'Ir', 'Iriđi', '192,22', _tm, 2.20, '[Xe]4f¹⁴5d⁷6s²', 6, 9),
  PeriodicElement(78, 'Pt', 'Platin', '195,08', _tm, 2.28, '[Xe]4f¹⁴5d⁹6s¹', 6, 10),
  PeriodicElement(79, 'Au', 'Vàng', '196,97', _tm, 2.54, '[Xe]4f¹⁴5d¹⁰6s¹', 6, 11),
  PeriodicElement(80, 'Hg', 'Thủy ngân', '200,59', _tm, 2.00, '[Xe]4f¹⁴5d¹⁰6s²', 6, 12),
  PeriodicElement(81, 'Tl', 'Tali', '204,38', _pt, 1.62, '[Xe]4f¹⁴5d¹⁰6s²6p¹', 6, 13),
  PeriodicElement(82, 'Pb', 'Chì', '207,2', _pt, 2.33, '[Xe]4f¹⁴5d¹⁰6s²6p²', 6, 14),
  PeriodicElement(83, 'Bi', 'Bitmut', '208,98', _pt, 2.02, '[Xe]4f¹⁴5d¹⁰6s²6p³', 6, 15),
  PeriodicElement(84, 'Po', 'Poloni', '(209)', _pt, 2.00, '[Xe]4f¹⁴5d¹⁰6s²6p⁴', 6, 16),
  PeriodicElement(85, 'At', 'Astatin', '(210)', _hl, 2.20, '[Xe]4f¹⁴5d¹⁰6s²6p⁵', 6, 17),
  PeriodicElement(86, 'Rn', 'Rađon', '(222)', _ng, null, '[Xe]4f¹⁴5d¹⁰6s²6p⁶', 6, 18),
  PeriodicElement(87, 'Fr', 'Franxi', '(223)', _ak, 0.70, '[Rn]7s¹', 7, 1),
  PeriodicElement(88, 'Ra', 'Rađi', '(226)', _ae, 0.90, '[Rn]7s²', 7, 2),
  PeriodicElement(89, 'Ac', 'Actini', '(227)', _ac, 1.10, '[Rn]6d¹7s²', 7, null),
  PeriodicElement(90, 'Th', 'Thori', '232,04', _ac, 1.30, '[Rn]6d²7s²', 7, null),
  PeriodicElement(91, 'Pa', 'Protactini', '231,04', _ac, 1.50, '[Rn]5f²6d¹7s²', 7, null),
  PeriodicElement(92, 'U', 'Urani', '238,03', _ac, 1.38, '[Rn]5f³6d¹7s²', 7, null),
  PeriodicElement(93, 'Np', 'Neptuni', '(237)', _ac, 1.36, '[Rn]5f⁴6d¹7s²', 7, null),
  PeriodicElement(94, 'Pu', 'Plutoni', '(244)', _ac, 1.28, '[Rn]5f⁶7s²', 7, null),
  PeriodicElement(95, 'Am', 'Amerixi', '(243)', _ac, 1.30, '[Rn]5f⁷7s²', 7, null),
  PeriodicElement(96, 'Cm', 'Curi', '(247)', _ac, 1.30, '[Rn]5f⁷6d¹7s²', 7, null),
  PeriodicElement(97, 'Bk', 'Beckeli', '(247)', _ac, 1.30, '[Rn]5f⁹7s²', 7, null),
  PeriodicElement(98, 'Cf', 'Califoni', '(251)', _ac, 1.30, '[Rn]5f¹⁰7s²', 7, null),
  PeriodicElement(99, 'Es', 'Ensteni', '(252)', _ac, 1.30, '[Rn]5f¹¹7s²', 7, null),
  PeriodicElement(100, 'Fm', 'Fecmi', '(257)', _ac, 1.30, '[Rn]5f¹²7s²', 7, null),
  PeriodicElement(101, 'Md', 'Menđelevi', '(258)', _ac, 1.30, '[Rn]5f¹³7s²', 7, null),
  PeriodicElement(102, 'No', 'Nobeli', '(259)', _ac, 1.30, '[Rn]5f¹⁴7s²', 7, null),
  PeriodicElement(103, 'Lr', 'Lorenxi', '(266)', _ac, null, '[Rn]5f¹⁴7s²7p¹', 7, null),
  PeriodicElement(104, 'Rf', 'Rutherfordi', '(267)', _tm, null, '[Rn]5f¹⁴6d²7s²', 7, 4),
  PeriodicElement(105, 'Db', 'Đubni', '(268)', _tm, null, '[Rn]5f¹⁴6d³7s²', 7, 5),
  PeriodicElement(106, 'Sg', 'Seaborgi', '(269)', _tm, null, '[Rn]5f¹⁴6d⁴7s²', 7, 6),
  PeriodicElement(107, 'Bh', 'Bohri', '(270)', _tm, null, '[Rn]5f¹⁴6d⁵7s²', 7, 7),
  PeriodicElement(108, 'Hs', 'Hassi', '(269)', _tm, null, '[Rn]5f¹⁴6d⁶7s²', 7, 8),
  PeriodicElement(109, 'Mt', 'Meitneri', '(278)', _uk, null, '[Rn]5f¹⁴6d⁷7s²', 7, 9),
  PeriodicElement(110, 'Ds', 'Darmstadti', '(281)', _uk, null, '[Rn]5f¹⁴6d⁸7s²', 7, 10),
  PeriodicElement(111, 'Rg', 'Roentgeni', '(282)', _uk, null, '[Rn]5f¹⁴6d⁹7s²', 7, 11),
  PeriodicElement(112, 'Cn', 'Copernixi', '(285)', _tm, null, '[Rn]5f¹⁴6d¹⁰7s²', 7, 12),
  PeriodicElement(113, 'Nh', 'Nihoni', '(286)', _uk, null, '[Rn]5f¹⁴6d¹⁰7s²7p¹', 7, 13),
  PeriodicElement(114, 'Fl', 'Flerovi', '(289)', _uk, null, '[Rn]5f¹⁴6d¹⁰7s²7p²', 7, 14),
  PeriodicElement(115, 'Mc', 'Moscovi', '(290)', _uk, null, '[Rn]5f¹⁴6d¹⁰7s²7p³', 7, 15),
  PeriodicElement(116, 'Lv', 'Livermori', '(293)', _uk, null, '[Rn]5f¹⁴6d¹⁰7s²7p⁴', 7, 16),
  PeriodicElement(117, 'Ts', 'Tennessin', '(294)', _uk, null, '[Rn]5f¹⁴6d¹⁰7s²7p⁵', 7, 17),
  PeriodicElement(118, 'Og', 'Oganesson', '(294)', _uk, null, '[Rn]5f¹⁴6d¹⁰7s²7p⁶', 7, 18),
];

/// Ký hiệu các nguyên tố CÓ thẻ flash card AR trong bộ LABEDU.
/// Giữ đồng bộ với bộ thẻ thật (xem danh sách chất trong shop/landing page).
const Set<String> arElementSymbols = {
  'Al', 'C', 'Ca', 'Cu', 'Fe', 'K', 'Mg', 'Na', 'S', 'Zn',
};
