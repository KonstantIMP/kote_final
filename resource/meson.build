message('Build resources')

resources_sources = [
    'r/r.d'
]

resources_library = static_library(
    'resources',
    resources_sources,
    install: false,
    d_args: ['-J=../resource/']
)

resources_dep = declare_dependency(
    link_with: resources_library,
    include_directories: './'
)
