# SPDX-License-Identifier: GPL-3.0-or-later

#    ----------------------------------------------------------------------
#    Copyright © 2024, 2025, 2026  Pellegrino Prevete
#
#    All rights reserved
#    ----------------------------------------------------------------------
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

SHELL ?= bash
PREFIX ?= /usr/local
_PROJECT=evm-chains
DOC_DIR=$(DESTDIR)$(PREFIX)/share/doc/$(_PROJECT)
BIN_DIR=$(DESTDIR)$(PREFIX)/bin
MAN_DIR?=$(DESTDIR)$(PREFIX)/share/man
LIB_DIR=$(DESTDIR)$(PREFIX)/lib

_INSTALL_FILE=\
  install \
    -vDm644
_INSTALL_DIR=\
  install \
    -vdm755
_INSTALL_EXE=\
  install \
    -vDm755

DOC_FILES=\
  $(wildcard \
      *.rst) \
  $(wildcard \
      *.md)

_BUILD_TARGETS=\
  build \
  build-split
_BUILD_TARGETS_ALL=\
  all \
  $(_BUILD_TARGETS)
_CHECK_TARGETS=\
  shellcheck
_CHECK_TARGETS_ALL=\
  check \
  $(_CHECK_TARGETS)
_INSTALL_SCRIPTS_TARGETS=\
  install-json
INSTALL_DOC_TARGETS=\
  install-doc \
  install-man
_INSTALL_TARGETS=\
  install-scripts \
  $(_INSTALL_DOC_TARGETS)
_INSTALL_TARGETS_ALL=\
  install \
  $(_INSTALL_TARGETS) \
  $(_INSTALL_SCRIPTS_TARGETS)

_PHONY_TARGETS=\
  $(_BUILD_TARGETS_ALL) \
  $(_CHECK_TARGETS_ALL) \
  $(_INSTALL_TARGETS_ALL)
  
all: build build-split

check: shellcheck

shellcheck:

	cat \
	  "chains.json" | \
	  jq \
	    . \
	    1>&"/dev/null"

build:

	mkdir \
	 -p \
	 "build"
	install \
	  -vDm644 \
	  "chains.json" \
	  "build"

build-split:

	mkdir \
	 -p \
	 "build"
	install \
	  -vDm644 \
	  "COPYING" \
	  "build/COPYING"
	_chains_amount="$$( \
	  cat \
	    "$${_chains_file}" | \
	    jq \
	      length)"; \
	_msg=( \
	  "Found '$${_chains_amount}'" \
	  "chains." \
	); \
	echo \
	 "$${_msg[*]}"; \
	_index_end="$(( \
	  "$${_chains_amount}" - \
	  1 ))"; \
	for _index \
	  in $$(seq \
	         "0" \
	         "$${_index_end}"); do \
	  _jq_query="[.[]][$${_index}]"; \
	  _network="$$( \
	    jq \
	      "$${_jq_query}" \
	      "$${_chains_file}")"; \
	  _msg=( \
	    "Network '$${_index}'" \
	    "out of '$${_index_end}'." \
	  ); \
	  _chain_id="$$( \
	    echo \
	      "$${_network}" | \
	      jq \
	        ".chainId")"; \
	  echo \
	    "$${_network}" | \
	    jq \
	      "[.]" > \
	      "build/$${_chain_id}.json"; \
	  _msg=( \
	    "Written configuration file" \
	    "for network with chain ID" \
	    "'$${_chain_id}'" \
	    "('$${_index}'" \
	    "out of '$${_index_end}')." \
	  ) \
	  echo \
	   "$${_msg[*]}"; \
	done

install: $(_INSTALL_TARGETS)

install-scripts: $(_INSTALL_SCRIPTS_TARGETS)

install-bash-scripts:

	for _file in $(_BASH_FILES); do \
	  $(_INSTALL_EXE) \
	    "$(_PROJECT)/$${_file}" \
	    "$(BIN_DIR)/$${_file}"; \
	done

install-node-scripts:

	for _file in $(_NODE_FILES); do \
	  $(_INSTALL_EXE) \
	    "$(_PROJECT)/$${_file}" \
	    "$(LIB_DIR)/$(_PROJECT)/$${_file}"; \
	done

install-doc:

	$(_INSTALL_FILE) \
	  $(DOC_FILES) \
	  -t \
	  "$(DOC_DIR)/"

install-man:

	$(_INSTALL_DIR) \
	  "$(MAN_DIR)/man1"
	rst2man \
	  "man/evm-contract-bytecode-get.1.rst" \
	  "$(MAN_DIR)/man1/evm-contract-bytecode-get.1"
	rst2man \
	  "man/evm-contract-call.1.rst" \
	  "$(MAN_DIR)/man1/evm-contract-call.1"
	rst2man \
	  "man/evm-contract-deployer-get.1.rst" \
	  "$(MAN_DIR)/man1/evm-contract-deployer-get.1"

.PHONY: $(_PHONY_TARGETS)
