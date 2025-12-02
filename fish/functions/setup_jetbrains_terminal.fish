# The python item doesn't render properly in the integrated terminal.
function setup_jetbrains_terminal
	set -g tide_right_prompt_items $tide_right_prompt_items
	set -ge tide_right_prompt_items[(contains -i python $tide_right_prompt_items)]
end
