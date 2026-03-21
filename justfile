port := "1237"

@_default:
  just --list --unsorted

# Run development server.
develop: install qr
  node ./source/scripts/generate-json.js
  pnpm exec vite --port {{port}} --clearScreen false --host

# Build for deployment.
build: install
  rm -rf dist
  pnpm exec vite build --base ./

# Build for debugging.
build-debug: install
  pnpm exec gulp debug

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
qr:
    #!/usr/bin/env nu
    let ip = sys net | where name == "en0" | get 0.ip | where protocol == "ipv4" | get 0.address
    let url = $"http://($ip):{{port}}"
    qrtool encode -t ansi256 $url
    print $url
