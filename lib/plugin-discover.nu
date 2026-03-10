# Plugin discovery functions

use plugin-config.nu *

# Get installed plugins from system/ and plugin/ directories
export def get-installed [] {
    let system_dir = ($ZENIX_DIR | path join "system")
    
    # Find directories with .git (actual repos)
    let system = (ls $system_dir 
        | where type == "dir" 
        | where {|d| ($d.name | path join ".git") | path exists }
        | where {|d| ($d.name | path basename) != "lib" }
        | each {|d| { name: ($d.name | path basename), dir: $d.name, type: "system" } })
    
    let plugins = if ($PLUGIN_DIR | path exists) {
        ls $PLUGIN_DIR 
        | where type == "dir"
        | where {|d| ($d.name | path join ".git") | path exists }
        | each {|d| { name: ($d.name | path basename), dir: $d.name, type: "plugin" } }
    } else { [] }
    
    $system | append $plugins
}

# Get current version (commit or tag) for a plugin
export def get-version [dir: string] {
    # Try tag first
    let tag_result = do { ^git -C $dir describe --tags --exact-match } | complete
    if $tag_result.exit_code == 0 {
        return ($tag_result.stdout | str trim)
    }
    
    # Fall back to short commit
    let commit_result = do { ^git -C $dir rev-parse --short HEAD } | complete
    if $commit_result.exit_code == 0 {
        $commit_result.stdout | str trim
    } else {
        "unknown"
    }
}

# Fetch available plugins from GitHub
export def get-available [] {
    let result = do { gh api $"orgs/($GITHUB_ORG)/repos" --paginate --jq '.[].name' } | complete
    if $result.exit_code != 0 { return [] }
    
    $result.stdout | lines | where {|n| $n | is-not-empty }
}
