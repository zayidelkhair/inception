# ==============================================================================
# 📜 FILE: Makefile
# 🎯 PURPOSE:
#    This Makefile is the master remote control (or the Wizard's Spellbook) for
#    the entire Inception infrastructure. It provides convenient shortcuts
#    (targets) to build images, start containers, inspect logs, and cleanly
#    purge everything from the system without memorizing long docker commands.
#
# 🧒 KID-FRIENDLY CONCEPT & STORY:
#    Imagine you have a giant Lego city with 8 toy houses. If you had to plug in
#    every single battery, turn on every light switch, and check every door one
#    by one every morning, you'd be exhausted!
#    The Makefile is a single magic board with colorful push-buttons:
#    - Press "all" ➔ The entire city builds and turns on!
#    - Press "down" ➔ All the lights go off and the toys rest.
#    - Press "fclean" ➔ The magic broom clears the playroom completely!
#
# 🎓 EVALUATION CHECKPOINT:
#    Evaluators will type `make all` from the project root. It MUST build all
#    images using Dockerfiles (never pre-made images from Docker Hub) and start
#    the entire stack without errors. They will also test `make fclean` to verify
#    that containers, images, volumes, and host directories are completely wiped.
# ==============================================================================

# ------------------------------------------------------------------------------
# 🔧 VARIABLES & PATHS
# ------------------------------------------------------------------------------
# USER: The current logged-in user on the Linux host machine.
# If USER is not set in the shell environment, `whoami` detects it automatically.
USER ?= $(shell whoami)

# NAME: Project identifier name.
NAME = inception

# COMPOSE_FILE: Path to the central blueprint file that defines all services.
COMPOSE_FILE = srcs/docker-compose.yml

# DATA_DIR: Persistent host directory where databases and files stay forever.
# 🧒 STORY: This is the underground treasure chest! Even if the wooden cottages
# on the surface are torn down, the gold coins buried down here are never lost.
DATA_DIR = /home/zsid-ele/data
MARIADB_DIR = $(DATA_DIR)/mariadb
WORDPRESS_DIR = $(DATA_DIR)/wordpress

# ------------------------------------------------------------------------------
# 🎯 .PHONY TARGETS
# 🧒 CONCEPT: A "Phony" target tells Make: "Hey! These names are ACTION COMMANDS,
# not files on disk! Even if a file named 'build' or 'clean' accidentally exists,
# run my command anyway!"
# ------------------------------------------------------------------------------
.PHONY: all build up down stop start clean fclean re status logs mariadb wordpress nginx redis adminer static_site cadvisor ftp

# ------------------------------------------------------------------------------
# 🚀 DEFAULT RULE: `make all` or just `make`
# First builds all images and host directories, then launches all containers.
# ------------------------------------------------------------------------------
all: build up

# ------------------------------------------------------------------------------
# 🏗️ RULE: `make build`
# 1. `sudo mkdir -p`: Creates persistent host folders for MariaDB & WordPress.
# 2. `chown` & `chmod`: Grants your user read/write access so containers don't
#    get "Permission Denied" errors when saving files.
# 3. `docker compose build`: Reads each Dockerfile and compiles local images.
# ------------------------------------------------------------------------------
build:
	@sudo mkdir -p $(MARIADB_DIR) $(WORDPRESS_DIR)
	@sudo chown -R $(USER):$(USER) $(DATA_DIR)
	@sudo chmod -R 775 $(DATA_DIR)
	@docker compose -f $(COMPOSE_FILE) build

# ------------------------------------------------------------------------------
# ⚡ RULE: `make up`
# Starts all containers in the background (-d = detached / silent background mode).
# 🧒 STORY: Like flipping the master power switch in your Lego city so all the
# lights turn on and the toy train starts rolling while you do other things!
# ------------------------------------------------------------------------------
up:
	@docker compose -f $(COMPOSE_FILE) up -d

# ------------------------------------------------------------------------------
# 🛑 RULE: `make down`
# Stops and removes running containers and network.
# ⚠️ Note: Volumes and persistent data on disk are KEPT SAFE by default!
# ------------------------------------------------------------------------------
down:
	@docker compose -f $(COMPOSE_FILE) down

# ------------------------------------------------------------------------------
# ⏸️ RULES: `make stop` and `make start`
# `stop`: Pauses containers without deleting them (freezes them in place).
# `start`: Unfreezes containers back into running state.
# ------------------------------------------------------------------------------
stop:
	@docker compose -f $(COMPOSE_FILE) stop

start:
	@docker compose -f $(COMPOSE_FILE) start

# ------------------------------------------------------------------------------
# 📊 RULE: `make status`
# Shows a live list of all containers, their status (Up or Exited), and ports.
# Evaluators will run this to ensure all 8 containers are running and healthy!
# ------------------------------------------------------------------------------
status:
	@docker compose -f $(COMPOSE_FILE) ps

# ------------------------------------------------------------------------------
# 📜 RULE: `make logs`
# Streams real-time terminal output from all running containers simultaneously.
# Useful for debugging when something goes wrong. Press Ctrl+C to exit.
# ------------------------------------------------------------------------------
logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

# ------------------------------------------------------------------------------
# 🎯 INDIVIDUAL SERVICE TARGETS
# Allows building and starting a single service independently for fast debugging.
# Example: `make nginx` will only build and launch NGINX without the others.
# ------------------------------------------------------------------------------
mariadb:
	@sudo mkdir -p $(MARIADB_DIR)
	@docker compose -f $(COMPOSE_FILE) up -d --build mariadb

wordpress:
	@sudo mkdir -p $(WORDPRESS_DIR)
	@docker compose -f $(COMPOSE_FILE) up -d --build wordpress

nginx:
	@docker compose -f $(COMPOSE_FILE) up -d --build nginx

redis:
	@docker compose -f $(COMPOSE_FILE) up -d --build redis

adminer:
	@docker compose -f $(COMPOSE_FILE) up -d --build adminer

static_site:
	@docker compose -f $(COMPOSE_FILE) up -d --build static_site

cadvisor:
	@docker compose -f $(COMPOSE_FILE) up -d --build cadvisor

ftp:
	@sudo mkdir -p $(WORDPRESS_DIR)
	@docker compose -f $(COMPOSE_FILE) up -d --build ftp

# ------------------------------------------------------------------------------
# 🧹 RULE: `make clean`
# Stops containers and prunes dangling (unused) images and containers to save space.
# ------------------------------------------------------------------------------
clean: down
	@docker system prune -f

# ------------------------------------------------------------------------------
# 💥 RULE: `make fclean` (Full Clean / The Nuclear Option)
# 1. Stops and deletes all containers and internal networks.
# 2. Deletes all Docker volumes (-v) and built images (--rmi all).
# 3. Purges Docker system cache (`prune -af --volumes`).
# 4. Removes the persistent host folder `/home/zsid-ele/data`.
# 🧒 STORY: The giant magic broom! Cleans up every toy, resets the entire room,
# and empties the treasure chest so you can test building it from zero!
# ------------------------------------------------------------------------------
fclean: down
	@docker compose -f $(COMPOSE_FILE) down -v --rmi all --remove-orphans 2>/dev/null || true
	@docker system prune -af --volumes 2>/dev/null || true
	@sudo rm -rf $(DATA_DIR) 2>/dev/null || rm -rf $(DATA_DIR) 2>/dev/null || true
	@echo "All containers, images, volumes, and persistent data have been purged."

# ------------------------------------------------------------------------------
# 🔄 RULE: `make re`
# Performs a complete fresh rebuild: wipes everything (`fclean`) and runs `all`.
# ------------------------------------------------------------------------------
re: fclean all
