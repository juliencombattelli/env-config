import re

# A version spec starts with an operator in ==, !=, <=, >=, <, >, followed
# by a version containing any character except whitespace and comma
spec_regexp = re.compile(r"^(==|!=|<=|>=|<|>) ([^\s,]*)$")

def explode_version_spec(version_spec):
    '''
    Return a list of tuple containing the version and the operator of each
    version spec.
    '''
    spec_list = [spec.strip() for spec in version_spec.split(",")]
    exploded_spec = []
    for spec in spec_list:
        m = spec_regexp.match(spec)
        if not m:
            print(f"spec {spec} not matching")
            break
        else:
            op = m.group(1)
            ver = m.group(2)
            exploded_spec.append((ver, op))
    return exploded_spec
