#!/usr/bin/env nu
# description: Remove a plugin

use lib/plugin-config.nu *
use list.nu [get-installed]
use sync.nu
use ../lib/style.nu

# Remove a plugin
export def main [
    name: string  # Plugin name
] {
    let plugin = get-installed | where name == $name | first | default null
    
    if $plugin == null {
        print $"(style err 'Error'): '($name)' is not installed"
        return
    }
    
    cd $ROOT_DIR
    rm -rf $plugin.dir
    sync
    print $"(style ok 'Removed') ($name)"
}
