# RotAdd_MDS_diffusion_layers
Codes for the paper "MDS Diffusion Layers for Arithmetization-Oriented Symmetric Ciphers: The Rotational-Add Construction" (ToSC 2025 issue 3).

Clone the repository by
```bash
git clone recurse-submodules https://github.com/ba0fengwu/rotadd_mds_diffusion_layers.git
```

### 1. Analysis properties of ratational-add diffusion layers and construct explicit class of MDS ones
```bash
$ cd rotadd_diff_layer
$ sage search_light_mds_L4m.sage # generate results in Append. A of the paper
$ sage construct_light_mds_L4m.sage # generate results in Append. B of the paper
$ sage inverse_light_mds_L4m.sage # generate inverses of MDS constructions in Append. B
```

### 2. Test efficiency of YuX and YuX_dag
