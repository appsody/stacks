FROM python:3.7
  
WORKDIR /app

COPY requirements.txt /tmp/requirements.txt
RUN  pip install --upgrade pip \
  && pip install --upgrade pipenv\
  && pip install --upgrade -r /tmp/requirements.txt

COPY . /app
ENV FLASK_APP=server/__init__.py

EXPOSE 8080
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0", "--port=8080"]