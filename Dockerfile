FROM python:3.9.6-slim-buster as base

# Setup env
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1
ENV PATH=/root/.local/bin:$PATH
ENV LD_LIBRARY_PATH /usr/local/lib

ENV FT_APP_ENV="docker"

# Prepare environment
RUN mkdir /freqtrade \
  && apt-get update \
  && apt-get install -y libatlas3-base sqlite3 libhdf5-dev

RUN apt-get clean \
  && apt-get autoclean -y \
  && apt-get autoremove -y

WORKDIR /freqtrade

FROM base as python-deps

# Install compiler and development packages
RUN apt-get update \
  && apt-get -y install curl build-essential libssl-dev git libffi-dev libgfortran5 pkg-config cmake gcc

# TA-Lib
COPY ta-lib /tmp/ta-lib
RUN cd /tmp/ta-lib && \
  ./configure --prefix=/usr/local && \
  make && \
  make install

COPY requirements.txt requirements-hyperopt.txt /freqtrade/
RUN pip install --user --no-cache-dir -r requirements-hyperopt.txt

FROM base as runtime-image

COPY --from=python-deps /usr/local/lib /usr/local/lib
COPY --from=python-deps /root/.local /root/.local

ENTRYPOINT ["sh"]
