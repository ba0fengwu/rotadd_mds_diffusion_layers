# RotAdd_MDS_diffusion_layers
Codes for the paper "MDS Diffusion Layers for Arithmetization-Oriented Symmetric Ciphers: The Rotational-Add Construction" (ToSC 2025 issue 3).

Clone the repository by
```bash
git clone recurse-submodules https://github.com/ba0fengwu/rotadd_mds_diffusion_layers.git
```

### 1. Analysis properties of ratational-add diffusion layers and construct explicit class of MDS ones

The directory `rotadd_diff_layer/` contains:
- Sagemath implementations of the class `RotAddDiffLayer` and its subclass `FourOrdRotAddDiffLayer`, including several methods for stadying the properties of rotational-add diffusion layers.
- sage scripts for generating results in Appendix A and Appendix B of the paper.

```bash
$ cd rotadd_diff_layer
$ sage search_light_mds_L4m.sage # generate results in Append. A of the paper
$ sage construct_light_mds_L4m.sage # generate results in Append. B of the paper
$ sage inverse_light_mds_L4m.sage # generate inverses of MDS constructions in Append. B
```

### 2. Test efficiency of  YuX_dag and YuX
The directory `Yux_dag_efficiency_test` contains:
- codes from the repository of YuX: `https://github.com/YuXenc/Yux_FHE_HElib`
- implementation of YuX_dag by  directly replacing the linear diffusion layer of YuX with a rotational-add diffusion layer using 5 rotations 
- scripts to test efficiency of YuX_dag and YuX

To perform the test, you should install the homomomorphic encryption scheme library HElib first. Follow the instructions in `https://github.com/homenc/HElib/blob/master/INSTALL.md` to install it and we suggest the library build method. For a root user, the default path of HElib is `/usr/local/helib-pack/`.
```bash
$ git clone https://github.com/homenc/HElib.git
$ cd HElib
$ mkdir build
$ cd build
$ cmake -DPACKAGE_BUILD=ON ..
$ make -j$(nproc)
$ sudo make install
```

