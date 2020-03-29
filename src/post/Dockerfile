FROM alpine:3.8 as python-env

WORKDIR /app
ADD . /app

ENV VENV_PATH /pyenv
ENV PATH $VENV_PATH/bin:$PATH

RUN apk --no-cache --update add build-base python3 musl-dev python3-dev \
    && wget https://bootstrap.pypa.io/get-pip.py -O get-pip.py \
    && python3 get-pip.py \
    && pip install virtualenv==16.7.9 \
    && python3 -m virtualenv --system-site-packages $VENV_PATH \
    && pip --no-cache-dir install --prefix=$VENV_PATH -r /app/requirements.txt \
    && apk del build-base

FROM alpine:3.8
LABEL imagename="post" version="logging"
WORKDIR /app
ADD . /app
ENV VENV_PATH /pyenv
RUN apk --no-cache add python3
COPY --from=python-env $VENV_PATH $VENV_PATH
ENV PATH $VENV_PATH/bin:$PATH
ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

ENTRYPOINT ["/pyenv/bin/python", "post_app.py"]
