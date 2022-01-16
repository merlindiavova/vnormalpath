module normalpath

import os

pub fn normalize_path(paths ...string) string {
	mut chained := ''

	for i := 0; i < paths.len; i++ {
		path := paths[i]
		if chained.len > 0 {
			chained = chain_path(chained, path)
		} else {
			chained = path
		}
	}

	if chained in ['.', '/'] {
		return chained
	}

	// Counts sequencial `/` ocurrences in the given chain.
	// Replaces found occurences with a single `/`
	first_slash_idx := chained.index('/') or { -1 }
	last_sequencial_slash_count := sequencial_count(chained, '/', first_slash_idx)

	if last_sequencial_slash_count >= first_slash_idx {
		chained = chained.replace_once('/'.repeat(last_sequencial_slash_count), '/')
	}

	if chained in ['.', '/'] {
		return chained
	}

	return as_normalized_path(chained.split(os.path_separator))
}

pub fn chain_path(paths ...string) string {
	mut separator := os.path_separator
	mut use_sep := false

	if paths.len > 2 {
		first_two := chain_path(paths[0], paths[1])
		remainder := chain_path(...paths[2..])
		return chain_path(first_two, remainder)
	}

	part1 := paths[0]
	part2 := if paths.len > 1 { paths[1] } else { '' }
	mut pos := part1.len

	if pos > 0 {
		if part2.starts_with('/') {
			pos = 0
		} else if !part1.ends_with('/') {
			use_sep = true
		}
	}

	if part2.len == 0 || !use_sep {
		separator = ''
	}

	mut chain := []string{}

	chain << part1[0..pos]
	chain << separator
	chain << part2

	// return [part1[0..pos], separator, part2].join('')
	return chain.join('')
}

fn as_normalized_path(paths []string) string {
	mut relative := false
	mut relative_separator := '..'
	mut possible_result := []string{}
	separator := os.path_separator
	element := paths.join(separator)

	for i := 0; i < paths.len; i++ {
		path := paths[i]
		current_paths := paths[i..].clone()
		previous_paths := paths[..i].clone()

		if path == '' {
			continue
		}

		if is_dot(path) {
			if possible_result.len == 0 {
				relative = true
				relative_separator = '.'
			}

			continue
		}

		if is_dot_dot(path) {
			if possible_result.len == 0 {
				relative = true
				continue
			}

			if possible_result.len > 0 {
				possible_result.pop()

				if possible_result.len == 0 {
					// First check handles a edge case where there are ../p/..
					if element[0] == 46 && element[1] == 46 {
						relative_separator = '..'
					} else if element[0] == 46 {
						relative_separator = '.'
					} else if element[0] == 47 {
						relative_separator = separator
					}
				}

				continue
			}
		} else {
			if previous_paths.len > 0 && relative == true {
				if !is_dot_dot(previous_paths[i - 1]) {
					relative_separator = ''
				}
			}
		}

		if previous_paths.len > 0 && current_paths.len == 1 {
			if is_dot(previous_paths[i - 1]) {
				relative = false
			}

			// Handle some edgcases
			filtered_previous_paths := previous_paths.filter(it != '.')
			if filtered_previous_paths.len == 2 {
				if is_dot_dot(filtered_previous_paths[0]) && is_dot_dot(filtered_previous_paths[1])
					&& relative == true && element[0] == 46 {
					relative_separator = '..' + separator + '..' + separator
				}
			}
		}

		possible_result << path
	}

	if relative {
		if possible_result.len == 1 && element[0] == 47 {
			return os.join_path(separator, ...possible_result).trim_right('\\/')
		}

		if possible_result.len == 0 && element[0] == 47 && relative_separator == separator {
			return separator
		}

		return os.join_path(relative_separator, ...possible_result).trim_right('\\/')
	}

	mut result := os.join_path('', ...possible_result).trim_right('\\/')

	if element[0] == 47 && possible_result.len == 0 && result.len == 0 {
		return separator
	}

	if element[0] != 47 {
		return result.trim_left('\\/')
	}

	return result
}

pub fn is_dot(elem string) bool {
	// return elem.len == 1 && elem[0] == `.`
	return elem == '.'
}

pub fn is_dot_dot(elem string) bool {
	// return elem.len == 2 && elem[0] == `.` && elem[1] == `.`
	return elem == '..'
}

// Recursively counts how many `p` occures in sequencial order.
// TODO: Double check if vlib has a similar function.
fn sequencial_count(s string, p string, index int) int {
	new_index := s.index_after(p, index + 1)

	if new_index < 0 {
		return index + 1
	}

	return sequencial_count(s, p, new_index)
}
