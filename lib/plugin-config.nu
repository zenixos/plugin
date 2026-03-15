use ../../lib/config.nu *

# Re-export system-level config
export const GITHUB_ORG = $GITHUB_ORG
export const CORE_PLUGINS = $CORE_PLUGINS
export const PROJECTS = $PROJECTS
export const ROOT_DIR = $ROOT
export const PLUGIN_DIR = $PLUGIN_DIR
export const ENV_FILE = $ENV_FILE
export const PROJECT = $PROJECT

# Plugin-specific paths
export const SKILL_DIR = (path self | path dirname | path dirname)
export const DATA_DIR = ($SKILL_DIR | path join "data")
