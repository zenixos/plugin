#!/usr/bin/env nu
# description: Update skills

use lib/skill-config.nu *
use lib/skill-discover.nu
use sync.nu
use ../lib/style.nu
use ../lib/vcs.nu

# Update skills
export def main [
    name?: string  # Skill name (optional, updates all skills if omitted)
    --system       # Also update system skills
] {
    skill-discover
    | where { ($name | is-empty) or $in.name == $name }
    | where { $system or $in.type == "skill" }
    | par-each {|s|
        vcs update $s.dir --track=$PROJECT.track
        print $"(style ok 'Updated') ($s.name)"
    }
    
    sync
}
