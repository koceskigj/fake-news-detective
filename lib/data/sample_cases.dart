import '../models/case_item.dart';

final List<CaseItem> sampleCases = [
  CaseItem(
    id: 'case_001',
    title: 'City announces new bike lanes on two main streets',
    snippet:
    'The city council approved a plan to add bike lanes and improve crossings. Construction starts next month.',
    sourceName: 'City Bulletin',
    isFake: false,
    explanation:
    'This reads like a standard local update: specific action (approved plan) and a clear timeline. No extreme claims or emotional language.',
    tags: ['local-news', 'specific-details'],
    difficulty: 1,
    domainHint: 'city-bulletin.example',
  ),
  CaseItem(
    id: 'case_002',
    title: 'Doctors HATE this one fruit that “melts fat” overnight!!!',
    snippet:
    'A “secret” trick supposedly burns fat while you sleep. No diet needed. Results in 7 days!',
    sourceName: 'HealthMiracle Blog',
    isFake: true,
    explanation:
    'Strong clickbait (“Doctors HATE”), unrealistic promise (“overnight”), and no credible evidence. This is a classic misleading health claim pattern.',
    tags: ['clickbait', 'unrealistic-claim', 'missing-evidence'],
    difficulty: 1,
    domainHint: 'healthmiracle-blog.example',
  ),
  CaseItem(
    id: 'case_003',
    title: 'School starts a media literacy club for students',
    snippet:
    'Students can learn how to verify sources, spot misinformation, and discuss online safety topics with teachers.',
    sourceName: 'School Newsletter',
    isFake: false,
    explanation:
    'The claim is modest and plausible. It describes an initiative without sensational language and fits typical school programs.',
    tags: ['education', 'plausible'],
    difficulty: 1,
    domainHint: 'school-news.example',
  ),
  CaseItem(
    id: 'case_004',
    title: 'Scientists confirm: phones charge faster if you whisper to them',
    snippet:
    'A “new study” says talking nicely to your phone improves charging speed by 30%. People are shocked!',
    sourceName: 'TechWow Daily',
    isFake: true,
    explanation:
    'This is an absurd claim with vague sourcing (“a new study”) and emotional framing (“shocked”). No details about the researchers or where it was published.',
    tags: ['absurd-claim', 'vague-source'],
    difficulty: 1,
    domainHint: 'techwow.example',
  ),
  CaseItem(
    id: 'case_005',
    title: 'Weather service issues advisory for strong winds tomorrow',
    snippet:
    'Gusts may reach high speeds in the afternoon. Citizens are advised to secure light objects outdoors.',
    sourceName: 'Regional Weather Service',
    isFake: false,
    explanation:
    'This is the kind of cautious, specific language official advisories use: time window, risk, and practical advice.',
    tags: ['official-tone', 'specific-details'],
    difficulty: 1,
    domainHint: 'weather-service.example',
  ),
  CaseItem(
    id: 'case_006',
    title: '“BREAKING”: New law bans homework worldwide starting next week',
    snippet:
    'A viral post claims schools everywhere must stop giving homework immediately. Share to celebrate!',
    sourceName: 'ViralToday',
    isFake: true,
    explanation:
    '“Worldwide” legal claims are extremely unlikely, and the post encourages sharing instead of providing sources. No country, agency, or document is cited.',
    tags: ['sharebait', 'impossible-scope', 'missing-source'],
    difficulty: 2,
    domainHint: 'viraltoday.example',
  ),
  CaseItem(
    id: 'case_007',
    title: 'Museum opens a new exhibit on ancient coins',
    snippet:
    'The exhibit includes coins from multiple eras, interactive displays, and guided tours on weekends.',
    sourceName: 'Museum Announcements',
    isFake: false,
    explanation:
    'Plausible event notice with ordinary details (what, when). No red flags like urgency, outrage, or miracle claims.',
    tags: ['event', 'neutral-tone'],
    difficulty: 1,
    domainHint: 'museum.example',
  ),
  CaseItem(
    id: 'case_008',
    title: 'Celebrity “caught” saying something shocking in a 2-second clip',
    snippet:
    'A short video clip is spreading fast. The post claims it proves a big scandal—but there is no full video context.',
    sourceName: 'ClipStorm',
    isFake: true,
    explanation:
    'This is likely misleading-by-context: very short clips can remove the surrounding meaning. Real verification needs full context and a reliable source.',
    tags: ['context-missing', 'misleading-edit'],
    difficulty: 2,
    domainHint: 'clipstorm.example',
  ),
  CaseItem(
    id: 'case_009',
    title: 'Library extends weekend hours during exam season',
    snippet:
    'The library will stay open later on Fridays and Saturdays to support students. Quiet zones will be expanded.',
    sourceName: 'Community Library',
    isFake: false,
    explanation:
    'Reasonable change and practical details. No emotional manipulation or impossible promises.',
    tags: ['community', 'practical-details'],
    difficulty: 1,
    domainHint: 'library.example',
  ),
  CaseItem(
    id: 'case_010',
    title: '“You won’t believe it”: A single app can hack any phone in 10 seconds',
    snippet:
    'The post claims anyone can hack phones instantly. No proof, but it urges you to download a “protection app.”',
    sourceName: 'SecurityBuzz',
    isFake: true,
    explanation:
    'Fear-based marketing + a push to download something is a red flag. Claims are extreme and unsupported. This looks like scammy persuasion.',
    tags: ['fearbait', 'scam-pattern', 'extreme-claim'],
    difficulty: 2,
    domainHint: 'securitybuzz.example',
  ),
];
