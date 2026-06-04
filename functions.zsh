imageCleanup() {
  local input="$1"
  local output="$2"

  if [[ -z "$input" || -z "$output" ]]; then
    echo "Usage: imageCleanup <input> <output>"
    return 1
  fi

  # Cleaner, non-deprecated pipeline
  magick "$input" \
    -colorspace Gray \
    -resize 200% \
    -level 10%,90% \
    "$output"
}

ocrf() {
  local input="$1"
  local lang="${2:-eng}"
  local mode="$3"   # "file" or "stdout"

  if [[ -z "$input" ]]; then
    echo "Usage: ocr <image> [lang] [file|stdout]"
    return 1
  fi

  case "$mode" in
    ""|"stdout")
      # Output text directly to terminal
      tesseract "$input" stdout -l "$lang"
      ;;
    file)
      # Output to <input>.txt
      local base="${input%.*}"
      tesseract "$input" "$base" -l "$lang"
      echo "Saved: ${base}.txt"
      ;;
    *)
      echo "Invalid mode. Use 'file' or 'stdout'."
      return 1
      ;;
  esac
}

list-agents() {
    local selected path
    selected=$(git worktree list | fzf) || return
    path="${selected%% *}"
    [[ -d "$path" ]] && cd "$path"
}

close-agent() {
    local git_dir common_dir
    git_dir=$(git rev-parse --git-dir 2>/dev/null) || { echo "Not in a git repository"; return 1; }
    common_dir=$(git rev-parse --git-common-dir 2>/dev/null)

    local abs_git_dir abs_common_dir
    abs_git_dir=$(cd "$git_dir" 2>/dev/null && pwd)
    abs_common_dir=$(cd "$common_dir" 2>/dev/null && pwd)

    if [[ "$abs_git_dir" == "$abs_common_dir" ]]; then
        echo "Not in a worktree (this is the main repository)"
        return 1
    fi

    if ! git diff --quiet || ! git diff --cached --quiet || [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
        claude "Commit the files that are not committed with a good message"
    fi

    local worktree_path main_worktree branch_name
    worktree_path=$(git rev-parse --show-toplevel)
    branch_name=$(git rev-parse --abbrev-ref HEAD)
    main_worktree=$(git worktree list | head -n 1 | awk '{print $1}')

    if [[ "$branch_name" == "master" || "$branch_name" == "HEAD" ]]; then
        echo "Refusing to merge: worktree is not on a feature branch (current: $branch_name)"
        return 1
    fi

    cd "$main_worktree" 2>/dev/null || cd ..
    git checkout master || return 1
    git pull --ff-only origin master || return 1
    git merge --no-ff "$branch_name" || { echo "Merge failed; resolve conflicts and finish manually"; return 1; }
    git push origin master || return 1

    git worktree remove "$worktree_path"
}

new-agent() {
    local main_worktree
    main_worktree=$(git worktree list | head -n 1 | awk '{print $1}')
    if [[ -z "$main_worktree" ]]; then
        echo "Not in a git repository"
        return 1
    fi

    cd "$main_worktree" || return 1
    git checkout master || return 1
    git pull || return 1

    local name
    if [ -n "$ZSH_VERSION" ]; then
        read "name?Worktree name: "
    else
        read -r -p "Worktree name: " name
    fi
    if [[ -z "$name" ]]; then
        echo "Name required"
        return 1
    fi

    # Sanitize name into a git-branch-friendly slug.
    # Replaces whitespace with underscores, strips characters disallowed
    # by git-check-ref-format, collapses repeats, and trims leading/trailing
    # separators and dots.
    local original_name="$name"
    name=$(printf '%s' "$name" | tr '[:space:]' '_')
    name=$(printf '%s' "$name" | tr -d '~^:?*[\\')
    name=$(printf '%s' "$name" | tr -cd '[:alnum:]_./-')
    name=$(printf '%s' "$name" | sed -e 's/\.\.\+/./g' -e 's|//\+|/|g' -e 's/__\+/_/g')
    name=$(printf '%s' "$name" | sed -e 's|^[-./_]\+||' -e 's|[-./_]\+$||')

    if [[ -z "$name" ]]; then
        echo "Name became empty after sanitization"
        return 1
    fi

    if [[ "$name" != "$original_name" ]]; then
        echo "Sanitized name: '$original_name' → '$name'"
    fi

    git worktree add "../$name" -b "$name" || return 1
    cd "../$name" || return 1

    # If we're inside tmux, rename the current window to the branch name.
    # Disable automatic-rename so the title sticks instead of being
    # overwritten by the running command.
    if [[ -n "$TMUX" ]]; then
        tmux set-window-option automatic-rename off >/dev/null 2>&1
        tmux rename-window "$name" >/dev/null 2>&1
    fi

    claude
}
