/**
 * File Edit Tracker Hook - PostToolUse
 *
 * Tracks all file modifications during a session.
 * Creates a log that build-checker can use to run targeted builds.
 * Helps maintain awareness of what's been changed.
 */

import * as fs from 'fs';
import * as path from 'path';

interface EditLog {
  timestamp: string;
  sessionId: string;
  files: FileEdit[];
}

interface FileEdit {
  path: string;
  repo: string;
  operation: 'create' | 'edit' | 'delete';
  timestamp: string;
  tool: string;
}

interface PostToolUseParams {
  toolName: string;
  toolInput: any;
  toolOutput: any;
}

export async function hook(params: PostToolUseParams): Promise<void> {
  try {
    // Only track file modification tools
    const fileTools = ['Write', 'Edit', 'MultiEdit', 'NotebookEdit'];
    if (!fileTools.includes(params.toolName)) {
      return;
    }

    const logPath = path.join(process.cwd(), '.claude/tmp/edit-log.json');

    // Ensure tmp directory exists
    const tmpDir = path.join(process.cwd(), '.claude/tmp');
    if (!fs.existsSync(tmpDir)) {
      fs.mkdirSync(tmpDir, { recursive: true });
    }

    // Load or create log
    let log: EditLog;
    if (fs.existsSync(logPath)) {
      log = JSON.parse(fs.readFileSync(logPath, 'utf-8'));
    } else {
      log = {
        timestamp: new Date().toISOString(),
        sessionId: generateSessionId(),
        files: []
      };
    }

    // Extract file path from tool input
    const filePath = extractFilePath(params.toolName, params.toolInput);
    if (!filePath) return;

    // Determine operation type
    const operation = detectOperation(params.toolName, params.toolInput, params.toolOutput);

    // Detect repository/package
    const repo = detectRepository(filePath);

    // Add to log
    const edit: FileEdit = {
      path: filePath,
      repo: repo,
      operation: operation,
      timestamp: new Date().toISOString(),
      tool: params.toolName
    };

    // Avoid duplicates (same file edited multiple times)
    const existingIndex = log.files.findIndex(f => f.path === filePath);
    if (existingIndex >= 0) {
      // Update existing entry with latest timestamp
      log.files[existingIndex] = edit;
    } else {
      log.files.push(edit);
    }

    // Save log
    fs.writeFileSync(logPath, JSON.stringify(log, null, 2));

    // Optional: Log to console for debugging (can be removed in production)
    if (process.env.DEBUG_HOOKS === 'true') {
      console.log(`[FileTracker] ${operation}: ${filePath}`);
    }
  } catch (error) {
    // Silently fail - we don't want to interrupt Claude's workflow
    if (process.env.DEBUG_HOOKS === 'true') {
      console.error('Error in file-edit-tracker:', error);
    }
  }
}

function extractFilePath(toolName: string, toolInput: any): string | null {
  switch (toolName) {
    case 'Write':
    case 'Edit':
      return toolInput.file_path || toolInput.path || null;
    case 'MultiEdit':
      // MultiEdit might have multiple files - track the first one
      return toolInput.files?.[0]?.path || toolInput.files?.[0]?.file_path || null;
    case 'NotebookEdit':
      return toolInput.notebook_path || null;
    default:
      return null;
  }
}

function detectOperation(toolName: string, toolInput: any, toolOutput: any): 'create' | 'edit' | 'delete' {
  // Check if it's a delete operation
  if (toolInput.operation === 'delete' || toolInput.edit_mode === 'delete') {
    return 'delete';
  }

  // Check if file was created
  if (toolName === 'Write') {
    // If output mentions "created", it's a new file
    if (toolOutput?.message?.includes('created') ||
        toolOutput?.status?.includes('created')) {
      return 'create';
    }
  }

  // Default to edit
  return 'edit';
}

function detectRepository(filePath: string): string {
  // Normalize the path
  const normalizedPath = path.normalize(filePath);
  const parts = normalizedPath.split(path.sep);

  // Check for monorepo patterns
  if (parts.includes('packages') || parts.includes('apps')) {
    const idx = parts.findIndex(p => p === 'packages' || p === 'apps');
    if (idx < parts.length - 1) {
      return parts.slice(0, idx + 2).join(path.sep);
    }
  }

  // Check for common project structure patterns
  const projectIndicators = ['backend', 'frontend', 'api', 'client', 'server', 'services'];
  for (const indicator of projectIndicators) {
    if (parts.includes(indicator)) {
      const idx = parts.findIndex(p => p === indicator);
      return parts.slice(0, idx + 1).join(path.sep);
    }
  }

  // Check if file is in a subdirectory with its own package.json
  let currentPath = path.dirname(normalizedPath);
  while (currentPath !== '/' && currentPath !== '.' && currentPath.length > 0) {
    if (fs.existsSync(path.join(currentPath, 'package.json')) ||
        fs.existsSync(path.join(currentPath, 'Gemfile')) ||
        fs.existsSync(path.join(currentPath, 'pyproject.toml')) ||
        fs.existsSync(path.join(currentPath, 'Cargo.toml'))) {
      return currentPath;
    }
    const parent = path.dirname(currentPath);
    if (parent === currentPath) break;  // Prevent infinite loop
    currentPath = parent;
  }

  // Default to root
  return 'root';
}

function generateSessionId(): string {
  return `session-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
}
