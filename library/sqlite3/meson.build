message('Build shared SQLite3')

sqlite3_sources = [
    'sqlite3.c'
]

sqlite3_headers = [
    'sqlite3.h',
    'sqlite3ext.h'
]

sqlite3_library = shared_library(
    'sqlite',
    sqlite3_sources,
    install: true,
    version: '3.37.0'
)

sqlite3_dep = declare_dependency(
    link_with: sqlite3_library,
    include_directories: './',
    sources: sqlite3_sources
)
