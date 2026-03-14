#!/usr/bin/env nu
# description: Remove a plugin

use lib/plugin-config.nu *
use lib/plugin-discover.nu *
use ../lib/style.nu

# Remove a plugin
export def main [
    name: string  # Plugin name
] {
    # Check if system plugin
    if $name in $SYSTEM_PLUGINS {
        print $"(style err 'Error'): '($name)' is a system plugin, cannot remove"
        return
    }
    
    let installed = get-installed | where name == $name
    if ($installed | is-empty) {
        print $"(style err 'Error'): '($name)' is not installed"
        return
    }
    
    let plugin = $installed | first
    if $plugin.type == "system" {
        print $"(style err 'Error'): '($name)' is a system plugin, cannot remove"
        return
    }
    
    print $"Removing ($name)..."
    rm -rf $plugin.dir
    
    # Run sync
    print "Syncing..."
    do { nu -c $"source ($ENV_FILE); plugin sync" } | complete | ignore
    
    print $"(style ok 'Removed') ($name)"
}
