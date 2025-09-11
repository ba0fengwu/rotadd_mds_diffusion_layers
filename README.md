# RotAdd_MDS_diffusion_layers
Codes for the paper "MDS Diffusion Layers for Arithmetization-Oriented Symmetric Ciphers: The Rotational-Add Construction" (ToSC 2025 issue 3).

Clone the repository by
```bash
git clone recurse-submodules https://github.com/ba0fengwu/rotadd_mds_diffusion_layers.git
```

---

### 1. Analysis properties of ratational-add diffusion layers and construct explicit class of MDS ones

The directory `rotadd_diff_layer/` contains:
- Sagemath implementations of the class `RotAddDiffLayer` and its subclass `FourOrdRotAddDiffLayer`, including several methods for stadying the properties of rotational-add diffusion layers, such as:
    - `diffusion_matrix_overFp_blockwise`: generate blockwise form of the diffusion matrix over Fp;
    - `is_invertible_overFp`: check if the diffusion layer is invertible over Fp;
    - `inverse_linear_diffusion`: inverse of the linear diffusion layer;
    - `is_MDS`: check whether the layer is MDS.

- sage scripts for generating results in Appendix A and Appendix B of the paper.

```bash
$ cd rotadd_diff_layer
$ sage search_light_mds_L4m.sage # generate results in Append. A of the paper
$ sage construct_light_mds_L4m.sage # generate results in Append. B of the paper
$ sage inverse_light_mds_L4m.sage # generate inverses of MDS constructions in Append. B
```

---

### 2. Test efficiency of  YuX_dag and YuX
The directory `Yux_dag_efficiency_test` contains:
- the git submodule `Yux_FHE_HElib` is a fork of the repository of YuX at: `https://github.com/YuXenc/Yux_FHE_HElib`, including two git branches:
    - the `Yux_original` branch includes original codes of YuX;
    - the `main` branch includes codes of YuX_dag and YuX to perform the test;
    - implementation of YuX_dag comes from directly replacing the linear diffusion layer of YuX with a rotational-add diffusion layer using 5 rotations.
- a bash scripts to run efficiency test of YuX_dag and YuX, outputing logs including the runtime and throughtput.

To perform the test, you should install the homomomorphic encryption scheme library HElib first. Follow the instructions in `https://github.com/homenc/HElib/blob/master/INSTALL.md` to install it and we suggest the library build method (Option 1). 
```bash
$ git clone https://github.com/homenc/HElib.git
$ cd HElib
$ mkdir build
$ cd build
$ cmake -DPACKAGE_BUILD=ON ..
$ make -j$(nproc)
$ sudo make install
```
For a root user, the default path of HElib is `/usr/local/helib_pack/`. If HElib is installed in another path, you should modify the path in `target_include_directories()` in `Yux_FHE_HElib/CMakeLists.txt` to your path of HElib before compiling.

After installing HElib, you can build YuX_dag and YuX by
```bash
$ cd Yux_dag_efficiency_test/Yux_FHE_HElib
$ git checkout main
$ mkdir build
$ cd build
$ cmake ..
$ make
```

Then go back to the directory `Yux_dag_efficiency_test` and run the bash script `run_with_logging.sh` to perform the test. The results will be outputed to `Yux_dag_efficiency_test/logs/`.

(1)
```bash
$ ./run_with_logging.sh ./Yux_FHE_HElib/tests/test-blockcipher-F_p
$ ./run_with_logging.sh ./Yux_FHE_HElib/tests/test-blockcipher-dagger-F_p
```
This can generate:
- `test-blockcipher-F_p.log` (runtime and throughput of the plain implemented Yux encryption algorithm at 9, 12, and 14 rounds respectively)
- `test-blockcipher-dagger-F_p.log ` (runtime and throughput of the plain implemented Yux_dagger encryption algorithm at 9, 12, and 14 rounds respectively)

(2) 
```bash
$ ./run_with_logging.sh ./Yux_FHE_HElib/tests/test-transciphering-F_p-16
$ ./run_with_logging.sh ./Yux_FHE_HElib/tests/test-transciphering-dagger-F_p-16
``` 
This can generate:
- `test-transcipheringr-F_p-16(9).log` (runtime and throughput of the homomorphic implementation of the Yux decryption algorithm at 9 rounds)
- `test-transciphering-dagger-F_p-16(9).log` (runtime and throughput of the homomorphic implementation of the Yux_dagger decryption algorithm at 9 rounds) 
 
(3)   Change the pROUND parameter to 12 in the file `Yux_FHE_HElib/transciphering/param.h` by replacing `static long pROUND = 9`  to `static long pROUND = 12`，and rebuild the project. Then run
```bash
$ ./run_with_logging.sh ./Yux_FHE_HElib/tests/test-transciphering-F_p-16
$ ./run_with_logging.sh ./Yux_FHE_HElib/tests/test-transciphering-dagger-F_p-16
```  
 This can generate: 
 - `test-transcipheringr-F_p-16(12).log` (runtime and throughput of the homomorphic implementation of the Yux decryption algorithm at 12 rounds)
- `test-transciphering-dagger-F_p-16(12).log` (runtime and throughput of the homomorphic implementation of the Yux_dagger decryption algorithm at 12 rounds) 
  
(4) Change the pROUND parameter to 14 in the file `Yux_FHE_HElib/transciphering/param.h` by replacing `static long pROUND = 9`  to `static long pROUND = 14`，and rebuild the project. Then run
```bash
$ ./run_with_logging.sh ./Yux_FHE_HElib/tests/test-transciphering-F_p-16
$ ./run_with_logging.sh ./Yux_FHE_HElib/tests/test-transciphering-dagger-F_p-16
```  
 This can generate: 
 - `test-transcipheringr-F_p-16(14).log` (runtime and throughput of the homomorphic implementation of the Yux decryption algorithm at 14 rounds)
- `test-transciphering-dagger-F_p-16(14).log` (runtime and throughput of the homomorphic implementation of the Yux_dagger decryption algorithm at 14 rounds) 

