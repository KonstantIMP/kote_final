smtp_source = [
    'smtp.c', 'smtp.h', 'smtp.d'
]

curl_dep = dependency('curl')

smtp_lib = static_library('smtp',
    smtp_source,
    dependencies: [curl_dep]
)

smtp_dep = declare_dependency(
    link_with: smtp_lib,
    include_directories: './',
    sources: smtp_source
)
