/**
 * Error Handling Reminder Hook - Stop
 *
 * Analyzes edited files for risky patterns and provides gentle reminders
 * about error handling best practices.
 */

import * as fs from 'fs';
import * as path from 'path';

interface EditLog {
  timestamp: string;
  files: {
    path: string;
    operation: 'create' | 'edit' | 'delete';
  }[];
}

interface RiskyPattern {
  pattern: RegExp;
  message: string;
  severity: 'info' | 'warning';
}

const RISKY_PATTERNS: RiskyPattern[] = [
  {
    pattern: /async\s+\w+\([^)]*\)\s*{[^}]*(?!try)[^}]*}/s,
    message: 'Async function without try-catch block',
    severity: 'warning'
  },
  {
    pattern: /\.find\(|\.findOne\(|\.findById\(/,
    message: 'Database query without null/error handling',
    severity: 'info'
  },
  {
    pattern: /JSON\.parse\(/,
    message: 'JSON.parse without try-catch',
    severity: 'warning'
  },
  {
    pattern: /fetch\(|axios\.|http\./,
    message: 'HTTP request - ensure error handling',
    severity: 'info'
  },
  {
    pattern: /raise\s+\w+(?!Error)/,
    message: 'Raising exception - ensure it\'s logged appropriately',
    severity: 'info'
  }
];

export async function hook(): Promise<{ reminder?: string }> {
  try {
    const logPath = path.join(process.cwd(), '.claude/tmp/edit-log.json');

    if (!fs.existsSync(logPath)) {
      return {};
    }

    const log: EditLog = JSON.parse(fs.readFileSync(logPath, 'utf-8'));

    if (log.files.length === 0) {
      return {};
    }

    const findings: { file: string; issues: string[] }[] = [];

    // Analyze each edited file
    for (const file of log.files.filter(f => f.operation !== 'delete')) {
      if (!fs.existsSync(file.path)) continue;

      const content = fs.readFileSync(file.path, 'utf-8');
      const issues: string[] = [];

      for (const { pattern, message, severity } of RISKY_PATTERNS) {
        if (pattern.test(content)) {
          const icon = severity === 'warning' ? ' ' : '„¹  ';
          issues.push(`${icon}${message}`);
        }
      }

      if (issues.length > 0) {
        findings.push({ file: file.path, issues });
      }
    }

    if (findings.length === 0) {
      return {};
    }

    // Build reminder message
    const messages = findings.map(({ file, issues }) => {
      const filename = path.basename(file);
      return `„ ${filename}:\n${issues.map(i => `  ${i}`).join('\n')}`;
    });

    const reminder = `\n---\n Error Handling Review:\n\n${messages.join('\n\n')}\n\n` +
      `These are just reminders - please verify error handling is appropriate.\n---\n`;

    return { reminder };
  } catch (error) {
    console.error('Error in error-reminder hook:', error);
    return {};
  }
}
