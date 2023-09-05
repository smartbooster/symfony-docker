
# Colors
COLOR_RESET   = \033[0m
COLOR_INFO    = \033[32m
COLOR_COMMENT = \033[33m
COLOR_COMMAND = \033[01m\033[34m

.DEFAULT_GOAL := help

define HELP_MESSAGE=
$(COLOR_INFO)To launch and install the project use the command$(COLOR_RESET) '"\033[01m$(COLOR_COMMAND)make up$(COLOR_RESET)"',\
then in another terminal type $(COLOR_RESET)'"\033[01m$(COLOR_COMMAND)make ssh$(COLOR_RESET)"'\
followed by$(COLOR_RESET) '"$(COLOR_COMMAND)make install$(COLOR_RESET)"'
endef

.PHONY: help
help:
	@cat ./Makefile make/*.mk | grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)'  | awk 'BEGIN {FS = ":.*?## "}; {printf "$(COLOR_COMMAND)%-20s$(COLOR_RESET) %s\n", $$1, $$2}' | sed -e 's/\[34m##/[32m/'
	@echo ''
	@echo '$(HELP_MESSAGE)'
