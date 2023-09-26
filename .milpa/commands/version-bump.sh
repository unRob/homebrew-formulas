#!/usr/bin/env bash

name="$(basename "${MILPA_ARG_FORMULA%.rb}")"
@milpa.log info "bumping $name"
latest_url="$(awk -F'"' '/# version-check-url$/ {print $2}' "$MILPA_ARG_FORMULA")"
latest=$(curl --silent "$latest_url")

awk -v version="\"$latest\"" -v pattern="\".+\"" '/^  version "/ {gsub(pattern, version, $0)}1' "$MILPA_ARG_FORMULA" > "$MILPA_ARG_FORMULA.updated"

shasum_url_tpl="$(awk -F'#' -v version="$latest" '/# shasum-url$/ {
  gsub("VERSION", version, $2);
  gsub(/ */, "", $2);
  print $2
}' "$MILPA_ARG_FORMULA")"

while read -r os arch; do
  @milpa.log info "looking for pair $os $arch"
  shasum_url="${shasum_url_tpl/OS/$os}"
  shasum_url="${shasum_url/ARCH/$arch}"

  if ! sum="$(curl --silent --fail --show-error -L "$shasum_url")"; then
    @milpa.log warning "Could not find checksum for $shasum_url"
    continue
  fi
  awk -v sum="\"$sum\"" -v pattern="\".+\"" '/ # '"${os}_${arch}"'$/ {gsub(pattern, sum, $0)}1' "$MILPA_ARG_FORMULA.updated" > "$MILPA_ARG_FORMULA.updated-bak" &&  mv "$MILPA_ARG_FORMULA.updated-bak" "$MILPA_ARG_FORMULA.updated"
done < <(cat <<PAIRS
darwin amd64
darwin arm64
linux amd64
linux arm64
PAIRS
)

mv "$MILPA_ARG_FORMULA.updated" "$MILPA_ARG_FORMULA" || @milpa.fail "could not save updated formula"
@milpa.log complete "Updated to $latest"
