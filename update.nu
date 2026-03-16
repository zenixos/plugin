#!/usr/bin/env nu
# description: Update plugins

use lib/plugin-config.nu *
use lib/plugin-discover.nu
use sync.nu
use ../lib/style.nu
use ../lib/vcs.nu

# Update plugins
export def main [
    name?: string  # Plugin name (optional, updates all plugins if omitted)
    --system       # Also update system plugins
] {
    plugin-discover
    | where { ($name | is-empty) or $in.name == $name }
    | where { $system or $in.type == "plugin" }
    | par-each {|p|
        vcs update $p.dir --track=$PROJECT.track
        print $"(style ok 'Updated') ($p.name)"
    }
    
    sync
}
