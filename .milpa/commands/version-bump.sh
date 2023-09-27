#!/usr/bin/env bash
@milpa.load_util tmp

name="$(basename "${MILPA_ARG_FORMULA%.rb}")"
@milpa.log info "bumping $name"

if [[ "$MILPA_ARG_VERSION" == "latest" ]]; then
  latest_url="$(awk -F'"' '/# version-check-url$/ {print $2}' "$MILPA_ARG_FORMULA")"
  latest=$(curl --silent "$latest_url")
  @milpa.log info "found latest version from well-known url: $latest"
else
  latest="$MILPA_ARG_VERSION"
fi

@tmp.file original
@tmp.file changes
cp "$MILPA_ARG_FORMULA" "$original"

awk -v version="\"$latest\"" -v pattern="\".+\"" '/^  version "/ {gsub(pattern, version, $0)}1' "$MILPA_ARG_FORMULA" > "$MILPA_ARG_FORMULA.updated"

shasum_url_tpl="$(awk -F'#' -v version="$latest" '/# shasum-url$/ {
  gsub("VERSION", version, $2);
  gsub(/ */, "", $2);
  print $2
}' "$MILPA_ARG_FORMULA")"

while read -r os arch; do
  @milpa.log info "looking up $os/$arch checksum"
  shasum_url="${shasum_url_tpl/OS/$os}"
  shasum_url="${shasum_url/ARCH/$arch}"

  sum="$(curl --silent --fail --show-error -L "$shasum_url")" || @milpa.fail "Could not find checksum for $shasum_url"

  @milpa.log info "found checksum $shasum_url for pair $os/$arch"
  awk -v sum="\"$sum\"" -v pattern="\".+\"" '/ # '"${os}_${arch}"'$/ {gsub(pattern, sum, $0)}1' "$MILPA_ARG_FORMULA.updated" > "$MILPA_ARG_FORMULA.updated-bak" &&  mv "$MILPA_ARG_FORMULA.updated-bak" "$MILPA_ARG_FORMULA.updated"
done < <(awk '/ # (darwin|linux)_(arm64|amd64|mips|mips64)$/ {gsub("_", " ", $NF);print $NF}' "$MILPA_ARG_FORMULA")

mv "$MILPA_ARG_FORMULA.updated" "$MILPA_ARG_FORMULA" || @milpa.fail "could not save updated formula"

diff -u -Loriginal "$original" "$MILPA_ARG_FORMULA" > "$changes"
ec="$?"
case "$ec" in
  03)
    @milpa.fail "no changes found for $MILPA_ARG_FORMULA after updating to $latest"
    ;;
  1|0)
    if ! [[ "$MILPA_OPT_UPDATE_REPO" ]]; then
      @milpa.log complete "Formula for $name updated to $latest"
      cat "$changes"
      exit
    fi

    @milpa.log warning "Changes found, updating repo"
    cat "$changes"
    git add "$MILPA_ARG_FORMULA" || @milpa.fail "could not stage formula"
    git commit -m "Bump $name to $latest" || @milpa.fail "could not commit changes"
    git push origin main || @milpa.fail "could not push changes"
    @milpa.log complete "formula updated and pushed"
    ;;
  *)
    @milpa.fail "Error during diff: $ec"
    ;;
esac
