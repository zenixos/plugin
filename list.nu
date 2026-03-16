#!/usr/bin/env nu
# description: List installed and available skills

use lib/skill-config.nu *
use lib/skill-discover.nu
use ../lib/vcs.nu
use ../lib/style.nu

def format-output [skills: list, header: string, empty_msg: string] {
    print (style header $header)
    match ($skills | is-empty) {
        true => { print $"  ($empty_msg)" }
        false => {
            let data = $skills | each {|s|
                { 
                    category: (style category $s.type)
                    name: $s.name
                    description: (style dim ($s.version? | default ""))
                }
            }
            style catalog $data
        }
    }
}

# List all skills
export def main [
    --explore # Show remote available skills
] {
    let installed = skill-discover
    let installed_names = $installed | get name
    let exclude = ["zenix" "xenix" "system"]
    
    print (style header $"System: ($PROJECT.name)")
    print ""
    
    format-output $installed "Installed" "(none)"
    
    if $explore {
        print ""
        let available = vcs list-repos $GITHUB_ORG
            | where {|r| $r.name not-in $installed_names }
            | where {|r| $r.name not-in $exclude }
            | each {|r| $r | insert type (if $r.name in $CORE_SKILLS { "system" } else { "skill" }) }
        
        format-output $available "Available" "(all installed)"
    }
}
