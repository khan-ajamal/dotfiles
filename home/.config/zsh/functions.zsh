# mkdir + cd in one go. Passes every flag straight through to mkdir
# and lands in the last directory operand: mkcd -p tests/ui -> tests/ui
mkcd() {
	local arg
	local -a dirs
	local skip_next=0 opts_done=0
	for arg in "$@"; do
		if (( skip_next )); then skip_next=0; continue; fi
		if (( ! opts_done )); then
			case $arg in
				--) opts_done=1; continue ;;
				--mode|-[^-]*m) skip_next=1; continue ;;  # takes a separate MODE operand
				-*) continue ;;
			esac
		fi
		dirs+=("$arg")
	done
	if (( ! ${#dirs} )); then
		print -u2 "mkcd: missing directory operand"
		return 1
	fi
	mkdir "$@" && cd -- "${dirs[-1]}"
}
