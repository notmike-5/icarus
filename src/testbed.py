def bitlen(n: int):
    '''Get the bitlength of some integer.'''
    # return f"{len(format(n, 'b'))}-bit"
    return len(format(n, 'b'))


######################
## Field Parameters ##
######################
p = 2**255 - 19  # Base Field Z_p

# Base Point
B = (15112221349535400772501151409588531511454012693041857206046113283949847762202, 46316835694926478169428394003475163141307993866256225615783033603165251855960)

b = 256  # bit-length
c = 3  # base-2 logarithm cofactor of edwards25519
# curve constant
d = 37095705934669439343138083508754565189542113879843219016388785533085940283555
a = -1
L = q = 2 ^ 252 + 27742317777372353535851937790883648493  # order of group


def modp_inv(x):
    '''Compute modular inverse the easy way.'''
    return pow(x, p-2, p)


def to_proj(x, y):
    '''project an affine point to extended/projective coordinates'''
    return (x, y, 1, x*y)


def to_affine(x, y, z, t):
    '''return extended/projective point to affine coordinates'''
    zinv = modp_inv(z)
    return (x*zinv % p, y*zinv % p)


######################
## Point Operations ##
######################

# Affine
def add(x1, y1, x2, y2):
    '''addition in affine coordinates'''
    # FACT: these are the modular inverses we want to avoid
    #      i.e. ’why’ we like extended (projective) coordinates
    x3 = (x1*y2 + y1*x2) * modp_inv(1 + d*x1*y1*x2*y2)
    y3 = (y1*y2 - a*x1*x2) * modp_inv(1 - d*x1*y1*x2*y2)

    return (x3, y3)


def dbl(x, y):
    '''double in affine coordinates'''
    x3 = (2*x*y) * modp_inv(y**2 + a * x**2)
    y3 = (y**2 - a * x**2) * modp_inv(2 - y**2 - a * x**2)

    return x3, y3


def proj_add(x1, y1, z1, t1, x2, y2, z2, t2):
    '''add in extended/projective coordinates'''
    A = (((y1 - x1) % p) * ((y2 - x2) % p)) % p
    B = (((y1 + x1) % p) * ((y2 + x2) % p)) % p
    C = (((2 * t1) % p) * ((t2 * d) % p)) % p
    D = (((2 * z1) % p) * z2) % p
    E = (B - A) % p
    F = (D - C) % p
    G = (D + C) % p
    H = (B + A) % p

    return ((E*F) % p, (G*H) % p, (F*G) % p, (E*H) % p)


def proj_dbl(x, y, z, t):
    '''double a point in extended/projective coordinates'''
    A = x**2 % p
    B = y**2 % p
    C = (2 * (z**2 % p)) % p
    H = (A + B) % p
    E = (H - ((x + y) % p)**2 % p) % p
    G = (A - B) % p
    F = (C + G) % p
    return ((E*F) % p, (G*H) % p, (F*G) % p, (E*H) % p)


# compute kP
def mult(k, P):
    '''Point Multiplication (by Montgomery ladder)'''
    R0 = (0, 1, 1, 0)
    R1 = P
    for n in range(bitlen(k)):
      if k & (1 << n):
          R1 = proj_add(*R0, *R1)
          R0 = proj_add(*R0, *R0)
      else:
          R0 = proj_add(*R0, *R1)
          R1 = proj_add(*R1, *R1)

      n += 1

    return R0


def point_mult(s, P):
    Q = (0, 1, 1, 0)
    while s > 0:
        if s & 1:
            Q = proj_add(*Q, *P)
        P = proj_add(*P, *P)

        s >>= 1

    return Q





if __name__== "__main__":
    ###########
    ## Tests ##
    ###########

    print("Initiating tests...")

    # Gy = 4 * modp_inv(5) % p
    # Gx = recover_x(Gy, 0)  # TODO: handle point compression
    # G = (Gx, Gy, 1, Gx*Gy % p)
    G_hex = 0x5866666666666666666666666666666666666666666666666666666666666666
    G = (15112221349535400772501151409588531511454012693041857206046113283949847762202,         46316835694926478169428394003475163141307993866256225615783033603165251855960)
    G = to_proj(*G)


    # Point Projection

    # Test - project a point back-and-forth (without performing any operations)
    print(f'\nStarting Point: \n{G[0], G[1]}')

    # to extended (projective) coordinates
    point = to_proj(G[0], G[1])
    print(f'\nAffine to Projective: \n{point}')

    assert point == (G[0], G[1], 1, G[0] * G[1]), f'Affine-to-Projective passed'

    # back to affine coordinates
    affine = to_affine(*point)
    print(f'\nProjective to Affine: \n{affine}\n')

    assert affine == (G[0], G[1])

    # Point Addition and Doubling
    '''The values 2G, 5G, aG, and bG have been generated according to:
    https://crypto.stackexchange.com/questions/99798/test-vectors-points-for-ed25519'''

    # 2G
    twoG_hex = 0xc9a3f86aae465f0e56513864510f3997561fa2c9e85ea21dc2292309f3cd6022
    twoG = (24727413235106541002554574571675588834622768167397638456726423682521233608206, 15549675580280190176352668710449542251549572066445060580507079593062643049417)

    # 5G
    fiveG_hex = 0xedc876d6831fd2105d0b4389ca2e283166469289146e2ce06faefe98b22548df
    fiveG = (33467004535436536005251147249499675200073690106659565782908757308821616914995,  43097193783671926753355113395909008640284023746042808659097434958891230611693)

    # aG
    exp_a = 0x12581e70a192aeb9ac1411b36d11fc06393db55998190491c063807a6b4d730d

    aG_hex = 0x14e35209936de59710e4a3a55b1887a6f3a390c0b1b2d132a0158ff3b60581e0
    aG = (46953515626174660128743374276590207025464948126956050456964432034683890442435, 43649996176441760651255662656482711906128939437336752974722489909985414406932)

    # bG
    exp_b = 0x0c2340b974bebfb9cb3f14e991bca432b57fb33f7c4d79e15f64209076afcd00

    bG_hex = 0xcca4cc575d5eb9057834ad8b759272d37feb95c9f7197bf251814f37a4413f1d
    bG = (48108495825706412711799803692360228025391948835486250305831184019146948949994, 13228837014764440841117560545823854143168584625415590819123131242008409842892)

    # Tests

    # Test: square the order 2 element (0, -1) using affine add() & dbl()
    assert add(0, -1, 0, -1) == (0, 1)
    assert dbl(0, -1) == (0, 1)

    # Test: compute 2G from G using proj_add and proj_dbl
    assert to_affine(*proj_add(*G, *G)) == twoG

    # Test: compute 2G using mult
    result = to_affine(*point_mult(2, G))
    assert result == twoG, f"Test failed: compute 2G using mult()\nExpected:\n{twoG}\nGot:\n{result}"

    # Test: compute 5G from twoG using proj_add and proj_dbl
    result = to_affine(*proj_add(*G, *proj_dbl(*to_proj(*twoG))))
    assert result == fiveG, f'\nExpected\n{fiveG}\nGot\n {result}\n'

    # Test: compute 5G using mult
    result = to_affine(*point_mult(5, G))
    assert result == fiveG, f'\nExpected\n{fiveG}\nGot\n {result}\n'

    # Test: compute aG using mult
    result = to_affine(*point_mult(exp_a, G))
    assert result == aG, f'\nExpected\n{aG}\nGot\n {result}\n'
