import os
import json
import shutil

base_dir = r"e:\WorkRelated\Roblox\Version1"
src_dir = os.path.join(base_dir, "src")

# Clean up old src directory
if os.path.exists(src_dir):
    shutil.rmtree(src_dir)

# Define new structure
directories = [
    "client/UI",
    "client/Controllers",
    "client/Effects",
    "client/Input",
    "server/Matchmaking",
    "server/AntiCheat",
    "server/Ranked",
    "server/Validation",
    "server/Services",
    "shared/Types",
    "shared/Constants",
    "shared/Networking",
    "shared/Typing",
    "shared/Utilities",
    "replicated"
]

for d in directories:
    os.makedirs(os.path.join(src_dir, d), exist_ok=True)

# default.project.json
rojo_project = {
  "name": "TypeRoyale",
  "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": {
      "Shared": {
        "$path": "src/shared"
      },
      "Replicated": {
        "$path": "src/replicated"
      }
    },
    "ServerScriptService": {
      "Server": {
        "$path": "src/server"
      }
    },
    "StarterPlayer": {
      "$className": "StarterPlayer",
      "StarterPlayerScripts": {
        "Client": {
          "$path": "src/client"
        }
      }
    }
  }
}

with open(os.path.join(base_dir, "default.project.json"), "w") as f:
    json.dump(rojo_project, f, indent=2)

# wally.toml
wally_toml = """[package]
name = "typeroyale/typeroyale"
version = "0.1.0"
registry = "https://github.com/UpliftGames/wally-index"
realm = "shared"

[dependencies]
# Roact = "roblox/roact@1.4.4"
# Promise = "evaera/promise@3.3.0"

[server-dependencies]
"""

with open(os.path.join(base_dir, "wally.toml"), "w") as f:
    f.write(wally_toml)

# selene.toml
selene_toml = """std = "roblox"
"""
with open(os.path.join(base_dir, "selene.toml"), "w") as f:
    f.write(selene_toml)

# .stylua.toml
stylua_toml = """column_width = 120
line_endings = "Windows"
indent_type = "Tabs"
indent_width = 4
quote_style = "AutoPreferDouble"
call_parentheses = "Always"
"""
with open(os.path.join(base_dir, ".stylua.toml"), "w") as f:
    f.write(stylua_toml)

print("Scaffolded new structure successfully.")
