command --query rg
if test $status -eq 0
    rg --quiet --no-mmap "(JetBrains|intellij).*/shell-integrations/fish/fish-integration.fish" /proc/$fish_pid/cmdline
    if test $status -eq 0
        setup_jetbrains_terminal
    end
end