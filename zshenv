export HOMEBREW_CASK_OPTS="--no-quarantine --no-binaries"

function exists() {
  # `command -v` is similar to `which`
  # https://stackoverflow.com/a/677212/1341838
  command -v $1 >/dev/null 2>&1

  # More explicitly written:
  # command -v $1 1>/dev/null 2>/dev/null
}

# A helper function to create directory and cd into that new directory
function mkcd {
  last=$(eval "echo \$$#")
  if [ ! -n "$last" ]; then
    echo "Enter a directory name"
  elif [ -d $last ]; then
    echo "\`$last' already exists"
  else
    mkdir $@ && cd $last
  fi
}

# Modifying `cd` command
# If the directory contains venv folder, then activate the virtual environment
function cd() {
    builtin cd "$@"
    venv=$(eval "ls | grep venv")
    if [ -n "$venv" ]; then
        echo "Virtual Environment found"
        echo "Activating virtual environment"
        source venv/bin/activate
        echo "Virtual environment activated"
    fi
}