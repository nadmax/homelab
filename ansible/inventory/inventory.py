#!/usr/bin/env python3

import json
import os

script_dir = os.path.dirname(os.path.realpath(__file__))
inventory_path = os.path.join(script_dir, "inventory.json")

with open(inventory_path) as f:
    vm_ips = json.load(f)

inventory = {
    'masters': {'hosts': []},
    'workers': {'hosts': []},
    '_meta': {'hostvars': {}}
}

for name, ip in vm_ips.items():
    if name == "controlplane" or name.startswith("master"):
        inventory['masters']['hosts'].append(ip)
    elif name.startswith("node") or name.startswith("worker"):
        inventory['workers']['hosts'].append(ip)

    inventory['_meta']['hostvars'][ip] = {
        'ansible_host': ip,
        'ansible_user': 'user01',
        'hostname': name
    }

print(json.dumps(inventory))