'''Test script for looking into point addition/multiplication routines'''

######################
## Field Parameters ##
######################
p = 2**255 - 19  # Base Field Z_p

# Base Point
B = (15112221349535400772501151409588531511454012693041857206046113283949847762202, 46316835694926478169428394003475163141307993866256225615783033603165251855960)

b = 256  # bit-length
c = 3  # base-2 logarithm cofactor of edwards25519
d = 37095705934669439343138083508754565189542113879843219016388785533085940283555  # curve constant
a = -1
L = q = 2^252 + 27742317777372353535851937790883648493  # order of group


######################
## Modular Inverses ##
######################
def inv(x):
  '''Compute modular inverse with square and multiply.'''
  pass

def modp_inv(x):
  '''Compute modular inverse the easy way.'''
  return pow(x, p-2, p)


#######################
## Point Compression ##
#######################
# Square root of -1
modp_sqrt_m1 = pow(2, (p-1) // 4, p)

# Compute corresponding x-coordinate, with low bit corresponding# sign, or return None on failure
def recover_x(y, sign):
  if y >= p:
    return None
  x2 = (y*y-1) * modp_inv(d*y*y+1)
  if x2 == 0:
    if sign:
      return None
    else:
      return 0
    
  # Compute square root of x2
  x = pow(x2, (p+3) // 8, p)
  if (x*x - x2) % p != 0:
    x = x * modp_sqrt_m1 % p
  if (x*x - x2) % p != 0:
    return None
  
  if (x & 1) != sign:
    x = p - x
  return x
      
def extract(p1):
  '''TODO: extract the x- and y-coordinates of a compressed point'''
  n = hex(p1)[2:]
  x = int(n[0:31], 16)
  y = int(n[32:63], 16)
  return x, y


######################
## Point Operations ##
######################
def add(x1, y1, x2, y2):
  '''addition in affine coordinates'''
  x3 = (x1*y2 + y1*x2) * modp_inv(1 + d*x1*y1*x2*y2)
  y3 = (y1*y2 - a*x1*x2) * modp_inv(1 - d*x1*y1*x2*y2)

  return (x3, y3)


def dbl(x, y):
  '''double in affine coordinates'''
  x3 = (2*x*y) * modp_inv(y**2 + a * x**2)
  y3 = (y**2 - a * x**2) * modp_inv(2 - y**2 - a * x**2)

  return x3, y3


def to_proj(x, y):
  '''project an affine point to extended/projective coordinates'''
  return (x, y, 1, x*y)


def to_affine(x, y, z, t):
  '''return extended/projective point to affine coordinates'''
  zinv = modp_inv(z)
  return (x*zinv % p, y*zinv % p)


def proj_add(x1, y1, z1, t1, x2, y2, z2, t2):
  '''add in extended/projective coordinates'''
  A = (y1 - x1) * (y2 - x2) % p
  B = (y1 + x1) * (y2 + x2) % p
  C = 2 * t1 * t2 * d % p
  D = 2 * z1 * z2 % p
  E = B - A
  F = D - C
  G = D + C
  H = B + A

  return (E*F, G*H, F*G, E*H)


def proj_dbl(x, y, z, t):
  '''double a point in extended/projective coordinates'''
  A = x**2
  B = y**2
  C = 2 * z**2
  H = A + B
  E = H - (x + y)**2
  G = A - B
  F = C + G

  return (E*F, G*H, F*G, E*H)


# compute Q = kQ
def mult(k, P):
  Q = (0, 1, 1, 0)  # identity/neutral element
  while k > 0:
    if k & 1:
      Q = proj_add(Q, P)
    P = proj_add(P, P)  # TODO: consider testing proj_dbl here
    k >>= 1
  return Q


###########
## Tests ##
###########

## Point Projection
# Test - project a point back-and-forth (without operation)

#print(f'\nStarting Point: {G[0], G[1]}')
point = to_proj(G[0], G[1])
#print(f'\nAffine to Projective: {point}')
affine = to_affine(*point)
#print(f'\nProjective to Affine: {affine}')

assert(affine == (G[0], G[1]))


## Point Addition and Doubling
# Gy = 4 * modp_inv(5) % p
# Gx = recover_x(Gy, 0)  # TODO: handle point compression
# G = (Gx, Gy, 1, Gx*Gy % p)
G = (15112221349535400772501151409588531511454012693041857206046113283949847762202, 46316835694926478169428394003475163141307993866256225615783033603165251855960)
G = to_proj(*G)

twoG = (24727413235106541002554574571675588834622768167397638456726423682521233608206, 15549675580280190176352668710449542251549572066445060580507079593062643049417)

fiveG = (33467004535436536005251147249499675200073690106659565782908757308821616914995, 43097193783671926753355113395909008640284023746042808659097434958891230611693)

# Test - square the order 2 element (0, -1)
assert(add(0, -1, 0, -1) == (0, 1))
assert(dbl(0, -1) == (0, 1))

# Test - compute 2G from G using proj_dbl
assert(twoG == to_affine(*proj_dbl(*G)))

# Test - compute 5G from twoG using proj_dbl and proj_add
twoG = to_proj(*twoG)
assert(fiveG == to_affine(*proj_add(*G, *proj_dbl(*twoG))))
