# ****************************************************************************
#  Experimental rsearch on rotational-add diffusion layers
#  Goal: characterization and construction of MDS rot-add diffusion layers
#
#  Codes written by Baofeng Wu (wubaofeng@iie.ac.cn)
#  Date: August 2025
#  Currently a plain impl; more optimizations needed.
# ****************************************************************************

from sage.matrix.constructor import matrix_method


class RotAddDiffLayer:
    """
    A class representing a rotational-add diffusion layer 
    L_{n,m}(I cup J) over (Fp^m)^n.
    EXAMPLES:
        sage: layer = RotAddDiffLayer(3, 4, 4, [0, 8, 12], [4])
        sage: layer.diffusion_matrix_overFp_blockwise()
        [1 0 1 0|0 0 2 0|0 0 2 0|1 0 0 0]
        [0 1 0 1|0 0 0 2|0 0 0 2|0 1 0 0]
        [0 0 1 0|1 0 0 0|2 0 0 0|2 0 1 0]
        [0 0 0 1|0 1 0 0|0 2 0 0|0 2 0 1]
        [-------+-------+-------+-------]
        [1 0 0 0|1 0 1 0|0 0 2 0|0 0 2 0]
        [0 1 0 0|0 1 0 1|0 0 0 2|0 0 0 2]
        [2 0 1 0|0 0 1 0|1 0 0 0|2 0 0 0]
        [0 2 0 1|0 0 0 1|0 1 0 0|0 2 0 0]
        [-------+-------+-------+-------]
        [0 0 2 0|1 0 0 0|1 0 1 0|0 0 2 0]
        [0 0 0 2|0 1 0 0|0 1 0 1|0 0 0 2]
        [2 0 0 0|2 0 1 0|0 0 1 0|1 0 0 0]
        [0 2 0 0|0 2 0 1|0 0 0 1|0 1 0 0]
        [-------+-------+-------+-------]
        [0 0 2 0|0 0 2 0|1 0 0 0|1 0 1 0]
        [0 0 0 2|0 0 0 2|0 1 0 0|0 1 0 1]
        [1 0 0 0|2 0 0 0|2 0 1 0|0 0 1 0]
        [0 1 0 0|0 2 0 0|0 2 0 1|0 0 0 1]
    Note: 2 = -1 in F_3
    """

    def __init__(
        self, p: int, dim: int, block_size: int, I: list[int], J: list[int] = []
    ):
        self.p = p
        self.dim = dim
        self.block_size = block_size
        self.I = I
        self.J = J
        if any(i in self.I for i in self.J) or any(
            i >= self.dim * self.block_size for i in self.I + self.J
        ):
            raise ValueError("Sets I and J must be disjoint and in the right range.")

    def __repr__(self):
        msg = (
            f"Rotational-add diffusion layer L_{self.dim, self.block_size} over "
            f"F_{self.p} with (I={self.I}, J={self.J})"
        )
        return msg

    def __str__(self):
        msg = (
            f"Rotational-add diffusion layer L_{self.dim, self.block_size} over "
            f"F_{self.p} with (I={self.I}, J={self.J})"
        )
        return msg

    def linear_diffusion(self, input_vector: list[int]) -> list:
        """
        Apply the linear diffusion layer to the input vector.
        Entries of input_vector are integers modulo p.
        """
        F = GF(self.p)
        inout_length = self.dim * self.block_size
        if len(input_vector) != inout_length:
            raise ValueError("Input vector length must match the dimension of the layer.")

        output_vector = vector(F, [0] * inout_length)
        for idx in self.I:
            output_vector += vector(F, input_vector[idx:]+input_vector[:idx])
        for idx in self.J:
            output_vector -= vector(F, input_vector[idx:]+input_vector[:idx])

        return output_vector.list()

    def transposed_diffusion_layer(self):
        """
        Return the transposed diffusion layer.
        """
        width = self.dim * self.block_size
        new_I = [(width - i) % width for i in self.I]
        new_J = [(width - j) % width for j in self.J]

        return self.__class__(self.p, self.dim, self.block_size, new_I, new_J)

    @matrix_method
    def diffusion_matrix_overZ(self) -> Matrix:
        """
        Return the circulant matrix representation for the rotational-add 
        diffusion layer as a matrix over ZZ.
        The purpose of this function is to show the distribution of 1, -1, 
        and 0 in the matrix.
        """
        first_row = [0] * (self.dim * self.block_size)
        for i in self.I:
            first_row[i] = 1
        for j in self.J:
            first_row[j] = -1

        return matrix.circulant(first_row)

    @matrix_method
    def diffusion_matrix_overFp(self) -> Matrix:
        """
        Return the circulant matrix representation for the rotational-add 
        diffusion layer as a matrix over Fp.
        """
        return self.diffusion_matrix_overZ().mod(self.p).lift_centered()

    @matrix_method
    def diffusion_matrix_overZ_blockwise(self) -> Matrix:
        """
        Return blockwise form of the diffusion matrix over Z.
        """
        M = self.diffusion_matrix_overZ()
        divisions = [i * self.block_size for i in range(1, self.dim)]
        M.subdivide(divisions, divisions)
        return M

    def diffusion_matrix_overZ_first_blockrow(self) -> list[Matrix]:
        """
        Return the first block row of the diffusion matrix over Z.
        """
        M = self.diffusion_matrix_overZ_blockwise()
        return [M.subdivision(0, i) for i in range(self.dim)]

    @matrix_method
    def diffusion_matrix_overFp_blockwise(self) -> Matrix:
        """
        Return blockwise form of the diffusion matrix over Fp.
        """
        return self.diffusion_matrix_overZ_blockwise().mod(self.p)

    def diffusion_matrix_overFp_first_blockrow(self) -> list[Matrix]:
        """
        Return the first block row of the diffusion matrix over Fp.
        """
        blocks = self.diffusion_matrix_overZ_first_blockrow()
        return [B.mod(self.p) for B in blocks]

    def associate_polynomial_overZ(self) -> Polynomial:
        """
        Return the associated polynomial of the diffusion matrix over Z.
        To show the poly with coefficients {1, -1, 0}
        """
        R.<x> = QQ[]
        return sum(x^i for i in self.I) - sum(x^j for j in self.J)

    def associate_polynomial_overFp(self) -> Polynomial:
        """
        Return the associated polynomial of the diffusion matrix over Fp.
        """
        F = GF(self.p)
        return self.associate_polynomial_overZ().change_ring(F)

    def is_invertible_overFp(self) -> bool:
        """
        Check if the diffusion layer is invertible over Fp.
        """
        R.<x> = GF(self.p)[]        
        poly = self.associate_polynomial_overFp()
        mod_poly = x^(self.dim * self.block_size) - 1
        gcd = poly.gcd(mod_poly)
        return gcd.degree() == 0

    def primes_dividing_determinant(self) -> list[int]:
        """
        Return a list of primes dividing the determinant of the 
        diffusion matrix over Z.
        """
        det = self.diffusion_matrix_overZ().determinant()
        if det == 0:
            return f'The determinant is zero over ZZ.'
        return prime_factors(det)

    def inverse_associate_polynomial_overZ(self) -> Polynomial:
        """
        Return the inverse associated polynomial of the diffusion layer 
        over Q, if it exists.
        This is to show general representation of the inverse ignoring p.
        """        
        R.<x> = QQ[]
        mod_poly = x^(self.dim * self.block_size) - 1
        poly = self.associate_polynomial_overZ()
        gcd, s, _ = xgcd(poly, mod_poly)
        if gcd.degree() != 0:
            raise ValueError("The diffusion layer is not invertible over QQ.")
        return s.mod(mod_poly)

    def inverse_associate_polynomial_overFp(self) -> Polynomial:
        """
        Return the inverse associated polynomial of the diffusion layer 
        over Q, if it exists.
        This is to show general representation of the inverse ignoring p.
        """
        if not self.is_invertible_overFp():
            raise ValueError("The diffusion layer is not invertible over Fp.")

        F = GF(self.p)
        R.<x> = F[]
        mod_poly = x^(self.dim * self.block_size) - 1
        poly = self.associate_polynomial_overFp()
        return poly.inverse_mod(mod_poly)

    @matrix_method
    def inverse_diffusion_matrix_overFp(self) -> Matrix:
        """
        Return the inverse of the diffusion matrix over Fp.
        """
        if not self.is_invertible_overFp():
            raise ValueError("The diffusion layer is not invertible over Fp.")

        R.<x> = GF(self.p)[]
        inv_poly = self.inverse_associate_polynomial_overFp()
        coefficients = [inv_poly[i] for i in range(self.dim * self.block_size)]
        return matrix.circulant(coefficients)

    def inverse_linear_diffusion(self, input_vector: list[int]) -> list:
        """
        Apply the linear diffusion layer to the input vector.
        Entries of input_vector are integers modulo p.
        """
        if not self.is_invertible_overFp():
            raise ValueError("The diffusion layer is not invertible over Fp.")

        F = GF(self.p)
        inout_length = self.dim * self.block_size
        if len(input_vector) != inout_length:
            raise ValueError(
                "Input vector length must match the dimension of the inverse layer."
            )

        input_vector = vector(F, input_vector)
        inv_diff_mat = self.inverse_diffusion_matrix_overFp()
        return (inv_diff_mat * input_vector).list()

    def is_inverse_rotadd(self) -> bool:
        """
        Check if the inverse of self is also rot-add over Fp.
        """
        if not self.is_invertible_overFp():
            raise ValueError("The diffusion layer is not invertible over Fp.")

        F = GF(self.p)
        inv_poly = self.inverse_associate_polynomial_overFp()
        return Set(inv_poly.coefficients()).issubset(Set([F(1), F(-1)]))

    def is_inverse_quasi_rotadd(self) -> bool:
        """
        Check if the inverse of self is quasi-rot-add over Fp.
        quasi-rot-add = nonzero-constant * rot-add
        """
        if not self.is_invertible_overFp():
            raise ValueError("The diffusion layer is not invertible over Fp.")

        F = GF(self.p)
        inv_poly_coeffs = self.inverse_associate_polynomial_overFp().coefficients()
        distinct_coeffs = Set(inv_poly_coeffs)
        return all(
            c/inv_poly_coeffs[0] in [F(1), F(-1)] for c in distinct_coeffs
        )

    @staticmethod
    def kord_rowcol_pairs(n: int, k: int) -> list[tuple[int, int]]:
            all_subsets = Subsets(range(n), k)
            all_subsets_tuples = [tuple(s) for s in all_subsets]

            def translate(s, d, n):
                return tuple(sorted((x + d) % n for x in s))

            excluded_pairs = []
            for I in all_subsets_tuples:
                for J in all_subsets_tuples:
                    if (I, J) in excluded_pairs:
                        continue
                    else:
                        for d in range(n):
                            I1 = translate(I, d, n)
                            J1 = translate(J, d, n)
                            excluded_pairs.append((I1, J1))
                        yield (I, J)

    def is_MDS(self) -> bool:
        """
        Check if the diffusion layer is MDS over Fp.
        """
        M = self.diffusion_matrix_overFp_blockwise()

        if not self.is_invertible_overFp():
            return False

        for i in range(self.dim):
            if not M.subdivision(0, i).is_invertible():
                return False

        for k in range(2, self.dim):
            for (I, J) in self.kord_rowcol_pairs(self.dim, k):
                kord_submat = block_matrix(
                    [M.subdivision(i, j) for i in I for j in J], ncols=k
                )
                if not kord_submat.is_invertible():
                    return False

        return True

    def primes_for_nonMDS(self):
        """
        Return a set of primes for which the diffusion layer is not MDS over Fp, 
        together with a dict with keys the minors and values the corresponding primes.
        Note: for a minor, the value being [] means it is 1 or -1.
        """
        non_mds_primes = dict()

        M = self.diffusion_matrix_overZ_blockwise()
        if M.determinant() == 0:
            msg = (
                f'{self.__str__()} is not MDS over Fp for any prime p, '
                f'having zero determinant.'
            )
            return msg
        non_mds_primes['whole mat'] = prime_factors(M.determinant())

        for i in range(self.dim):
            det = M.subdivision(0, i).determinant()
            if det == 0:
                msg = (
                    f'{self.__str__()} is not MDS over Fp for any prime p, '
                    f'having a zero {(0,i)}-th 1-minor.'
                )
                return msg
            non_mds_primes[f'{(0, i)}-th 1-monor'] = prime_factors(det)

        for k in range(2, self.dim):
            for (I, J) in self.kord_rowcol_pairs(self.dim, k):
                kord_submat = block_matrix(
                    [M.subdivision(i, j) for i in I for j in J], ncols=k
                )
                det = kord_submat.determinant()
                if det == 0:
                    msg = (
                        f'{self.__str__()} is not MDS over Fp for any prime p, '
                        f'having a zero {(I,J)}-th {k}-minor.'
                    )
                    return msg
                non_mds_primes[f'{(I, J)}-th {k}-minor'] = prime_factors(det)

        all_primes = set().union(*non_mds_primes.values())
        return all_primes, non_mds_primes

    def print_formated_nonMDS_primes(self):
        """
        Format print all_primes and non_mds_primes (exluding empty values).
        """
        results = self.primes_for_nonMDS()
        if type(results) == str:
            print(results)
        else:
            primes, detailed = results
            print('**********************************************************')
            print(f'All appearing primes: {primes}')
            print('**********************************************************')
            for key, value in detailed.items():
                if value:
                    print(f'{key}: {set(value)}')
                    print('**********************************************************')


class FourOrdRotAddDiffLayer(RotAddDiffLayer):
    """
    A subclass of RotAddDiffLayer for the case of dim = 4.
    """

    def __init__(
        self, p: int, block_size: int, I: list[int], J: list[int] = []
    ):
        dim = 4        
        super().__init__(p, dim, block_size, I, J)

    @property
    def four_blocks(self) -> list[Matrix]:
        """
        Returns the four blocks of the diffusion matrix over ZZ.
        """
        return self.diffusion_matrix_overZ_first_blockrow()

    @property
    def ord2_submats(self):
        """
        Return a generator of 2-ord submatrices involved in the 
        checking of MDS property.
        """
        A, B, C, D = self.four_blocks
        yield block_matrix([A, B, D, A], ncols=2)
        yield block_matrix([A, C, D, B], ncols=2)
        yield block_matrix([A, D, D, C], ncols=2)
        yield block_matrix([B, C, A, B], ncols=2)
        yield block_matrix([B, D, A, C], ncols=2)
        yield block_matrix([C, D, B, C], ncols=2)
        yield block_matrix([A, B, C, D], ncols=2)
        yield block_matrix([A, C, C, A], ncols=2)
        yield block_matrix([A, D, C, B], ncols=2)
        yield block_matrix([B, D, D, B], ncols=2)

    @property
    def ord3_submats(self):
        """
        Return a generator of 3-ord submatrices involved in the 
        checking of MDS property.
        """
        A, B, C, D = self.four_blocks
        yield block_matrix([[A, B, C], [D, A, B], [C, D, A]])
        yield block_matrix([[A, B, D], [D, A, C], [C, D, B]])
        yield block_matrix([[A, C, D], [D, B, C], [C, A, B]])
        yield block_matrix([[B, C, D], [A, B, C], [D, A, B]])

    def is_MDS(self) -> bool:
        """
        Check if the diffusion layer is MDS over Fp.
        """
        F = GF(self.p)
        if not self.is_invertible_overFp():
            return False

        for block in self.four_blocks:
            if not block.change_ring(F).is_invertible():
                return False

        for submat in self.ord2_submats:
            if not submat.change_ring(F).is_invertible():
                return False

        for submat in self.ord3_submats:
            if not submat.change_ring(F).is_invertible():
                return False

        return True

    def primes_for_nonMDS(self):
        """
        Return a set of primes for which the diffusion layer is not MDS over Fp, 
        together with a dict with keys the minors and values the corresponding primes.
        Note: for a minor, the value being [] means it is 1 or -1.
        """
        a, b, c, d = var('A, B, C, D')
        symb_ord1_submats = [a, b, c, d]
        symb_ord2_submats = [
            matrix([a, b, d, a], ncols=2),
            matrix([a, c, d, b], ncols=2),
            matrix([a, d, d, c], ncols=2),
            matrix([b, c, a, b], ncols=2),
            matrix([b, d, a, c], ncols=2),
            matrix([c, d, b, c], ncols=2),
            matrix([a, b, c, d], ncols=2),
            matrix([a, c, c, a], ncols=2),
            matrix([a, d, c, b], ncols=2),
            matrix([b, d, d, b], ncols=2)
        ]
        symb_ord3_submats = [
            matrix([[a, b, c], [d, a, b], [c, d, a]]),
            matrix([[a, b, d], [d, a, c], [c, d, b]]),
            matrix([[a, c, d], [d, b, c], [c, a, b]]),
            matrix([[b, c, d], [a, b, c], [d, a, b]])
        ]
        symb_submats = [symb_ord1_submats, symb_ord2_submats, symb_ord3_submats]

        non_mds_primes = dict()
        all_submats = [self.four_blocks, self.ord2_submats, self.ord3_submats]
        for k, submats in enumerate(all_submats):
            for i, submat in enumerate(submats):
                det = submat.determinant()
                if det == 0:
                    msg = (
                        f'{self.__str__()} is not MDS over Fp for any prime p, '
                        f'having a zero {k+1}-minor {symb_submats[k][i]}.'
                    )
                    return msg
                non_mds_primes[f'{symb_submats[k][i]}'] = prime_factors(det)

        M = self.diffusion_matrix_overZ_blockwise()
        if M.determinant() == 0:
            msg = (
                f'{self.__str__()} is not MDS over Fp for any prime p, '
                f'having zero determinant.'
            )
            return msg
        non_mds_primes['whole mat'] = prime_factors(M.determinant())

        all_primes = set().union(*non_mds_primes.values())
        return all_primes, non_mds_primes


# ****************************************************************************
# some special matrices used in the study
# ****************************************************************************

@matrix_method
def upper_shift_matrix(nrows, ring=ZZ) -> Matrix:
    """
    Return the upper shift matrix of size `nrows x nrows`.
    EXAMPLES:
        sage: M = matrix.upper_shift(4)
        sage: M
        [0 1 0 0]
        [0 0 1 0]
        [0 0 0 1]
        [0 0 0 0]
    """
    return matrix(nrows, nrows, lambda i, j: int(j == i + 1), base_ring=ring)

@matrix_method
def lower_shift_matrix(nrows, ring=ZZ) -> Matrix:
    """
    Return the lower shift matrix of size `nrows x nrows`.
    EXAMPLES:
        sage: M = matrix.lower_shift(4)
        sage: M
        [0 0 0 0]
        [1 0 0 0]
        [0 1 0 0]
        [0 0 1 0]
    """
    return matrix(nrows, nrows, lambda i, j: int(j == i - 1), base_ring=ring)

@matrix_method
def cyclic_shift_matrix(nrows, ring=ZZ) -> Matrix:
    """
    Return the cyclic permutation matrix of size `nrows x nrows`.
    EXAMPLES:
        sage: M = matrix.cyclic_shift(4)
        sage: M
        [0 1 0 0]
        [0 0 1 0]
        [0 0 0 1]
        [1 0 0 0]
    """
    return matrix(
        nrows, nrows, lambda i, j: int(j == (i + 1) % nrows), base_ring=ring
    )