# README

## Quick Start

0. Check how-to

```
make help
```

1. Customize variables in Makefile for your own project

```
# ############################################################# #
# Change variables below for your own                           #
# ############################################################# #

# Project repo address and repo namespace
# The project module name will be: [repo_addr/][repo_name/]project_name
# Comment it out or leave it blank to unset a variable
repo_addr := gitlab.com
repo_name := go-hao

# Project name
# Comment it out or leave it blank for default value (Root folder name of the project)
project_name :=

# Name for main executable of the project
# Comment it out or leave it blank for default value (main)
main_name :=

# Proxy address for GOPROXY
# Do not add https:// or http:// in front of the address
# Comment it out or leave it blank for default value (proxy.golang.org)
proxy_addr := goproxy.cn

```

2. Set go env if needed

```
make set
```

3. Initialize the project

```
make go.mod
```

4. Run your project for the first time

```
make run
```