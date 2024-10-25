"""
Reads ingress rules from existing yaml specs. This is how we keep the ingress yamls in-sync with terraform
"""
import json
import os.path
import sys
from typing import Any, Dict

import yaml

_INGRESS_SERVICES = [
    'admin',
    'dse',
    # TODO: remove these two, they're not needed (?)
    'qp',
    'scholastic',
    'qe',
]


def _convert_ingress_rule_to_tf_string(service_name: str, ingress_rule: Dict[str, Any]) -> str:
    # unfortunately, external data blocks in terraform must produce a map of string -> string, so we have to package
    # each rule into a string that terraform can parse into the real rules
    path = ingress_rule['path'].replace('{{SERVICE_NAME}}', service_name)
    path_type = ingress_rule['pathType']
    service_name = (ingress_rule['backend']['service']['name'].replace('{{REGION}}',
                                                                       '').replace('{{SERVICE_NAME}}', service_name))
    port = ingress_rule['backend']['service']['port']['number']
    return f'{path},{path_type},{service_name},{port}'


def main():
    json_input = sys.stdin.read()
    tf_info = json.loads(json_input)
    ingress_paths_root = tf_info['ingress_paths_root']
    all_rules = []
    for service in _INGRESS_SERVICES:
        with open(os.path.join(ingress_paths_root, f'ingress_{service}.yaml'), encoding='utf-8') as rf:
            rules = yaml.load(rf, Loader=yaml.SafeLoader)
        all_rules.extend([_convert_ingress_rule_to_tf_string(service, rule) for rule in rules])
    # again, we must produce a map[string, string] output, so we have to get a little creative with the indexing
    # so terraform knows which rules should come first
    print(
        json.dumps({
            # Left-pad the rule index so terraform can sort lexicographically
            f'rule_{i:03}': rule_string for i, rule_string in enumerate(all_rules)
        }))


if __name__ == '__main__':
    main()
