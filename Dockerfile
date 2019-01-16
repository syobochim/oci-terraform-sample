FROM python:3

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# virtualenv
RUN mkdir -p myvirtualspaces/virtualenvs
RUN virtualenv myvirtualspaces/virtualenvs/cli-testing --no-site-packages

# create api-key
RUN mkdir ~/.oci
RUN openssl genrsa -out ~/.oci/oci_api_key.pem 2048
RUN chmod go-rwx ~/.oci/oci_api_key.pem
RUN openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem


CMD [ "cat", "/root/.oci/oci_api_key_public.pem" ]
