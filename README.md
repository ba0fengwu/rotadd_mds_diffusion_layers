# RotAdd_MDS_diffusion_layers
Codes for the paper "MDS Diffusion Layers for Arithmetization-Oriented Symmetric Ciphers: The Rotational-Add Construction" (ToSC 2025 issue 3).

Clone the repository by
```bash
git clone --recurse-submodules https://github.com/ba0fengwu/rotadd_mds_diffusion_layers.git
```

---

### 1. Analyse properties of rotational-add diffusion layers and construct explicit class of MDS ones

The directory `rotadd_diff_layer/` contains:
- Sagemath implementations of the class `RotAddDiffLayer` and its subclass `FourOrdRotAddDiffLayer`, including several methods for studying the properties of rotational-add diffusion layers, such as:
    - `diffusion_matrix_overFp_blockwise`: generate blockwise form of the diffusion matrix over Fp;
    - `is_invertible_overFp`: check if the diffusion layer is invertible over Fp;
    - `inverse_linear_diffusion`: inverse of the linear diffusion layer;
    - `is_MDS`: check whether the diffusion layer is MDS.

- sage scripts for generating results in Appendix A and Appendix B of the paper.

```bash
$ cd rotadd_diff_layer
$ sage search_light_mds_L4m.sage # Generate all MDS L4m with rotation offsets of weight 5 with multiple values of m, and record the results in separate `.txt` files. Among them, `light_mds_L4m_m4.txt` and `light_mds_L4m_m8.txt` correspond to Table 3 and Table 4 in Append. A of the paper, respectively.
$ sage construct_light_mds_L4m.sage # Generate Table 5, Table 6 and Table 7 in Append. B of the paper.
$ sage inverse_light_mds_L4m.sage # Generate inverses of MDS constructions in Append. B, which are supplementary results not included in the paper.
```

All results will be saved to the `rotadd_diff_layer/results` directory. Note that some result files contain very broad tables. Please 
"disable word wrap" in your text editor to view it properly.

---

### 2. Test efficiency of YuX_dag and YuX
The directory `Yux_dag_efficiency_test` contains:
- the git submodule `Yux_FHE_HElib`, a fork of the repository of YuX at: `https://github.com/YuXenc/Yux_FHE_HElib`, including two git branches:
    - the `Yux_original` branch includes original codes of YuX;
    - the `main` branch includes codes of YuX_dag and YuX to perform the test;
    - implementation of YuX_dag comes from direct replacement of the linear diffusion layer of YuX with a rotational-add diffusion layer using 5 rotations.
- a bash script to run efficiency test of YuX_dag and YuX, outputing logs including the runtime and throughtput.

To perform the test, you should install the homomomorphic encryption library HElib first. Follow the instructions in `https://github.com/homenc/HElib/blob/master/INSTALL.md` to install it and we suggest the library build method (Option 1). 
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
$ cmake .. # if HElib is not installed in the default path, use "cmake -DCMAKE_PREFIX_PATH=/your_path/helib_install .." instead
$ make
```

Then go back to the directory `Yux_dag_efficiency_test` and run the bash script `run_with_logging.sh` to perform the test. The results will be outputted to `Yux_dag_efficiency_test/logs/`.

**Note on Test Duration:**
Testing the plain implementation of the encryption algorithm (1,000 iterations) is extremely fast, completing in milliseconds. In contrast, testing the homomorphic implementation of the decryption algorithm (100 iterations) is time-consuming, taking approximately 2, 6 and 9 hours for 9, 12 and 14 rounds, respectively.

(1)
```bash
$ ./run_with_logging.sh tests/test-blockcipher-F_p
$ ./run_with_logging.sh tests/test-blockcipher-dagger-F_p
```
This can generate (`***` represents the timestamp):
- `test-blockcipher-F_p_***.log`: contains the runtime and throughput for the plain implementation of the Yux encryption algorithm with 9, 12 and 14 rounds, corresponding to the first three rows in Table 2 of the paper.
- `test-blockcipher-dagger-F_p_***.log `: contains the runtime and throughput for the plain implementation of the Yux_dagger encryption algorithm with 9, 12 and 14 rounds, corresponding to the last three rows in Table 2. 

(2) 
```bash
$ ./run_with_logging.sh tests/test-transciphering-F_p-16
$ ./run_with_logging.sh tests/test-transciphering-dagger-F_p-16
``` 
This can generate (`***` represents the timestamp):
- `test-transciphering-F_p-16_***.log`: contains the runtime and throughput for the homomorphic implementation of the Yux decryption algorithm with 9 rounds, corresponding to the first row in Table 1.
- `test-transciphering-dagger-F_p-16_***.log`: contains the runtime and throughput for the homomorphic implementation of the Yux_dagger decryption algorithm with 9 rounds, corresponding to the fourth row in Table 1.
 
(3)   Change the pROUND parameter to 12 in the file `Yux_FHE_HElib/transciphering/param.h` by replacing `static long pROUND = 9`  to `static long pROUND = 12`，and rebuild the project. Then run
```bash
$ ./run_with_logging.sh tests/test-transciphering-F_p-16
$ ./run_with_logging.sh tests/test-transciphering-dagger-F_p-16
```  
 This can generate (`***` represents the timestamp): 
 - `test-transciphering-F_p-16_***.log`: contains the runtime and throughput for the homomorphic implementation of the Yux decryption algorithm with 12 rounds, corresponding to the second row in Table 1.
- `test-transciphering-dagger-F_p-16_***.log`: contains the runtime and throughput for the homomorphic implementation of the Yux_dagger decryption algorithm with 12 rounds, corresponding to the fifth row in Table 1.

(4) Change the pROUND parameter to 14 in the file `Yux_FHE_HElib/transciphering/param.h` by replacing `static long pROUND = 9`  to `static long pROUND = 14`，and rebuild the project. Then run
```bash
$ ./run_with_logging.sh tests/test-transciphering-F_p-16
$ ./run_with_logging.sh tests/test-transciphering-dagger-F_p-16
```  
 This can generate (`***` represents the timestamp): 
 - `test-transciphering-F_p-16_***.log`: contains the runtime and throughput for the homomorphic implementation of the Yux decryption algorithm with 14 rounds, corresponding to the third row in Table 1.
- `test-transciphering-dagger-F_p-16_***.log`: Contains the runtime and throughput for the homomorphic implementation of the Yux_dagger decryption algorithm with 14 rounds, corresponding to the sixth row in Table 1.

