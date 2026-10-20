#!/usr/bin/env bash
set -euo pipefail

# Parse the whole function before pulling, since the pull may update this script.
main() {
	local repo_dir before after running_projects working_dir project app diff_status
	local -a updated=() failed=()

	cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
	repo_dir=$(pwd -P)

	if [[ -n $(git status --porcelain --untracked-files=no) ]]; then
		echo "Refusing to pull: tracked files have local changes." >&2
		return 1
	fi

	# Check Docker before pulling and snapshot only projects with running containers.
	docker compose version >/dev/null
	running_projects=$(docker ps --filter label=com.docker.compose.project \
		--format '{{.Label "com.docker.compose.project.working_dir"}}{{"\t"}}{{.Label "com.docker.compose.project"}}' | sort -u)

	before=$(git rev-parse HEAD)
	git pull --ff-only
	after=$(git rev-parse HEAD)

	if [[ "$before" == "$after" ]]; then
		echo "No new commits; nothing to update."
		return 0
	fi

	while IFS=$'\t' read -r working_dir project; do
		# Ignore projects outside this checkout, including retired/nested apps.
		[[ "$working_dir" == "$repo_dir/"* && -n "$project" ]] || continue
		app=${working_dir#"$repo_dir/"}
		[[ -n "$app" && "$app" != */* && "$app" != _inactive ]] || continue

		if git diff --quiet "$before" "$after" -- "$app/"; then
			continue
		else
			diff_status=$?
			if (( diff_status != 1 )); then
				return "$diff_status"
			fi
		fi

		if [[ ! -f "$app/docker-compose.yml" ]]; then
			echo "Skipping $app: docker-compose.yml no longer exists."
			continue
		fi

		echo "Updating $app (project: $project)..."
		if (cd -- "$app" && docker compose --project-name "$project" up -d); then
			updated+=("$app (project: $project)")
		else
			failed+=("$app (project: $project)")
		fi
	done <<< "$running_projects"

	printf '\nUpdated: %s; failed: %s\n' "${#updated[@]}" "${#failed[@]}"
	if (( ${#updated[@]} > 0 )); then
		printf '  Updated: %s\n' "${updated[@]}"
	fi
	if (( ${#failed[@]} > 0 )); then
		printf '  Failed: %s\n' "${failed[@]}" >&2
		echo "Retry failed projects manually; the Git pull has already completed." >&2
		return 1
	fi
	if (( ${#updated[@]} == 0 )); then
		echo "No changed, running apps to update."
	fi
}

main "$@"
