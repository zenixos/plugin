#!/usr/bin/env nu
# description: Verify skill commands are exported and documented

use lib/plugin-discover.nu
use ../lib/style.nu

def check-command [cmd_path: string, skill_name: string, scope: list] {
    let name = ($cmd_path | path basename | str replace ".nu" "")
    let found = ($scope | where name == $"($skill_name) ($name)")
    let exported = ($found | is-not-empty)
    let documented = $exported and (($found | first | get description) | is-not-empty)

    let result = match [$exported $documented] {
        [_ true] => { status: "ok", msg: "" }
        [true false] => { status: "warn", msg: "missing doc comment" }
        _ => { status: "error", msg: "not exported" }
    }
    { name: $name, status: $result.status, msg: $result.msg }
}

def verify-skill [skill: record, scope: list] {
    let results = $skill.commands | each {|cmd| check-command $cmd $skill.name $scope }
    let status = match ($results | all {|c| $c.status == "ok" }) { true => "ok", _ => "warn" }
    { name: $skill.name, status: $status, commands: $results }
}

def render-results [reports: list] {
    let data = ($reports | each {|r|
        $r.commands | each {|c|
            let desc = match $c.status {
                "ok" => (style ok "ok")
                "error" => (style err "not exported")
                _ => (style warn ($c | get -o msg | default "warning"))
            }
            { category: $r.name, name: $c.name, description: $desc }
        }
    } | flatten)
    style catalog $data
}

# Verify skill commands are exported and documented
export def main [] {
    let scope = scope commands | where type == 'custom' | select name description
    let skills = plugin-discover | where has_mod
    let reports = $skills | each {|s| verify-skill $s $scope }
    render-results $reports
}
