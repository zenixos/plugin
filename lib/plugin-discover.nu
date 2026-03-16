# Plugin discovery - single source of truth for finding installed plugins

use plugin-config.nu *
use ../../lib/vcs.nu
use ../../lib/md.nu

# Get description from SKILL.md if exists
def get-description [dir: string] {
    let skill_file = $dir | path join "SKILL.md"
    if ($skill_file | path exists) {
        (md parse $skill_file).meta | get -o description | default ""
    } else { "" }
}

# List command files in a plugin (excludes mod.nu)
def list-commands [dir: string] {
    glob $"($dir)/*.nu"
    | where {|f| ($f | path basename) != "mod.nu" }
    | sort
}

# List all installed plugins with metadata
export def main [] {
    ["system", "plugin"] | each {|type|
        ls ($ROOT_DIR | path join $type)
        | where type == "dir"
        | each {
            let dir = $in.name
            let name = $dir | path basename
            {
                name: $name
                type: $type
                dir: $dir
                version: (vcs version $dir)
                has_mod: ($dir | path join "mod.nu" | path exists)
                description: (get-description $dir)
                commands: (list-commands $dir)
            }
        }
    } | flatten
    | where { $in.version != "unknown" }
}


