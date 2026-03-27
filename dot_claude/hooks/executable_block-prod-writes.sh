#!/usr/bin/env bash
# PreToolUse hook: prompt before production-modifying commands unless they
# match known read-only subcommand patterns. Exit 0 = allow, JSON ask = prompt.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# If no command found, allow (non-Bash tool or missing field)
if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Skip leading KEY=VALUE env var assignments to find the actual binary
BASE=$(echo "$COMMAND" | awk '{
  for (i = 1; i <= NF; i++) {
    if ($i !~ /^[A-Za-z_][A-Za-z0-9_]*=/) {
      print $i
      exit
    }
  }
}')

# Strip any path prefix to get the binary name
BASE=$(basename "$BASE")

is_readonly() {
  local cmd="$COMMAND"

  case "$BASE" in
    heroku)
      local sub
      sub=$(echo "$cmd" | awk '{print $2}')
      case "$sub" in
        logs|ps|config|info|status|apps|addons:info|pg:info)
          return 0 ;;
      esac
      ;;

    railway)
      local sub
      sub=$(echo "$cmd" | awk '{print $2}')
      case "$sub" in
        logs|status|list|whoami)
          return 0 ;;
      esac
      ;;

    vercel)
      local sub
      sub=$(echo "$cmd" | awk '{print $2}')
      case "$sub" in
        list|ls|inspect|logs|whoami|project|env|dns|certs|domains)
          return 0 ;;
      esac
      ;;

    gcloud)
      # Allow subcommands containing list, describe, get-iam-policy, info
      if echo "$cmd" | grep -qE '\b(list|describe|get-iam-policy|info)\b'; then
        return 0
      fi
      ;;

    gh)
      local sub sub2
      sub=$(echo "$cmd" | awk '{print $2}')
      sub2=$(echo "$cmd" | awk '{print $3}')
      case "$sub" in
        pr)
          case "$sub2" in
            list|view|status|checks|diff|create)
              return 0 ;;
          esac
          ;;
        issue)
          case "$sub2" in
            list|view|status)
              return 0 ;;
          esac
          ;;
        repo)
          [[ "$sub2" == "view" ]] && return 0
          ;;
        api)
          # Allow GET requests (no -X or explicit -X GET)
          if ! echo "$cmd" | grep -qE '\-X\s+(?!GET)'; then
            return 0
          fi
          ;;
        run)
          case "$sub2" in
            list|view)
              return 0 ;;
          esac
          ;;
      esac
      ;;

    terraform)
      local sub
      sub=$(echo "$cmd" | awk '{print $2}')
      case "$sub" in
        plan|show|output|validate|fmt|providers)
          return 0 ;;
        state)
          local sub2
          sub2=$(echo "$cmd" | awk '{print $3}')
          case "$sub2" in
            list|show)
              return 0 ;;
          esac
          ;;
      esac
      ;;

    kubectl)
      local sub
      sub=$(echo "$cmd" | awk '{print $2}')
      case "$sub" in
        get|describe|logs|top|explain|api-resources|api-versions|cluster-info|version)
          return 0 ;;
        config)
          local sub2
          sub2=$(echo "$cmd" | awk '{print $3}')
          case "$sub2" in
            view|current-context)
              return 0 ;;
          esac
          ;;
      esac
      ;;

    az)
      # Allow subcommands containing list, show, get
      if echo "$cmd" | grep -qE '\b(list|show|get)\b'; then
        return 0
      fi
      ;;

    k9s)
      # Always block — interactive TUI
      return 1
      ;;

    ssh)
      # Always block — interactive/modifying
      return 1
      ;;

    *)
      # Not a production command, allow
      jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "allow"}}'
      exit 0
      ;;
  esac

  # Matched a production tool but not a read-only subcommand
  return 1
}

if is_readonly; then
  jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "allow"}}'
  exit 0
else
  jq -n --arg reason "'$COMMAND' may modify production state." '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "ask",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
fi
