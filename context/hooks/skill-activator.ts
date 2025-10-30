/**
 * Skill Activator Hook - UserPromptSubmit
 *
 * Automatically activates relevant skills based on user prompts and file context.
 * Reads skill-rules.json and injects skill activation reminders.
 */

import * as fs from 'fs';
import * as path from 'path';

interface SkillRule {
  type: string;
  enforcement: 'suggest' | 'require' | 'block';
  priority: 'low' | 'medium' | 'high' | 'critical';
  promptTriggers?: {
    keywords?: string[];
    intentPatterns?: string[];
  };
  fileTriggers?: {
    pathPatterns?: string[];
    contentPatterns?: string[];
  };
}

interface SkillRules {
  [skillName: string]: SkillRule;
}

export async function hook(params: {
  userPrompt: string;
  contextFiles?: string[];
}): Promise<{ reminder?: string }> {
  try {
    const skillRulesPath = path.join(process.cwd(), '.claude/config/skill-rules.json');

    if (!fs.existsSync(skillRulesPath)) {
      return {};
    }

    const skillRulesContent = fs.readFileSync(skillRulesPath, 'utf-8');
    const skillRules: SkillRules = JSON.parse(skillRulesContent);

    const matchedSkills = findMatchingSkills(
      skillRules,
      params.userPrompt,
      params.contextFiles || []
    );

    if (matchedSkills.length === 0) {
      return {};
    }

    const reminder = buildSkillReminder(matchedSkills);
    return { reminder };
  } catch (error) {
    console.error('Error in skill-activator hook:', error);
    return {};
  }
}

function findMatchingSkills(
  rules: SkillRules,
  prompt: string,
  contextFiles: string[]
): Array<{ name: string; rule: SkillRule }> {
  const matched: Array<{ name: string; rule: SkillRule; score: number }> = [];

  for (const [skillName, rule] of Object.entries(rules)) {
    if (skillName.startsWith('_')) continue; // Skip meta entries

    let score = 0;

    // Check prompt triggers
    if (rule.promptTriggers?.keywords) {
      const keywordMatches = rule.promptTriggers.keywords.filter(keyword =>
        prompt.toLowerCase().includes(keyword.toLowerCase())
      );
      score += keywordMatches.length * 10;
    }

    if (rule.promptTriggers?.intentPatterns) {
      for (const pattern of rule.promptTriggers.intentPatterns) {
        if (new RegExp(pattern, 'i').test(prompt)) {
          score += 20;
        }
      }
    }

    // Check file triggers
    if (contextFiles.length > 0 && rule.fileTriggers?.pathPatterns) {
      for (const file of contextFiles) {
        for (const pattern of rule.fileTriggers.pathPatterns) {
          if (minimatch(file, pattern)) {
            score += 15;
          }
        }
      }
    }

    if (score > 0) {
      matched.push({ name: skillName, rule, score });
    }
  }

  // Sort by priority and score
  const priorityOrder = { critical: 4, high: 3, medium: 2, low: 1 };
  matched.sort((a, b) => {
    const priorityDiff = priorityOrder[b.rule.priority] - priorityOrder[a.rule.priority];
    if (priorityDiff !== 0) return priorityDiff;
    return b.score - a.score;
  });

  return matched.slice(0, 3); // Top 3 skills
}

function buildSkillReminder(
  skills: Array<{ name: string; rule: SkillRule }>
): string {
  const reminders = skills.map(({ name, rule }) => {
    const prefix = rule.enforcement === 'require' ? '  REQUIRED' : ' Consider';
    const skillPath = `.claude/skills/${name}/SKILL.md`;
    return `${prefix}: Review skill "${name}" (${skillPath})`;
  });

  return `\n---\n Relevant Skills Detected:\n${reminders.join('\n')}\n---\n`;
}

// Simple minimatch implementation for path pattern matching
function minimatch(file: string, pattern: string): boolean {
  const regex = pattern
    .replace(/\*\*/g, '.*')
    .replace(/\*/g, '[^/]*')
    .replace(/\?/g, '.');
  return new RegExp(`^${regex}$`).test(file);
}
