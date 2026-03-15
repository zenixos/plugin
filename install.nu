#!/usr/bin/env nu
# description: Install a plugin

use lib/plugin-config.nu *
use list.nu [get-installed]
use sync.nu
use ../lib/style.nu
use ../lib/vcs.nu

# Install a plugin
export def main [
    name: string  # Plugin name, optionally with @version (e.g. browser@v1.0.0)
] {
    let parts = $name | split row "@"
    let plugin_name = $parts.0
    let version = $parts | get -o 1 | default ""
    
    if $plugin_name in (get-installed | get name) {
        print $"(style err 'Error'): '($plugin_name)' is already installed"
        return
    }
    
    let repo = $"($GITHUB_ORG)/($plugin_name)"
    let dir = $PLUGIN_DIR | path join $plugin_name
    
    try {
        vcs clone $repo $dir --tag $version
        vcs init $dir --track=$PROJECT.track
    } catch {|err|
        print $"(style err 'Error'): ($err.msg)"
        return
    }
    
    sync
    print $"(style ok 'Installed') ($plugin_name)"
}
