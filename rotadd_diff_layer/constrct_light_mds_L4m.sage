# ****************************************************************************
#  Explicit constructions of MDS rotational-add diffusion layers
#  in four cases
#
#  Baofeng Wu, Aug 2025
# ****************************************************************************

R.<x> = ZZ[]
POLY_LISTS = {
    'Case 2': [
        x + 1,
        2*x - 1,
        x - 2,
        x^2 - x - 1,
        x^2 - x + 1,
        x^2 - 3*x + 1,
        x^2 - 2*x + 2,
        x^3 - x^2 - 1,
        2*x^3 - 5*x^2 + 3*x + 1,
        x^3 - 4*x^2 + 3*x - 1,
        x^3 - 4*x^2 + 6*x - 1
    ],
    'Case 4_12': [
        2 * x + 1,
        x + 2,
        x^2 - 1,
        x^2 + x - 1,
        x^2 + x + 1,
        x^2 + 3*x + 1,
        x^3 + x^2 + 1,
        x^3 + 4*x^2 + 3 * x + 1,
        x^3 + 4*x^2 + 6*x + 1 ,
        2*x^3 + 5*x^2 + 3*x - 1,
        3*(x^3 + 4*x^2 + 6*x + 4)
    ]
}

def primes_dividing_resultants(poly, poly_list):
    """
    Returns the list of primes dividing the resultants of poly and each 
    polynomial in poly_list.
    """
    resultants = [poly.resultant(p) for p in poly_list]
    if 0 in resultants:
        return []
    primes = set().union(*[prime_factors(poly.resultant(p)) for p in poly_list])
    return sorted(list(primes))


def main(t_max=16):
    results = {'Case 2': [], 'Case 4': [], 'Case 12': []}
    for t in range(2, t_max+1):
        k_list2 = t.coprime_integers(t)
        k_list4_12 = [k for k in k_list2 if k/t > 1/2]
        polys = {
            'Case 2': [(-x)^t - (1-x)^(t-k) for k in k_list2],
            'Case 4': [x^t - (-x-1)^(t-k) for k in k_list4_12],
            'Case 12': [x^t - (-1)^k * (x+1)^(t-k) for k in k_list4_12]
        }

        for case, polys in polys.items():
            for poly in polys:
                if poly.is_irreducible():
                    results[case].append(poly)


