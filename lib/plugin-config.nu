use ../../../project.nu *

# Re-export project-level config
export const GITHUB_ORG = $GITHUB_ORG
export const CORE_PLUGINS = $CORE_PLUGINS
export const PROJECTS = $PROJECTS

# Plugin paths
export const SKILL_DIR = (path self | path dirname | path dirname)
export const ROOT_DIR = ($SKILL_DIR | path dirname | path dirname)
export const PLUGIN_DIR = ($ROOT_DIR | path join "plugin")
export const DATA_DIR = ($SKILL_DIR | path join "data")
export const ENV_FILE = ($ROOT_DIR | path join "system/lib/env.nu")

# Current project config (based on folder name)
export const PROJECT = ($PROJECTS | get ($ROOT_DIR | path basename))
