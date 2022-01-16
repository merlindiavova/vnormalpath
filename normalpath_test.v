module main

import normalpath { chain_path, normalize_path }

fn test_chain_path() {
	assert chain_path('foo', 'bar', 'baz') == 'foo/bar/baz'
	assert chain_path('/foo/', 'bar/baz') == '/foo/bar/baz'
	assert chain_path('/foo', '/bar') == '/bar'
}

fn test_normalize_path() {
	assert normalize_path('/foo/./bar/..//baz/') == '/foo/baz'
	assert normalize_path('../foo/.') == '../foo'
	assert normalize_path('/foo', 'bar/baz/') == '/foo/bar/baz'
	assert normalize_path('/foo', '/bar/..', 'baz') == '/baz'
	assert normalize_path('foo/./bar', '../../', '../baz') == '../baz'
	assert normalize_path('/foo/./bar', '../../baz') == '/baz'

	assert normalize_path('/', 'foo', 'bar') == '/foo/bar'
	assert normalize_path('foo', 'bar', 'baz') == 'foo/bar/baz'
	assert normalize_path('foo', 'bar/baz') == 'foo/bar/baz'
	assert normalize_path('foo', 'bar//baz///') == 'foo/bar/baz'
	assert normalize_path('/foo', 'bar/baz') == '/foo/bar/baz'
	assert normalize_path('/foo', '/bar/baz') == '/bar/baz'
	assert normalize_path('/foo/..', '/bar/./baz') == '/bar/baz'
	assert normalize_path('/foo/..', 'bar/baz') == '/bar/baz'
	assert normalize_path('/foo/../../', 'bar/baz') == '/bar/baz'
	assert normalize_path('/foo/bar', '../baz') == '/foo/baz'
	assert normalize_path('/foo/bar', '../../baz') == '/baz'
	assert normalize_path('/foo/bar', '.././/baz/..', 'wee/') == '/foo/wee'
	assert normalize_path('//foo/bar', 'baz///wee') == '/foo/bar/baz/wee'
}
