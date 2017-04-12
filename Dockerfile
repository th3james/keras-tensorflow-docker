#FROM gcr.io/tensorflow/tensorflow
FROM ubuntu:16.04

ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH

RUN mkdir -p $CONDA_DIR && \
    echo export PATH=$CONDA_DIR/bin:'$PATH' > /etc/profile.d/conda.sh && \
    apt-get update && \
    apt-get install -y wget git libhdf5-dev g++ graphviz bzip2 && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.2.11-Linux-x86_64.sh
RUN /bin/bash /Miniconda3-4.2.11-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-4.2.11-Linux-x86_64.sh

ENV NB_USER keras
ENV NB_UID 1000

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir -p $CONDA_DIR && \
    chown keras $CONDA_DIR -R && \
    mkdir -p /src && \
    chown keras /src

USER keras

# Python
ARG python_version=3.5

RUN conda install -y python=${python_version} && \
    pip install --upgrade pip && \
    conda install Pillow scikit-learn notebook pandas matplotlib mkl nose pyyaml six h5py pydot3 tensorflow && \
    git clone git://github.com/fchollet/keras.git /src && pip install -e /src[tests] && \
    pip install git+git://github.com/fchollet/keras.git && \
    conda clean -yt

ENV PYTHONPATH='/src/:$PYTHONPATH'

WORKDIR /src

EXPOSE 8888

CMD jupyter notebook --port=8888 --ip=0.0.0.0
