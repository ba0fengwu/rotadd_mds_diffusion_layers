# ****************************************************************************
#  Exhaustive search of MDS rotational-add diffusion layers
#  Goal: fix m, search all MDS L4m having rotational offsets of weight 5
#
#  Baofeng Wu, Aug 2025
# ****************************************************************************

load("rotadd_diff_layer.sage")


def generate_IJ_pairs(offset: list[int]) -> list:
    offset = sorted(offset)
    pairs = []
    for k in range(len(offset) // 2 + 1):
        for s in Combinations(offset, k):
            s_bar = [i for i in offset if i not in s]
            pairs.append((sorted(s_bar), s))

    return pairs


def search_light_mds_L4m(p: int, m: int, g2: int) -> list:
    offset = [0, g2, g2 + m, g2 + 2 * m, 3 * m]
    IJ_pairs = generate_IJ_pairs(offset)

    mds_cases = []
    L = FourOrdRotAddDiffLayer(p, m, [], [])

    for i, (I, J) in enumerate(IJ_pairs):
        L.I, L.J = I, J
        if L.is_MDS():
            mds_cases.append([f"Case {i + 1}", g2, I, J])

    return mds_cases


def main():
    p = 65537
    ms = [4, 8]
    g2_lists = {m: range(1, m) for m in ms}

    all_mds_cases = dict()
    for m, g2s in g2_lists.items():
        all_mds_cases[m] = []
        for g2 in g2s:
            mds_cases = search_light_mds_L4m(p, m, g2)
            all_mds_cases[m].extend(mds_cases)
        all_mds_cases[m].sort(key=lambda x: int(x[0].split()[1]))

    for m in ms:
        results = table(
            all_mds_cases[m], header_row=["Case", "g2", "I", "J"], frame=True
        )
        with open(f"./results/light_mds_L4m_m{m}.txt", "w") as f:
            f.write(f"m = {m}\n")
            f.write(str(results))


if __name__ == "__main__":
    main()
