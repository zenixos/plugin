#!/usr/bin/env nu
# description: Update plugins

use ./lib/plugin-config.nu *
use ./lib/plugin-discover.nu *
use ~/zenix_lib/style.nu

# Update plugins
export def main [
    name?: string  # Plugin name (optional, updates all plugins if omitted)
    --system       # Also update system plugins
] {
    let installed = get-installed
    
    let to_update = if ($name | is-not-empty) {
        $installed | where name == $name
    } else if $system {
        $installed
    } else {
        $installed | where type == "plugin"
    }
    
    if ($to_update | is-empty) {
        print "Nothing to update"
        return
    }
    
    for p in $to_update {
        print $"Updating ($p.name)..."
        cd $p.dir
        
        # Fetch latest
        let fetch = do { jj git fetch } | complete
        if $fetch.exit_code != 0 {
            print $"  (style warn 'Warning'): fetch failed"
            continue
        }
        
        # Rebase to main@origin
        let rebase = do { jj rebase -d main@origin } | complete
        if $rebase.exit_code != 0 {
            print $"  (style warn 'Warning'): rebase failed, may have conflicts"
            continue
        }
        
        print $"  (style ok 'Updated')"
    }
    
    # Run sync
    print "Syncing..."
    do { nu -c $"source ($ENV_FILE); plugin sync" } | complete | ignore
}
