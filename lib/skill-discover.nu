# Skill discovery - single source of truth for finding skills

use ~/zenix_lib/md.nu
use plugin-config.nu *

# List all skills with metadata
export def list [] {
    glob $"($ZENIX_DIR)/*/*/SKILL.md"
    | each {|f|
        let dir = ($f | path dirname)
        let name = ($dir | path basename)
        let category = ($dir | path dirname | path basename)
        let has_mod = ($dir | path join "mod.nu" | path exists)
        let meta = (md parse $f).meta
        let desc = ($meta | get -o description | default "")
        { name: $name, dir: $dir, category: $category, has_mod: $has_mod, description: $desc }
    }
    | sort-by category name
}

# Get script path for skill + command, returns null if not found
export def script [skill: string, cmd: string] {
    let dir = list | where name == $skill | get -o 0.dir
    if $dir == null { return null }

    let cmd_script = if $cmd != "" { $dir | path join $"($cmd).nu" } else { null }
    match ($cmd_script | default "" | path exists) {
        true => $cmd_script
        _ => ($dir | path join "mod.nu")
    }
}
