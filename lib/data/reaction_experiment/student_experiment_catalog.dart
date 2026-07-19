import '../../../domain/models/reaction_experiment/experiment_quiz_question.dart';
import '../../../domain/models/reaction_experiment/reaction_category.dart';
import '../../../domain/models/reaction_experiment/student_experiment_reaction.dart';

/// Curated experiment catalog until student reaction API is available.
class StudentExperimentCatalog {
  StudentExperimentCatalog._();

  static const grades = [8, 9, 10, 11, 12];

  static List<StudentExperimentReaction> all() => _cache ??= _buildAll();
  static List<StudentExperimentReaction>? _cache;

  static List<StudentExperimentReaction> forGradeAndCategory({
    required int grade,
    required ReactionCategory category,
  }) {
    return all()
        .where((r) => r.grade == grade && r.category == category)
        .toList();
  }

  static StudentExperimentReaction? byCode(String code) {
    try {
      return all().firstWhere((r) => r.code == code);
    } catch (_) {
      return null;
    }
  }

  static List<StudentExperimentReaction> _buildAll() {
    final items = <StudentExperimentReaction>[];
    items.addAll(_seedReactions());
    items.addAll(_generatedReactions());
    return items;
  }

  static List<StudentExperimentReaction> _seedReactions() {
    return [
      _reaction(
        code: 'zn_hcl_g8',
        nameVi: 'Kẽm + Axit clohidric',
        nameEn: 'Zinc + Hydrochloric acid',
        equation: 'Zn + 2HCl → ZnCl₂ + H₂↑',
        grade: 8,
        category: ReactionCategory.metal,
        reactants: ['Zn', 'HCl'],
        scriptVi:
            'Quét thẻ kẽm (Zn) và axit clohidric (HCl). Trong AR, quan sát bọt khí H₂ thoát ra và sự tan dần của kẽm. '
            'Phản ứng thể hiện tính khử của kim loại đứng trước hiđro trong dãy hoạt động kim loại.',
        scriptEn:
            'Scan the zinc (Zn) and hydrochloric acid (HCl) cards. In AR, watch H₂ bubbles form and the zinc dissolve. '
            'This reaction shows a metal reducing H⁺, a core concept in the reactivity series.',
      ),
      _reaction(
        code: 'fe_hcl_g8',
        nameVi: 'Sắt + Axit clohidric',
        nameEn: 'Iron + Hydrochloric acid',
        equation: 'Fe + 2HCl → FeCl₂ + H₂↑',
        grade: 8,
        category: ReactionCategory.metal,
        reactants: ['Fe', 'HCl'],
        scriptVi:
            'Quét thẻ sắt (Fe) và HCl. Theo dõi khí H₂ bám trên bề mặt kim loại và màu dung dịch đổi nhẹ. '
            'Đây là phản ứng kim loại tác dụng axit mạnh tạo muối và khí hiđro.',
        scriptEn:
            'Scan iron (Fe) and HCl cards. Observe H₂ on the metal surface and the slight color change. '
            'A typical metal + strong acid reaction producing salt and hydrogen gas.',
      ),
      _reaction(
        code: 'hcl_naoh_g8',
        nameVi: 'Axit HCl + Bazơ NaOH',
        nameEn: 'HCl + NaOH base',
        equation: 'HCl + NaOH → NaCl + H₂O',
        grade: 8,
        category: ReactionCategory.acid,
        reactants: ['HCl', 'NaOH'],
        scriptVi:
            'Quét thẻ HCl và NaOH. Phản ứng trung hòa tạo muối NaCl và nước — nền tảng để hiểu pH và phản ứng axit-bazơ trong thực hành AR.',
        scriptEn:
            'Scan HCl and NaOH cards. Neutralization forms NaCl and water — a foundation for understanding acid-base reactions in AR practice.',
      ),
      _reaction(
        code: 'naoh_cuso4_g9',
        nameVi: 'NaOH + CuSO₄',
        nameEn: 'NaOH + CuSO₄',
        equation: '2NaOH + CuSO₄ → Cu(OH)₂↓ + Na₂SO₄',
        grade: 9,
        category: ReactionCategory.base,
        reactants: ['NaOH', 'CuSO₄'],
        scriptVi:
            'Quét thẻ NaOH và CuSO₄. Quan sát kết tủa xanh Cu(OH)₂ hình thành trong mô hình 3D — minh họa phản ứng bazơ với muối.',
        scriptEn:
            'Scan NaOH and CuSO₄ cards. Watch blue Cu(OH)₂ precipitate form in 3D — illustrating a base reacting with a salt.',
      ),
      _reaction(
        code: 'bacl2_na2so4_g9',
        nameVi: 'BaCl₂ + Na₂SO₄',
        nameEn: 'BaCl₂ + Na₂SO₄',
        equation: 'BaCl₂ + Na₂SO₄ → BaSO₄↓ + 2NaCl',
        grade: 9,
        category: ReactionCategory.salt,
        reactants: ['BaCl₂', 'Na₂SO₄'],
        scriptVi:
            'Quét hai muối BaCl₂ và Na₂SO₄. Kết tủa BaSO₄ trắng là dấu hiệu điển hình của phản ứng trao đổi ion giữa các muối.',
        scriptEn:
            'Scan BaCl₂ and Na₂SO₄ salt cards. White BaSO₄ precipitate is a classic sign of a double-replacement reaction.',
      ),
    ];
  }

  static List<StudentExperimentReaction> _generatedReactions() {
    final templates = <
        ReactionCategory,
        List<({String nameVi, String nameEn, String eq, List<String> r})>>{
      ReactionCategory.metal: [
        (
          nameVi: 'Nhôm + Axit sunfuric loãng',
          nameEn: 'Aluminum + Dilute sulfuric acid',
          eq: '2Al + 3H₂SO₄ → Al₂(SO₄)₃ + 3H₂↑',
          r: ['Al', 'H₂SO₄'],
        ),
        (
          nameVi: 'Magie + Axit clohidric',
          nameEn: 'Magnesium + Hydrochloric acid',
          eq: 'Mg + 2HCl → MgCl₂ + H₂↑',
          r: ['Mg', 'HCl'],
        ),
        (
          nameVi: 'Đồng + Axit nitric loãng',
          nameEn: 'Copper + Dilute nitric acid',
          eq: '3Cu + 8HNO₃ → 3Cu(NO₃)₂ + 2NO↑ + 4H₂O',
          r: ['Cu', 'HNO₃'],
        ),
      ],
      ReactionCategory.acid: [
        (
          nameVi: 'H₂SO₄ + NaOH',
          nameEn: 'H₂SO₄ + NaOH',
          eq: 'H₂SO₄ + 2NaOH → Na₂SO₄ + 2H₂O',
          r: ['H₂SO₄', 'NaOH'],
        ),
        (
          nameVi: 'HNO₃ + KOH',
          nameEn: 'HNO₃ + KOH',
          eq: 'HNO₃ + KOH → KNO₃ + H₂O',
          r: ['HNO₃', 'KOH'],
        ),
        (
          nameVi: 'CH₃COOH + NaOH',
          nameEn: 'CH₃COOH + NaOH',
          eq: 'CH₃COOH + NaOH → CH₃COONa + H₂O',
          r: ['CH₃COOH', 'NaOH'],
        ),
      ],
      ReactionCategory.base: [
        (
          nameVi: 'Ca(OH)₂ + CO₂',
          nameEn: 'Ca(OH)₂ + CO₂',
          eq: 'Ca(OH)₂ + CO₂ → CaCO₃↓ + H₂O',
          r: ['Ca(OH)₂', 'CO₂'],
        ),
        (
          nameVi: 'NaOH + FeCl₃',
          nameEn: 'NaOH + FeCl₃',
          eq: '3NaOH + FeCl₃ → Fe(OH)₃↓ + 3NaCl',
          r: ['NaOH', 'FeCl₃'],
        ),
        (
          nameVi: 'KOH + HCl',
          nameEn: 'KOH + HCl',
          eq: 'KOH + HCl → KCl + H₂O',
          r: ['KOH', 'HCl'],
        ),
      ],
      ReactionCategory.salt: [
        (
          nameVi: 'AgNO₃ + NaCl',
          nameEn: 'AgNO₃ + NaCl',
          eq: 'AgNO₃ + NaCl → AgCl↓ + NaNO₃',
          r: ['AgNO₃', 'NaCl'],
        ),
        (
          nameVi: 'Pb(NO₃)₂ + KI',
          nameEn: 'Pb(NO₃)₂ + KI',
          eq: 'Pb(NO₃)₂ + 2KI → PbI₂↓ + 2KNO₃',
          r: ['Pb(NO₃)₂', 'KI'],
        ),
        (
          nameVi: 'Na₂CO₃ + CaCl₂',
          nameEn: 'Na₂CO₃ + CaCl₂',
          eq: 'Na₂CO₃ + CaCl₂ → CaCO₃↓ + 2NaCl',
          r: ['Na₂CO₃', 'CaCl₂'],
        ),
      ],
    };

    final out = <StudentExperimentReaction>[];
    for (final grade in grades) {
      for (final category in ReactionCategory.values) {
        final list = templates[category]!;
        for (var i = 0; i < list.length; i++) {
          final t = list[i];
          final code = '${category.name}_g${grade}_${i + 1}'.toLowerCase();
          if (out.any((r) => r.code == code) ||
              _seedReactions().any((r) => r.code == code)) {
            continue;
          }
          out.add(
            _reaction(
              code: code,
              nameVi: t.nameVi,
              nameEn: t.nameEn,
              equation: t.eq,
              grade: grade,
              category: category,
              reactants: t.r,
              scriptVi:
                  'Thí nghiệm AR lớp $grade — ${t.nameVi}. Quét đúng hai thẻ ${t.r.join(' và ')} '
                  'để quan sát mô hình phản ứng 3D, hiểu cách các chất tương tác theo nhóm ${category.name}.',
              scriptEn:
                  'Grade $grade AR experiment — ${t.nameEn}. Scan the correct ${t.r.join(' and ')} flash cards '
                  'to view the 3D reaction model and see how substances interact in the ${category.name} category.',
            ),
          );
        }
      }
    }
    return out;
  }

  static StudentExperimentReaction _reaction({
    required String code,
    required String nameVi,
    required String nameEn,
    required String equation,
    required int grade,
    required ReactionCategory category,
    required List<String> reactants,
    required String scriptVi,
    required String scriptEn,
  }) {
    return StudentExperimentReaction(
      code: code,
      nameVi: nameVi,
      nameEn: nameEn,
      equation: equation,
      grade: grade,
      category: category,
      reactantLabels: reactants,
      scriptVi: scriptVi,
      scriptEn: scriptEn,
      questions: _defaultQuestions(nameVi, nameEn, reactants),
    );
  }

  static List<ExperimentQuizQuestion> _defaultQuestions(
    String reactionNameVi,
    String reactionNameEn,
    List<String> reactants,
  ) {
    final r1 = reactants.isNotEmpty ? reactants.first : 'A';
    final r2 = reactants.length > 1 ? reactants[1] : 'B';
    return [
      ExperimentQuizQuestion(
        id: 'q1',
        questionTextVi:
            'Để quan sát phản ứng "$reactionNameVi" trong AR, cần quét bao nhiêu thẻ flash card?',
        questionTextEn:
            'To observe the "$reactionNameEn" reaction in AR, how many flash cards must you scan?',
        optionsVi: const ['1 thẻ', '2 thẻ', '3 thẻ', '4 thẻ'],
        optionsEn: const ['1 card', '2 cards', '3 cards', '4 cards'],
        correctIndex: 1,
        explanationVi:
            'Mỗi phản ứng cần đúng 2 chất/reactant — quét 2 thẻ tương ứng trước khi bấm Phản ứng.',
        explanationEn:
            'Each reaction needs exactly 2 reactants — scan both matching cards before tapping Reaction.',
      ),
      ExperimentQuizQuestion(
        id: 'q2',
        questionTextVi: 'Hai chất cần quét cho phản ứng này là?',
        questionTextEn: 'Which two substances must be scanned for this reaction?',
        optionsVi: [
          '$r1 và $r2',
          '$r2 và $r1 (khác loại)',
          'Chỉ $r1',
          'Chỉ $r2',
        ],
        optionsEn: [
          '$r1 and $r2',
          '$r2 and $r1 (different type)',
          'Only $r1',
          'Only $r2',
        ],
        correctIndex: 0,
        explanationVi: 'Đúng cặp reactant: $r1 và $r2 như trong thí nghiệm AR.',
        explanationEn:
            'The correct reactant pair is $r1 and $r2 as in the AR experiment.',
      ),
      ExperimentQuizQuestion(
        id: 'q3',
        questionTextVi: 'Mục tiêu chính của thí nghiệm AR này là gì?',
        questionTextEn: 'What is the main goal of this AR experiment?',
        optionsVi: const [
          'Học thuộc công thức không cần quan sát',
          'Hình dung cấu trúc/phản ứng 3D qua flash card',
          'Làm bài trắc nghiệm không liên quan AR',
          'Chỉ xem video lý thuyết',
        ],
        optionsEn: const [
          'Memorize formulas without observing',
          'Visualize 3D structure/reactions via flash cards',
          'Take a quiz unrelated to AR',
          'Watch theory videos only',
        ],
        correctIndex: 1,
        explanationVi:
            'Quiz bổ trợ AR: giúp bạn liên hệ quan sát 3D với hiểu biết về phản ứng.',
        explanationEn:
            'The quiz supports AR by linking your 3D observations to reaction understanding.',
      ),
      ExperimentQuizQuestion(
        id: 'q4',
        questionTextVi: 'Đồng hồ 7 phút bắt đầu khi nào?',
        questionTextEn: 'When does the 7-minute timer start?',
        optionsVi: const [
          'Khi mở app',
          'Khi vào danh sách phản ứng',
          'Sau khi quét đủ 2 thẻ và bấm Phản ứng thành công',
          'Khi bấm Nộp bài',
        ],
        optionsEn: const [
          'When opening the app',
          'When entering the reaction list',
          'After scanning 2 cards and starting Reaction successfully',
          'When tapping Submit',
        ],
        correctIndex: 2,
        explanationVi:
            'Thời gian chỉ tính từ lúc phản ứng AR chạy thành công, không tính lúc quét thử.',
        explanationEn:
            'Time counts only after the AR reaction runs successfully, not while scanning.',
      ),
      ExperimentQuizQuestion(
        id: 'q5',
        questionTextVi:
            'Sau khi hoàn thành AR lần đầu (có dấu tick), bạn được làm gì tiếp?',
        questionTextEn:
            'After completing AR the first time (check mark), what can you do next?',
        optionsVi: const [
          'Thoát app ngay',
          'Đọc script mô tả và làm 5 câu quiz trong thời gian còn lại',
          'Chỉ quét lại AR không làm quiz',
          'Chờ hết 7 phút mới làm quiz',
        ],
        optionsEn: const [
          'Exit the app immediately',
          'Read the script and answer 5 quiz questions in remaining time',
          'Scan AR again without the quiz',
          'Wait 7 minutes before starting the quiz',
        ],
        correctIndex: 1,
        explanationVi:
            'Script và quiz mở sau khi hoàn thành bước AR; làm trong thời gian còn lại của 7 phút.',
        explanationEn:
            'The script and quiz unlock after AR; complete them within the remaining 7 minutes.',
      ),
    ];
  }
}
