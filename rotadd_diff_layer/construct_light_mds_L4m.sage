# ****************************************************************************
#  Experiments on generate explicit constructions of MDS rot-add diffusion 
#  layers in three cases
#  Baofeng Wu, Aug 2025
# ****************************************************************************

R.<x> = QQ[]
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
    'Case 4': [
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
POLY_LISTS['Case 12'] = POLY_LISTS['Case 4']


def primes_dividing_resultants(poly, poly_list):
    """
    Returns the list of primes dividing the resultants of poly and each 
    polynomial in poly_list.
    """
    resultants = [poly.resultant(p) for p in poly_list]
    if 0 in resultants:
        return '--'
    primes = set().union(*[prime_factors(poly.resultant(p)) for p in poly_list])
    return sorted(list(primes))


def main(t_max=16):
    results = {'Case 2': [['2|m', 'm/2', [2, 3, 5]]], 'Case 4': [], 'Case 12': []}
    for t in range(3, t_max+1):
        k_lists = {'Case 2': ZZ(t).coprime_integers(t)}
        k_lists['Case 4'] = [k for k in k_lists['Case 2'] if k/t > 1/2]
        k_lists['Case 12'] = k_lists['Case 4']
        deg_t_polys = {
            'Case 2': [(-x)^t - (1-x)^(t-k) for k in k_lists['Case 2']],
            'Case 4': [x^t - (-x-1)^(t-k) for k in k_lists['Case 4']],
            'Case 12': [x^t - (-1)^k * (x+1)^(t-k) for k in k_lists['Case 12']]
        }

        for case, polys in deg_t_polys.items():
            for k, poly in enumerate(polys):
                primes_div_res = primes_dividing_resultants(poly, POLY_LISTS[case])
                g2 = f'{k_lists[case][k]}m/{t}'
                results[case].append([f'{t}|m', g2, primes_div_res])

    for case, result in results.items():
        result = table(result, header_row=["condition m", "g2", "excluded p"], frame=True)

        from pathlib import Path
        file_folder = Path('results')
        file_path = file_folder / f'constructions_mds_L4m_{case}.txt'
        file_folder.mkdir(parents=True, exist_ok=True)
        file_path.write_text(f'Example constructions in {case}\n' + str(result))

        print(f'Results saved to: {file_path.absolute()}')


if __name__ == "__main__":
    main()