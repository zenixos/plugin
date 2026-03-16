#!/usr/bin/env nu
# description: Install a skill

use lib/skill-config.nu *
use lib/skill-discover.nu
use sync.nu
use ../lib/style.nu
use ../lib/vcs.nu

# Install a skill
export def main [
    name: string  # Skill name, optionally with @version (e.g. browser@v1.0.0)
] {
    let parts = $name | split row "@"
    let skill_name = $parts.0
    let version = $parts | get -o 1 | default ""
    
    if $skill_name in (skill-discover | get name) {
        print $"(style err 'Error'): '($skill_name)' is already installed"
        return
    }
    
    let repo = $"($GITHUB_ORG)/($skill_name)"
    let dir = $PLUGIN_DIR | path join $skill_name
    
    vcs clone $repo $dir --tag $version
    vcs init $dir --track=$PROJECT.track
    sync
    print $"(style ok 'Installed') ($skill_name)"
}
