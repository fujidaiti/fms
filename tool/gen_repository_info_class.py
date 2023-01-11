import sys
from datetime import datetime


dart_file = '''
// GENERATED AT {}
// BASED ON THE COMMIT {}

class RepositoryInfo {{
  final String baseUrl;
  final Set<String> availableSymbolNames;
  const RepositoryInfo._({{
    required this.baseUrl,
    required this.availableSymbolNames,
  }});
}}

const repositoryInfo = RepositoryInfo._(
  baseUrl: '{}',
  availableSymbolNames: {{
    {} 
  }},
);
'''

commit_id = sys.stdin.readline().strip()
base_url = sys.stdin.readline().strip()

symbol_names = []
for line in sys.stdin:
  display_name = ' '.join(map(str.capitalize, line.strip().split('_')))
  symbol_names.append("'{}'".format(display_name))

print(dart_file.format(
    datetime.now(), commit_id, base_url, ",\n".join(symbol_names)),
    file=sys.stdout)