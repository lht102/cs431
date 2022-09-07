#!/usr/bin/env bash

encrypt_files() {
	for item in "$@"; do
		local file="$item"
		local encrypted_file="$item".encrypted
		openssl enc -aes-256-cbc -in $file -out $encrypted_file -k $PASSWORD
	done
}

decrypt_files() {
	for item in "$@"; do
		local encrypted_file="$item".encrypted
		local file="$item"
		openssl enc -aes-256-cbc -d -in $encrypted_file -out $file -k $PASSWORD
	done
}
