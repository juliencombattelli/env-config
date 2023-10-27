def is_version_satisfying_spec(version, version_spec):
    try:
        from packaging.version import parse
        from packaging.specifiers import SpecifierSet
    except ModuleNotFoundError:
        # if packaging is installed earlier during the same BitBake execution
        # it will not be in sys.modules and a classic import would not work
        import importlib.util
        importlib.invalidate_caches()
        packaging_version = importlib.import_module('packaging.version')
        parse = packaging_version.parse
        packaging_specifiers = importlib.import_module('packaging.specifiers')
        SpecifierSet = packaging_specifiers.SpecifierSet

    version = parse(version)
    version_spec = SpecifierSet(version_spec)
    return version in version_spec
