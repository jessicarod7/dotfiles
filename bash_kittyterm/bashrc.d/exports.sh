#!/bin/bash
# PATH exports
export PATH="$PATH:$HOME/.poetry/bin"
export PATH="$PATH:$XDG_DATA_HOME/JetBrains/Toolbox/scripts"
export PATH="$PATH:/opt/zeal/bin"
export PATH="$PATH:/opt/MATLAB/current/bin"

# Dev and other exports
export JAVA_HOME=/lib/jvm/java
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"

export CARGO_HOME="$XDG_DATA_HOME/cargo"
. "$CARGO_HOME/env"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgreprc"
export PATH="$PATH:/usr/local/go/bin"
export GOPATH="$XDG_DATA_HOME/go"
export PATH="$PATH:$GOPATH/bin"
export RYE_HOME="$XDG_CONFIG_HOME/rye"
eval "$($HOME/.rbenv/bin/rbenv init - bash)"
