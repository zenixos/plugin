#!/usr/bin/env nu
# description: List installed and available plugins

use lib/plugin-config.nu *
use lib/plugin-discover.nu
use ../lib/vcs.nu
use ../lib/style.nu

# List all plugins
export def main [] {
    let installed = plugin-discover
    
    print (style header "Installed")
    if ($installed | is-empty) {
        print "  (none)"
    } else {
        let data = $installed | each {|p|
            { 
                category: (style category $p.type)
                name: $p.name
                description: (style dim $p.version) 
            }
        }
        style catalog $data
    }
    
    print ""
    print (style header "Available")
    let installed_names = ($installed | get name)
    let exclude = ["zenix" "xenix" "system"]
    let available = vcs list-repos $GITHUB_ORG
        | where {|r| $r.name not-in $installed_names }
        | where {|r| $r.name not-in $exclude }
    
    if ($available | is-empty) {
        print "  (all installed)"
    } else {
        $available | each {|r| print $"  ($r.name)" }
        null
    }
}
