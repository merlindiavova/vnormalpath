module normalpath

import os

fn normalize_path(paths ...string) string
{
	mut chained := ''

	for i := 0; i < paths.len; i++ {
		path := paths[i]
		if chained.len > 0 {
			chained = chain_path(chained, path)
		} else {
			chained = path
		}
	}

	return as_normalized_path(chained.split(os.path_separator))
}

fn chain_path(paths ...string) string {
	mut separator := os.path_separator
	mut use_sep := false

	if paths.len > 2 {
		new_r1 := chain_path(paths[0], paths[1])
		new_r2 := chain_path(...paths[2..])
		return chain_path(new_r1, new_r2)
	} else {
		r1 := paths[0]
		r2 := if paths.len > 1 { paths[1] } else {''}
		mut pos := r1.len

		if pos > 0 {
			if r2.starts_with('/') {
				pos = 0
			} else if ! r1.ends_with('/') {
				use_sep = true
			}
		}

		if r2.len == 0 || ! use_sep {
			separator  = ''
		}

		mut chain := []string{}

		chain << r1[0..pos]
		chain << separator
		chain << r2

		// return [r1[0..pos], separator, r2].join('')
		return chain.join('')
	}
}

fn as_normalized_path(paths []string) string
{
	mut relative := false
	mut relative_separator := '..'
	mut possible_result := []string{}
	element := paths.join(os.path_separator)

	for i := 0; i < paths.len; i++ {
		path := paths[i]
		previous_paths := paths[..i].clone()

		if path == '' {
			continue
		}

		if is_dot(path) {
			continue
		}

		if is_dot_dot(path) {
			if possible_result.len == 0 {
				relative = true
				continue
			}

			if possible_result.len > 0 {
				possible_result.pop()
				continue
			}
		} else {
			if previous_paths.len > 0 && relative == true {
				if previous_paths[i - 1] != '..' {
					relative_separator = ''
				}
			}
		}

		possible_result << path
	}

	if relative {
		return os.join_path(relative_separator, ...possible_result).trim_right('\\/')
	}

	mut result := os.join_path('', ...possible_result).trim_right('\\/')

	if element[0] != 47 {
		return result.trim_left('\\/')
	}

	return result
}

pub fn is_dot(elem string) bool
{
	return elem.len == 1 && elem[0] == 46
}

pub fn is_dot_dot(elem string) bool
{
	return elem.len == 2 && elem[0] == 46 && elem[1] == 46
}
