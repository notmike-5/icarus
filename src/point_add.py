'''Test script for looking into point addition/multiplication routines'''
debug = True


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


######################
## Modular Inverses ##
######################
# TODO: complete inversion with square and multiply via montgomery ladder
def inv(x):
    '''Compute modular inverse with square and multiply.'''
    return None


def modp_inv(x):
    '''Compute modular inverse the easy way.'''
    return pow(x, p-2, p)


#######################
## Point Compression ##
#######################

# Square root of -1
modp_sqrt_m1 = pow(2, (p-1) // 4, p)


def recover_x(y, sign):
    '''Compute corresponding x-coordinate, with low bit corresponding
    to sign, or return None on failure'''
    if y >= p:
        return None
    x2 = (y*y-1) * modp_inv(d*y*y+1)
    if x2 == 0:
        if sign:
            return None
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


# Extended (projective)
def to_proj(x, y):
    '''project an affine point to extended/projective coordinates'''
    return (x, y, 1, x*y)


def to_affine(x, y, z, t):
    '''return extended/projective point to affine coordinates'''
    zinv = modp_inv(z)
    return (x*zinv % p, y*zinv % p)

# wrapped exceedingly excessively in parens to convince myself that this method works
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

    if debug:
        print("\nProjective addition of...\n")
        # Point 1
        print(f"P1: ({hex(x1)},{hex(y1)},{hex(z1)},{hex(t1)})")
        print("x1:", hex(x1))
        print("y1:", hex(y1))
        print("z1:", hex(z1))
        print("t1:", hex(t1), "\n")
        # Point 2
        print(f"P2: ({hex(x2)},{hex(y2)},{hex(z2)},{hex(t2)})")
        print("x2:", hex(x2))
        print("y2:", hex(y2))
        print("z2:", hex(z2))
        print("t2:", hex(t2), "\n")
        # A
        print(f"(y1 - x1) : {hex(y1 - x1)}")
        print(f"(y2 - x2) : {hex(y2 - x2)}")
        print(
            f"A = (y1 - x1) * (y2 - x2) : {hex(A)}")
        # B
        print(f"(y1 + x1) : {hex(y1 + x1)}")
        print(f"(y2 + x2) : {hex(y2 + x2)}")
        print(
            f"B = (y1 + x1) * (y2 + x2) : {hex(B)}")
        # C,D
        print(f"C = 2 * t1 * t2 * d : {hex(C)}")
        print(f"D = 2 * z1 * z2 : {hex(D)}")
        # E,F,G,H
        print(f"E = B - A : {hex(E)}")
        print(f"F = D - C : {hex(F)}")
        print(f"G = D + C : {hex(G)}")
        print(f"H = B + A : {hex(H)}")
        # Result
        print(f"\nResult : ({hex((E*F) % p)}, {hex((G*H) % p)}, {hex((F*G) % p)}, {hex((E*H) % p)})")

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

    if debug:
        print("\nProjective doubling of...\n")
        # Point
        print(f"Point: ({hex(x)}, {hex(y)}, {hex(z)}, {hex(t)})")
        print(f"x: {x}")
        print(f"y: {y}")
        print(f"z: {z}")
        print(f"t: {t}\n")
        # A,B,C,H,E,G,F
        print(f"A = x^2 : {hex(A)}")
        print(f"B = y^2 : {hex(B)}")
        print(f"C =  : {hex(C)}")
        print(f"H =  : {hex(H)}")
        print(f"E =  : {hex(E)}")
        print(f"G = A - B : {hex(G)}")
        print(f"F =  : {hex(F)}")
        # Result
        print(f"\nResult : ({hex((E*F)%p)}, {hex((G*H)%p)}, {hex((F*G)%p)}, {hex((E*H)%p)})")

    return ((E*F) % p, (G*H) % p, (F*G) % p, (E*H) % p)


# compute Q = kQ
def mult(k, P):
    '''Point Multiplication (repeated point addition)'''
    Q = (0, 1, 1, 0)  # identity/neutral element
    while k > 0:
        if k & 1:
            Q = proj_add(*Q, *P)
            P = proj_add(*P, *P)  # TODO: consider testing proj_dbl here
            k >>= 1
    return Q


if __name__== "__main__":
    ###########
    ## Tests ##
    ###########

    print("Initiating tests...")

    # Gy = 4 * modp_inv(5) % p
    # Gx = recover_x(Gy, 0)  # TODO: handle point compression
    # G = (Gx, Gy, 1, Gx*Gy % p)
    G = (15112221349535400772501151409588531511454012693041857206046113283949847762202,         46316835694926478169428394003475163141307993866256225615783033603165251855960)
    G = to_proj(*G)


    # Point Projection

    # Test - project a point back-and-forth (without performing any operations)
    print(f'\nStarting Point: \n{G[0], G[1]}')

    # to extended (projective) coordinates
    point = to_proj(G[0], G[1])
    print(f'\nAffine to Projective: \n{point}')

    assert point == (G[0], G[1], 1, G[0] * G[1])

    # back to affine coordinates
    affine = to_affine(*point)
    print(f'\nProjective to Affine: \n{affine}')

    assert affine == (G[0], G[1])

    # Point Addition and Doubling
    # The values 2G and 5G have been generated according to:
    # https://crypto.stackexchange.com/questions/99798/test-vectors-points-for-ed25519
    exp_a = 0x12581e70a192aeb9ac1411b36d11fc06393db55998190491c063807a6b4d730d
    exp_b = 0x0c2340b974bebfb9cb3f14e991bca432b57fb33f7c4d79e15f64209076afcd00

    twoG = (24727413235106541002554574571675588834622768167397638456726423682521233608206, 15549675580280190176352668710449542251549572066445060580507079593062643049417)

    fiveG = (33467004535436536005251147249499675200073690106659565782908757308821616914995,  43097193783671926753355113395909008640284023746042808659097434958891230611693)

    aG = (46953515626174660128743374276590207025464948126956050456964432034683890442435, 43649996176441760651255662656482711906128939437336752974722489909985414406932)

    bG = (48108495825706412711799803692360228025391948835486250305831184019146948949994, 13228837014764440841117560545823854143168584625415590819123131242008409842892)

    # Test - square the order 2 element (0, -1) using affine add() & dbl()
    assert add(0, -1, 0, -1) == (0, 1)
    assert dbl(0, -1) == (0, 1)

    # Test - compute 2G from G using proj_add and proj_dbl
    assert to_affine(*proj_add(*G, *G)) == to_affine(*proj_dbl(*G)) == twoG

    # Test - compute 5G from twoG using proj_add and proj_dbl
    twoG = to_proj(*twoG)
    assert to_affine(*proj_add(*G, *proj_dbl(*twoG))) == fiveG

    # Test - compute aG
    # TODO

    # Test - compute bG
    # TODO
