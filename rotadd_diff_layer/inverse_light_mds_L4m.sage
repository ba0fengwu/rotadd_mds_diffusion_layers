# ****************************************************************************
#  Comput inverses of explicit constructions of MDS rot-add diffusion 
#  layers in three cases
#  Baofeng Wu, Aug 2025
#  ⚠ In the output file, the inverse poly may be very long, please 
#    "disable word wrap" in your text editor to view it properly.
# ****************************************************************************

def get_data(file_path):
    data = []
    with open(file_path, 'r') as f:
        content = f.readlines()
        for line in content[4::2]:
            line_data = line.split('│ ')
            line_data = [x.strip() for x in line_data]
            line_data.remove('')
            line_data[2] = line_data[2].strip('│').strip()
            data.append(line_data)

    return data


files = {
    'Case 2': 'results/constructions_mds_L4m_Case 2.txt',
    'Case 4': 'results/constructions_mds_L4m_Case 4.txt',
    'Case 12': 'results/constructions_mds_L4m_Case 12.txt'
}
coefficients = {
    'Case 2': [-1, 1, 1, 1, 1],
    'Case 4': [1, 1, -1, 1, 1],
    'Case 12': [1, -1, 1, -1, 1]
}
R.<x> = QQ[]

for case, file in files.items():
    try:
        all_data = get_data(file)
    except FileNotFoundError:
        print(f'File {file} not found. Run construct_light_ ... first.')
        continue

    result = []
    poly_width = 0
    for data in all_data:
        t = int(data[0].split('|')[0])
        k = data[1].split('m')[0]
        if not k:
            k = 1
        else:
            k = int(k)

        if data[2] == '--':
            result.append(data[:2] + ['--', '--'])
        else:
            c = coefficients[case]
            poly = c[0] + c[1]*x^(k) + c[2]*x^(k+t) + c[3]*x^(k+2*t) + c[4]*x^(3*t)
            mod_poly = x^(4*t) - 1
            inv_poly = poly.inverse_mod(mod_poly)
            denominator = inv_poly.denominator()
            """
            LCM of denominators of coefficients of the inverse poly.
            Divisors of denominator are included in the 'excluded primes'
            in the construction of the MDS diff layer.
            """
            poly_width = max(poly_width, len(str(inv_poly)))
            result.append(data[:2] + [inv_poly, denominator])

    with open(f'results/inverses_mds_L4m_{case}.txt', 'w') as f:
        f.write(f'Inverses of example constructions in {case},\n')
        f.write(f'represented by inverse associated poly.\n\n')
        header = [
            "condition t|m",
            "g2=km/t",
            "f(x) s.t. inverse = f(x)◦x^(m/t)",
            "denominator of f"
        ]
        result = table(result, header_row=header, frame=True)
        f.write(str(result))

    print(f'Results saved to: results/inverses_mds_L4m_{case}.txt')

