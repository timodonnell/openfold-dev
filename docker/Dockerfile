FROM --platform=linux/x86_64 nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04 AS base

ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
WORKDIR /root

RUN apt-get update \
    && TZ=Etc/UTC DEBIAN_FRONTEND=noninteractive apt-get install -y \
        wget git libxml2 \
		cuda-minimal-build-11-3 libcusparse-dev-11-3 libcublas-dev-11-3 libcusolver-dev-11-3 \
    && rm -rf /var/lib/apt/lists/* \
    && wget \
      https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh \
    && conda --version

RUN conda update -n base -c defaults conda \
  && conda config --set ssl_verify no \
  && conda init bash \
  && conda clean -af

RUN git clone https://github.com/aqlaboratory/openfold.git && \
	 wget -q -P openfold/openfold/resources \
		https://git.scicore.unibas.ch/schwede/openstructure/-/raw/7102c63615b64735c4941278d92b554ec94415f8/modules/mol/alg/src/stereo_chemical_props.txt

RUN conda env create -n openfold -f openfold/environment.yml \
	&& conda clean --all

RUN patch -p0 -d /root/miniconda3/envs/openfold/lib/python3.7/site-packages/ < openfold/lib/openmm.patch

RUN cd openfold && \
	/root/miniconda3/envs/openfold/bin/pip install -e .

# Set up development environment (which include AlphaFold2 for equivalence testing)
FROM base as dev
RUN /root/miniconda3/envs/openfold/bin/pip install pytest mock matplotlib

# Download AlphaFold2 parameters.
RUN mkdir -p alphafold-params \
    && wget -nv https://storage.googleapis.com/alphafold/alphafold_params_2022-03-02.tar -O params.tar \
    && tar --extract --verbose --file=params.tar --directory=alphafold-params --preserve-permissions \
    && rm -f params.tar \
    && ln -s ~/alphafold-params/ openfold/resources/params

RUN git clone https://github.com/deepmind/alphafold.git
RUN /root/miniconda3/envs/openfold/bin/pip install -r alphafold/requirements.txt --no-cache-dir \
    && /root/miniconda3/envs/openfold/bin/pip install --upgrade  --no-cache-dir \
        jax==0.3.17 \
        jaxlib==0.3.15+cuda11.cudnn805 \
            -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html \
    && /root/miniconda3/envs/openfold/bin/pip install -e alphafold/

# Set up pycharm remote
FROM dev as pycharm
RUN mkdir pycharm \
    && wget -P pycharm https://download.jetbrains.com/python/pycharm-professional-2022.2.2.tar.gz \
    && tar xzf pycharm/*.tar.gz -C /opt/ \
    && rm -rf pycharm

ENV CWM_TRUST_PROJECTS=1
CMD /opt/pycharm-2022.2.2/bin/remote-dev-server.sh run ~/openfold -l 0.0.0.0 -p 5993


