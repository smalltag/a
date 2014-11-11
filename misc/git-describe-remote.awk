#!awk -f
BEGIN {
  if (ARGC != 2) {
    print "git-describe-remote.awk https://github.com/stedolan/jq"
    exit
  }
  FS = "[ /^]+"
  while ("git ls-remote " ARGV[1] | getline) {
    if (!sha)
      sha = substr($0, 1, 7)
    tag = $3
  }
  while ("curl -s " ARGV[1] "/releases/tag/" tag | getline)
    if ($3 ~ "commits")
      printf "%s-%s-g%s\n", tag, $2, sha
}
