#!/usr/bin/env nu
# description: List installed and available plugins

use lib/plugin-config.nu *
use lib/plugin-discover.nu
use ../lib/vcs.nu
use ../lib/style.nu

# Format output: sort, select, style
def format-output [] {
    sort-by name | sort-by type -r | sort-by status -r | select name status type version
    | each {|r| match $r.status {
        "installed" => ($r | items {|k, v| [$k (style ok $v)] } | into record)
        _ => $r
    }}
}

# List all plugins
export def main [] {
    let installed = plugin-discover | each { $in | insert status "installed" }
    
    let available = vcs list-repos $GITHUB_ORG
    | where { $in.name not-in ($installed | get name) }
    | each {|r| $r | insert status "available" }
    | insert type {|r| if $r.name in $CORE_PLUGINS { "system" } else { "plugin" } }
    
    $installed 
    | append $available
    | format-output
}
