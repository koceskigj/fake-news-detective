import '../models/learn_pattern.dart';

final List<LearnPattern> learnPatterns = [
  LearnPattern(
    id: 'pattern_clickbait',
    title: 'Clickbait',
    shortDescription: 'Overdramatic headlines that try to force clicks.',
    explanation:
    'Clickbait uses emotional words and exaggeration to make you click. It often hides the real information or twists it.'
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum ',
    checklist: [
      'Does it say “You won’t believe…” or “Shocking”?',
      'Is it missing details (who, where, when)?',
      'Does it promise instant results?',
      'Does it push you to share quickly?',
    ],
  ),
  LearnPattern(
    id: 'pattern_missing_source',
    title: 'No credible source',
    shortDescription: 'Claims without evidence or trustworthy references.',
    explanation:
    'A trustworthy post usually shows where the info came from. “A study says…” is not enough without details.'
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum ',
    checklist: [
      'Is there a real author or organization?',
      'Are there links to official documents or data?',
      'Is it “someone said” with no names?',
      'Can you confirm it elsewhere?',
    ],
  ),
  LearnPattern(
    id: 'pattern_context',
    title: 'Missing context',
    shortDescription: 'True info used in a misleading way.',
    explanation:
    'Sometimes the words or image are real, but the post removes context (time, place, full quote) to change the meaning.'
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum ',
    checklist: [
      'Is the clip very short?',
      'Could this be old content reposted?',
      'Is the quote incomplete?',
      'Does the post avoid giving background details?',
    ],
  ),
  LearnPattern(
    id: 'pattern_fear',
    title: 'Fear-based persuasion',
    shortDescription: 'Scares you so you react fast.',
    explanation:
    'Fear makes people share without checking. Scams often say your phone, account, or health is in danger to push you into action.'
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum ',
    checklist: [
      'Does it use urgent language (“NOW!”, “WARNING!”)?',
      'Does it threaten consequences if you don’t act?',
      'Does it push a download or link?',
      'Does it avoid evidence?',
    ],
  ),
  LearnPattern(
    id: 'pattern_absurd',
    title: 'Absurd / impossible claims',
    shortDescription: 'Claims that don’t make sense in real life.',
    explanation:
    'If something sounds magical or impossible, it usually is. These posts rely on surprise, not proof.'
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum ',
    checklist: [
      'Is it too good to be true?',
      'Does it break basic logic/science?',
      'Is there no clear source?',
      'Would multiple trusted outlets report this if it were true?',
    ],
  ),
  LearnPattern(
    id: 'pattern_domain',
    title: 'Suspicious domains',
    shortDescription: 'Websites that look official but aren’t.',
    explanation:
    'Fake sites often imitate real ones or use strange domains. Learning to notice small differences can protect you.'
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum '
        'lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum ',
    checklist: [
      'Is the domain weird (extra dashes, misspellings)?',
      'Does it mimic a famous site name?',
      'Is it full of ads/popups?',
      'Is the site missing contact/about info?',
    ],
  ),
];
