---
description: Analyze and fix code issues, syntax errors, or linting problems detected in the project.
---

1.  **Identify the Problem**
    - specific problems are usually provided in the metadata or user request.
    - Check the provided error logs, lint messages, or user descriptions.
    - Note the file path, line number, and error type (e.g., Syntax Error, ReferenceError).

2.  **Inspect the Code**
    - Use `view_file` to read the code around the reported line numbers.
    - Context is key: Look 10-20 lines before and after to check for unclosed blocks, missing declarations, or scope issues.

3.  **Analyze & Plan**
    - Determine the root cause (e.g., mismatched brackets, typo in variable name, logic flaw).
    - Formulate a fix that resolves the error without breaking surrounding logic.

4.  **Apply the Fix**
    - Use `replace_file_content` (for single blocks) or `multi_replace_file_content` (for multiple changes).
    - Ensure indentation and syntax match the existing code style.

5.  **Verify**
    - If possible, verify the fix (e.g., by re-reading the file to ensure the structure looks correct).
    - If a test or run command is available, use it to confirm the error is gone.
