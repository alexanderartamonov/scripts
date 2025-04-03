for d in *; do
  if [ -d "$d" ]; then         # or:  if test -d "$d"; then
    ( cd "$d" && find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;yes )
  fi
done
