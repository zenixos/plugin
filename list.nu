#!/usr/bin/env nu
# description: List installed and available plugins

use lib/plugin-config.nu *
use lib/plugin-discover.nu *
use ../lib/style.nu
use ../lib/vcs.nu

# List installed and available plugins
export def main [] {
    let installed = get-installed
    let available = get-available
    
    print (style header "Installed")
    if ($installed | is-empty) {
        print "  (none)"
    } else {
        let data = $installed | each {|p|
            let ver = (vcs version $p.dir)
            let type_badge = match $p.type {
                "system" => (style category "system")
                _ => (style category "plugin")
            }
            { category: $type_badge, name: $p.name, description: (style dim $ver) }
        }
        style catalog $data
    }
    
    print ""
    print (style header "Available")
    let installed_names = ($installed | get name)
    let exclude = ["zenix" "xenix" "system"]  # Meta repos, not plugins
    let not_installed = ($available 
        | where {|n| $n not-in $installed_names }
        | where {|n| $n not-in $exclude })
    if ($not_installed | is-empty) {
        print "  (all installed)"
    } else {
        $not_installed | each {|n| print $"  ($n)" }
        null
    }
}
