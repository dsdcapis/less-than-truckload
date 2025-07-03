#!/bin/bash
set -e

currentFolder="$(pwd)"
publicFolder="$currentFolder/public"
allFolders=()

# Finds all directories containing openapi.yaml files in currentFolder and returns their paths as an array
findAllOpenApiYamlDirs() {
    local -n resultRef=$1

    resultRef=()
    while IFS= read -r -d '' dir; do
        # Remove the $currentFolder prefix and leading slash if present
        rel_dir="${dir#$currentFolder/}"
        resultRef+=("$rel_dir")
    done < <(find "$currentFolder" -type f -name "openapi.yaml" -print0 | xargs -0 -n1 dirname -z | sort -zu)
}


# Creates static html files for openapi.yaml file in the current directory
loadStaticHtmlToFolder() {
    local folder="$1"

    echo "Creating folder \"$publicFolder/$folder\""
    mkdir -p "$publicFolder/$folder"

    echo "Running redocly/cli build-docs command on \"$currentFolder/$folder/openapi.yaml\" and saving it to \"$publicFolder/$folder/index.html\""
    npx @redocly/cli@latest build-docs "$currentFolder/$folder/openapi.yaml" -o "$publicFolder/$folder/index.html"
}

# Generates a high-level index for the Redoc static HTML documentation.
# This function is intended to be used within the create-redoc-static-htm.sh script
# to automate the creation of an overview or entry point for the generated API docs.
# Usage: generateHighLevelIndex
generateHighLevelIndex() {
    local indexFile="$publicFolder/index.html"
    echo "<!DOCTYPE html>
<html>
<head>
    <meta charset=\"UTF-8\">
    <title>API Documentation Index</title>
</head>
<body>
    <h1>API Documentation Index</h1>
    <ul>" > "$indexFile"

    # Build a tree structure from allFolders
    declare -A tree
    for dir in "${allFolders[@]}"; do
        IFS='/' read -ra parts <<< "$dir"
        if [[ ${#parts[@]} -eq 2 ]]; then
            parent="${parts[0]}"
            child="${parts[1]}"
            tree["$parent"]+="$child "
        elif [[ ${#parts[@]} -eq 1 ]]; then
            tree["${parts[0]}"]=""
        fi
    done

    # Sort parents
    mapfile -t sorted_parents < <(printf "%s\n" "${!tree[@]}" | sort -V)

    # Output the tree as nested lists
    for parent in "${sorted_parents[@]}"; do
        echo "        <li>$parent" >> "$indexFile"
        if [[ -n "${tree[$parent]}" ]]; then
            # Sort children
            read -ra children <<< "${tree[$parent]}"
            IFS=$'\n' sorted_children=($(printf "%s\n" "${children[@]}" | sort -V))
            echo "            <ul>" >> "$indexFile"
            for child in "${sorted_children[@]}"; do
                if [[ -f "$publicFolder/$parent/$child/index.html" ]]; then
                    echo "                <li><a href=\"$parent/$child/index.html\">$child</a></li>" >> "$indexFile"
                fi
            done
            echo "            </ul>" >> "$indexFile"
        else
            if [[ -f "$publicFolder/$parent/index.html" ]]; then
                echo "            <ul><li><a href=\"$parent/index.html\">$parent</a></li></ul>" >> "$indexFile"
            fi
        fi
        echo "        </li>" >> "$indexFile"
    done

    echo "    </ul>
</body>
</html>" >> "$indexFile"
    echo "Created high level index at \"$indexFile\""
}

allFolders=()
findAllOpenApiYamlDirs allFolders

for directory in "${allFolders[@]}"; do
    echo "Processing directory: \"$directory\""
    loadStaticHtmlToFolder "$directory"
done

generateHighLevelIndex
