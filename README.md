# PLSQL Unwrap

A python utility package to unwrap Oracle wrapped objects.

## Installation
`pip install plsqlunwrap`

## Example

```python
from plsqlunwrap import unwrap

wrapped = """
CREATE OR REPLACE  FUNCTION teste wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
8
3d 71
m9n4KQ8rT+C9b7lU4HcO3pDzsUMwg8eZgcfLCNL+XhahYtGhXOfAsr2ym16lmYEywLIJpXSL
wMAy/tKGCamhBKPHvpK+FkZTOQdTo4KmpqsCL3g=
"""

print(unwrap(wrapped))
# FUNCTION teste RETURN NUMBER IS
# BEGIN
#   RETURN 1;
# END TESTE;
```
