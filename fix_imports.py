#!/usr/bin/env python3
"""Convert relative imports to package imports in Flutter lib/ files."""
import os
import re

PROJECT_ROOT = '/Users/macbook/JoonaPay/USDC-Wallet/mobile'
LIB_DIR = os.path.join(PROJECT_ROOT, 'lib')
PACKAGE = 'usdc_wallet'

def fix_file(filepath):
    rel_to_lib = os.path.relpath(os.path.dirname(filepath), LIB_DIR)
    
    with open(filepath, 'r') as f:
        content = f.read()
    
    original = content
    
    def replace_import(m):
        prefix = m.group(1)  # "import '" or "export '" or "part '"
        path = m.group(2)
        suffix = m.group(3)  # everything after the path including "';"
        
        # Skip package: and dart: imports (shouldn't match but safety)
        if path.startswith('package:') or path.startswith('dart:'):
            return m.group(0)
        
        # Resolve the relative path
        if rel_to_lib == '.':
            resolved = os.path.normpath(path)
        else:
            resolved = os.path.normpath(os.path.join(rel_to_lib, path))
        
        return f"{prefix}package:{PACKAGE}/{resolved}{suffix}"
    
    # Match import/export with relative paths (starting with ./ or ../ or just a filename)
    # But NOT package: or dart:
    pattern = r"""((?:import|export|part)\s+['"])(\.\./[^'"]+|\.\/[^'"]+)(['"].*?)"""
    content = re.sub(pattern, replace_import, content)
    
    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        return True
    return False

count = 0
for root, dirs, files in os.walk(LIB_DIR):
    for f in files:
        if f.endswith('.dart'):
            filepath = os.path.join(root, f)
            if fix_file(filepath):
                count += 1

print(f"Fixed {count} files")
