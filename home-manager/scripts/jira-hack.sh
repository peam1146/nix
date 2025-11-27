# Creates a new git branch based on a Jira issue you select from a fuzzy finder.
# Assumes you have 'jira-cli' (ankitpokhrel/jira-cli) and 'fzf' installed.
jhack() {
# 1. Get issues assigned to you, in plain format, without headers.
#    - We filter for 'To Do' or 'In Progress' statuses.
#    - '--no-headers' and '--plain' are critical for scripting.
local issue=$(jira issue list \
    -a $(jira me) \
    -s"To Do" \
    --plain \
    --no-headers \
    --columns KEY,SUMMARY \
    | fzf --prompt="Select Jira Issue > ")

# Exit if no issue was selected (e.g., user pressed ESC)
if [[ -z "$issue" ]]; then
    echo "No issue selected."
    return 1
fi

# 2. Extract the key and summary.
#    - awk '{print $1}' gets the first column (e.g., "PROJ-123").
#    - awk '{$1=""; print $0}' gets everything *but* the first column.
local key=$(echo "$issue" | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
local summary=$(echo "$issue" | awk '{$1=""; print $0}' | xargs) # xargs trims whitespace

# 3. Sanitize the summary into a branch-safe name.
#    - Convert to lowercase.
#    - Replace spaces and underscores with a hyphen.
#    - Remove any character that is NOT a-z, 0-9, or a hyphen.
#    - Consolidate multiple hyphens into one.
#    - Remove leading/trailing hyphens.
local sanitized_summary=$(echo "$summary" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -e 's/[ _]/-/g' \
    | sed -e 's/[^a-z0-9-]//g' \
    | sed -e 's/--\+/-/g' \
    | sed -e 's/^-//' -e 's/-$//')

# 4. Combine and create the branch.
local branch_name="${key}-${sanitized_summary}"

# Truncate the branch name if it's too long (common git limit)
branch_name=$(echo "$branch_name" | cut -c 1-60)

# Remove a trailing hyphen one more time in case 'cut' created one
branch_name=$(echo "$branch_name" | sed -e 's/-$//')

echo "Creating branch: ${branch_name}"
git hack "${branch_name}"

jira issue move $key "In Progress"
}

jswitch() {
    # 1. Get issues assigned to you, in plain format, without headers.
    #    - We filter for 'To Do' or 'In Progress' statuses.
    #    - '--no-headers' and '--plain' are critical for scripting.
    local issue=$(jira issue list \
        -a $(jira me) \
        -s "In Progress" \
        -s "In Review" \
        --plain \
        --no-headers \
        --columns KEY,SUMMARY \
        | fzf --prompt="Select Jira Issue > ")

    # Exit if no issue was selected (e.g., user pressed ESC)
    if [[ -z "$issue" ]]; then
        echo "No issue selected."
        return 1
    fi

    # 2. Extract the key and summary.
    #    - awk '{print $1}' gets the first column (e.g., "PROJ-123").
    #    - awk '{$1=""; print $0}' gets everything *but* the first column.
    local key=$(echo "$issue" | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
    local summary=$(echo "$issue" | awk '{$1=""; print $0}' | xargs) # xargs trims whitespace

    # 3. Sanitize the summary into a branch-safe name.
    #    - Convert to lowercase.
    #    - Replace spaces and underscores with a hyphen.
    #    - Remove any character that is NOT a-z, 0-9, or a hyphen.
    #    - Consolidate multiple hyphens into one.
    #    - Remove leading/trailing hyphens.
    local sanitized_summary=$(echo "$summary" \
        | tr '[:upper:]' '[:lower:]' \
        | sed -e 's/[ _]/-/g' \
        | sed -e 's/[^a-z0-9-]//g' \
        | sed -e 's/--\+/-/g' \
        | sed -e 's/^-//' -e 's/-$//')

    # 4. Combine and create the branch.
    local branch_name="${key}-${sanitized_summary}"

    # Truncate the branch name if it's too long (common git limit)
    branch_name=$(echo "$branch_name" | cut -c 1-60)

    # Remove a trailing hyphen one more time in case 'cut' created one
    branch_name=$(echo "$branch_name" | sed -e 's/-$//')

    g switch "${branch_name}"
}
