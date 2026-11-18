# Bioinformatics_start_up

Setup script for a fresh Ubuntu 24.04 LTS bioinformatics / computational chemistry workstation.

## Usage

```bash
sudo su
bash installenv-ubuntu24.04_withAnaconda.sh
```

The script asks for your username. Some installers also stop and wait for input while it runs.

## What it installs

- **General:** vim, git, cmake, g++, LaTeX (texlive, texstudio), VS Code, RStudio, R
- **Python:** Anaconda, with conda envs for `acpype`, `ambertools`, `pyemma257`
- **Structural biology:** PyMOL (open-source), MODELLER, VMD 1.9.3, Jalview, MUSCLE
- **Docking:** AutoDock, AutoDock Vina, QVina, vinaXB, smina
- **MD / electrostatics:** GROMACS 2024 (built from source), PROPKA, PDB2PQR
- **GPU:** NVIDIA CUDA toolkit 13.2

When it finishes, leave the superuser shell. Then run `conda init bash` and `source ~/.bashrc`.
