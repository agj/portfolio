port := "1237"

@_default:
  just --list --unsorted

# Run development server.
develop: clean install qr
  pnpm exec gulp develop --port={{port}}

# Build for deployment.
build: clean install
  pnpm exec gulp build

# Generate media cache.
cache: install
  pnpm exec gulp cache

# Build and deploy to server. Needs .env variables to be set.
deploy: build
  bash ./source/scripts/deploy.sh

# Saves a Git stash with the current cache.
save-cache:
  #!/usr/bin/env nu
  let gitStageChanges = git diff --cached
  if $gitStageChanges != "" {
    print "🛑 Git stage is dirty! Make sure it's clean before running this task."
    exit 1
  }

  let today = date now | format date "%Y-%m-%d"
  git add --force ./cache
  git stash -m $"🧠 cache ($today)"
  git stash apply
  git reset

[private]
install:
  pnpm install

[private]
clean:
  rm -rf public
  rm -rf dist

[private]
qr:
  #!/usr/bin/env nu
  let ip = sys net | where name == "en0" | get 0.ip | where protocol == "ipv4" | get 0.address
  let url = $"http://($ip):{{port}}"
  qrtool encode -t ansi256 $url
  print $url
