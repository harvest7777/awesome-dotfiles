# pipes.sh garbles its box-drawing characters under macOS's bash 3.2, which
# comes first on PATH, so run it with Homebrew's bash
function pipes.sh
    /opt/homebrew/bin/bash (command -s pipes.sh) $argv
end
