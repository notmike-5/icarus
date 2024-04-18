p = 2**255 - 19
b = 256
c = 3  # base-2 logarithm cofactor of edwards25519
d = 37095705934669439343138083508754565189542113879843219016388785533085940283555
a = -1
B = (15112221349535400772501151409588531511454012693041857206046113283949847762202, 46316835694926478169428394003475163141307993866256225615783033603165251855960)
L = 2^252+27742317777372353535851937790883648493  # order of group

######################
## Point Operations ##
######################

def extract(p1):
  '''TODO: extract the x- and y-coordinates of a point'''
  n = hex(p1)[2:]
  x = int(n[0:31], 16)
  y = int(n[32:63], 16)
  return x, y


def add(x1, y1, x2, y2):
  '''addition in affine coordinates'''
  x3 = (((x1*y2) % L) + ((y1*x2) % L)) / (1 + ((d*x1*y1*x2*y2) % L))
  y3 = (((y1*y2) % L) - ((a*x1*x2) % L)) / (1 - ((d*x1*y1*x2*y2) % L))

  return (int(x3), int(y3))


def dbl(x, y):
  '''double in affine coordinates'''
  x3 = (2 * x * y) / (y**2 + a * x**2)
  y3 = (y**2 - a * x**2) / (2 - y**2 - a * x**2)

  return x3, y3


def to_proj(x, y):
  '''project an affine point to extended/projective coordinates'''
  return (x, y, 1, (x*y) % L)


def to_affine(x, y, z, t):
  '''return extended/projective point to affine coordinates'''
  return (x*z, y*z)


def proj_add(x1, y1, z1, t1, x2, y2, z2, t2):
  '''add in extended/projective coordinates'''
  A = ((y1 - x1) * (y2 - x2)) % L
  B = ((y1 + x1) * (y2 + x2)) % L
  C = (t1 * 2 * d * t2) % L
  D = (z1 * 2 * z2) % L
  E = B - A
  F = D - C
  G = (D + C) % L
  H = (B + A) % L

  return (E*F, G*H, F*G, E*H)


def proj_dbl(x, y, z, t):
  '''double a point in extended/projective coordinates'''
  A = x * x
  B = y * y
  C = 2 * (z * z)
  H = A + B
  E = H - (x + y) * (x + y)
  G = A - B
  F = C + G

  return (E*F, G*H, F*G, E*H)


def mult(k, G):
  pass
  
###########
## Tests ##
###########

## Choose a Point
# hex(G), compressed
#G = int('5866666666666666666666666666666666666666666666666666666666666666', 16)

# uncompressed(G), x- and y-coordinates
G = (15112221349535400772501151409588531511454012693041857206046113283949847762202, 46316835694926478169428394003475163141307993866256225615783033603165251855960)


## Point Projection
# Test - project a point back-and-forth (without operation)

#print(f'\nStarting Point: {G[0], G[1]}')
point = to_proj(G[0], G[1])
#print(f'\nAffine to Projective: {point}')
affine = to_affine(*point)
#print(f'\nProjective to Affine: {affine}')

assert(affine == (G[0], G[1]))


## Point Addition and Doubling
# Test - square the order 2 element (0, -1)
assert(add(0, -1, 0, -1) == (0, 1))
assert(dbl(0, -1) == (0, 1))

# 2G
num = proj_dbl(*proj(G[0], G[1]))
to_affine(*num)
