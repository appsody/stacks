FROM python:3.7

RUN pip install --user pipenv
ENV PATH=/root/.local/bin:$PATH

WORKDIR /app

COPY ./Pipfile .
RUN pipenv lock -r > requirements.txt
RUN python -m pip install -r requirements.txt -t /project/deps
COPY requirements.txt /tmp/requirements.txt
RUN  pip install --upgrade pip \
  && pip install --upgrade pipenv\
  && pip install --upgrade -r /tmp/requirements.txt

COPY . /app
ENV PYTHONPATH=/project/deps
ENV FLASK_APP=server/__init__.py

EXPOSE 8080
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0", "--port=8080"]