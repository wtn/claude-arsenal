/**
 * Build Checker Hook - Stop
 *
 * Philosophy: "No Errors Left Behind"
 *
 * Runs builds on modified repos when conversation ends.
 * Reports errors immediately and suggests fixes.
 * Tracks which repos/packages were modified to run targeted builds.
 */

import * as fs from 'fs';
import * as path from 'path';
import { execSync } from 'child_process';

interface EditLog {
  timestamp: string;
  repos: Map<string, Set<string>>;  // repo path -> Set of file paths
  files: {
    path: string;
    repo: string;
    operation: 'create' | 'edit' | 'delete';
  }[];
}

interface BuildConfig {
  command: string;
  errorThreshold: number;
  parseErrors: (output: string) => string[];
}

export async function hook(): Promise<{ reminder?: string }> {
  try {
    const logPath = path.join(process.cwd(), '.claude/tmp/edit-log.json');

    // Check if any files were edited
    if (!fs.existsSync(logPath)) {
      return {};
    }

    const logData = JSON.parse(fs.readFileSync(logPath, 'utf-8'));

    if (!logData.files || logData.files.length === 0) {
      return {};
    }

    // Group files by repository/package
    const repoMap = new Map<string, Set<string>>();
    for (const file of logData.files) {
      const repo = detectRepository(file.path);
      if (!repoMap.has(repo)) {
        repoMap.set(repo, new Set());
      }
      repoMap.get(repo)!.add(file.path);
    }

    const buildResults: string[] = [];
    let totalErrors = 0;

    // Run builds for each affected repository
    for (const [repo, files] of repoMap) {
      const config = getBuildConfig(repo, files);
      if (!config) continue;

      buildResults.push(`\n¨ **${repo}** - Running: ${config.command}`);

      try {
        const output = execSync(config.command, {
          encoding: 'utf-8',
          stdio: 'pipe',
          cwd: repo === 'root' ? process.cwd() : repo
        });

        buildResults.push(` No errors found`);
      } catch (error: any) {
        const output = error.stdout || error.stderr || '';
        const errors = config.parseErrors(output);
        totalErrors += errors.length;

        if (errors.length === 0) {
          buildResults.push(` Build failed but couldn't parse errors`);
        } else if (errors.length <= config.errorThreshold) {
          buildResults.push(` ${errors.length} error(s) found:`);
          errors.forEach(err => buildResults.push(`  ${err}`));
        } else {
          buildResults.push(` ${errors.length} errors found (showing first ${config.errorThreshold})`);
          errors.slice(0, config.errorThreshold).forEach(err => buildResults.push(`  ${err}`));
          buildResults.push(`\n Recommendation: Use auto-error-resolver agent to fix all errors`);
        }
      }
    }

    // Clean up log
    fs.unlinkSync(logPath);

    if (buildResults.length === 0) {
      return {};
    }

    const header = `

‹ BUILD CHECK RESULTS
`;

    const footer = totalErrors > 0
      ? `\n\n\n§ Would you like me to fix these ${totalErrors} error(s)?`
      : `\n\n\n¨ All builds passing! Great work!`;

    return {
      reminder: `${header}\n${buildResults.join('\n')}${footer}`
    };
  } catch (error) {
    console.error('Error in build-checker hook:', error);
    return {};
  }
}

function detectRepository(filePath: string): string {
  // Check if file is in a monorepo package
  const parts = filePath.split(path.sep);

  // Common monorepo patterns
  if (parts.includes('packages') || parts.includes('apps')) {
    const idx = parts.findIndex(p => p === 'packages' || p === 'apps');
    if (idx < parts.length - 1) {
      return parts.slice(0, idx + 2).join(path.sep);
    }
  }

  // Check for backend/frontend split
  if (parts.includes('backend') || parts.includes('frontend')) {
    const idx = parts.findIndex(p => p === 'backend' || p === 'frontend');
    return parts.slice(0, idx + 1).join(path.sep);
  }

  // Default to root
  return 'root';
}

function getBuildConfig(repo: string, files: Set<string>): BuildConfig | null {
  const repoPath = repo === 'root' ? process.cwd() : path.join(process.cwd(), repo);

  // Detect TypeScript projects
  if (Array.from(files).some(f => f.endsWith('.ts') || f.endsWith('.tsx'))) {
    if (fs.existsSync(path.join(repoPath, 'tsconfig.json'))) {
      return {
        command: 'npx tsc --noEmit',
        errorThreshold: 5,
        parseErrors: (output) => {
          const lines = output.split('\n');
          return lines
            .filter(line => line.includes('error TS'))
            .map(line => line.trim());
        }
      };
    }
  }

  // Detect Ruby projects
  if (Array.from(files).some(f => f.endsWith('.rb'))) {
    if (fs.existsSync(path.join(repoPath, 'Gemfile'))) {
      // Use RuboCop if available
      if (commandExists('rubocop')) {
        return {
          command: 'bundle exec rubocop --format simple',
          errorThreshold: 5,
          parseErrors: (output) => {
            const lines = output.split('\n');
            return lines
              .filter(line => line.match(/\.(rb|rake):\d+:\d+:/))
              .slice(0, 10);
          }
        };
      }
      // Fall back to syntax check
      return {
        command: 'ruby -c **/*.rb',
        errorThreshold: 5,
        parseErrors: (output) => output.split('\n').filter(l => l.includes('syntax error'))
      };
    }
  }

  // Detect Python projects
  if (Array.from(files).some(f => f.endsWith('.py'))) {
    if (fs.existsSync(path.join(repoPath, 'setup.py')) ||
        fs.existsSync(path.join(repoPath, 'pyproject.toml'))) {
      if (commandExists('mypy')) {
        return {
          command: 'mypy .',
          errorThreshold: 5,
          parseErrors: (output) => output.split('\n').filter(l => l.includes('error:'))
        };
      }
      if (commandExists('pylint')) {
        return {
          command: 'pylint **/*.py',
          errorThreshold: 5,
          parseErrors: (output) => output.split('\n').filter(l => l.match(/:\d+:\d+:/))
        };
      }
    }
  }

  // Detect JavaScript/Node projects
  if (Array.from(files).some(f => f.endsWith('.js') || f.endsWith('.jsx'))) {
    if (fs.existsSync(path.join(repoPath, 'package.json'))) {
      const pkg = JSON.parse(fs.readFileSync(path.join(repoPath, 'package.json'), 'utf-8'));

      // Use build script if available
      if (pkg.scripts?.build) {
        return {
          command: 'npm run build',
          errorThreshold: 5,
          parseErrors: (output) => {
            const lines = output.split('\n');
            return lines.filter(line =>
              line.includes('ERROR') ||
              line.includes('Error:') ||
              line.includes('SyntaxError')
            );
          }
        };
      }

      // Use ESLint if available
      if (commandExists('eslint')) {
        return {
          command: 'npx eslint .',
          errorThreshold: 5,
          parseErrors: (output) => output.split('\n').filter(l => l.includes('error '))
        };
      }
    }
  }

  return null;
}

function commandExists(command: string): boolean {
  try {
    execSync(`command -v ${command}`, { stdio: 'pipe' });
    return true;
  } catch {
    return false;
  }
}
